package tencent.ad

import android.Manifest.permission.ACCESS_FINE_LOCATION
import android.Manifest.permission.READ_PHONE_STATE
import android.annotation.TargetApi
import android.content.Intent
import android.content.pm.PackageManager.PERMISSION_DENIED
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.net.Uri
import android.os.Build
import android.os.Build.VERSION.SDK_INT
import android.provider.Settings
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import tencent.ad.O.TAG
import tencent.ad.O.bannerID
import tencent.ad.O.nativeID
import java.text.SimpleDateFormat
import java.util.*
import kotlin.collections.ArrayList

@Suppress("SpellCheckingInspection")
class TencentADPlugin : MethodCallHandler, RequestPermissionsResultListener {
    private var splashAD: SplashAD? = null
    private var lackedPermission = ArrayList<String>()
    private var phoneSTAT = 0
    private var fineLOC = 0
    private var requestCode = 0

    override fun onMethodCall(call: MethodCall, result: Result) {
        val arguments = call.arguments as Map<*, *>
        when (call.method) {
            "config" -> {
                O.appID = "${arguments["appID"]}"
                phoneSTAT = 0
                fineLOC = 0
                when {
                    // 监测权限
                    SDK_INT >= 23 -> {
                        registrar.addRequestPermissionsResultListener(this)
                        checkAndRequestPermission()
                    }
                }
                result.success(true)
            }
            "createIntersAD" -> {
                val posID = arguments["posID"] as String?
                if (posID == null) {
                    result.error("posID cannot be null!", null, null)
                    return
                }
                if (UNIFIED_INTERS_AD_MAP.containsKey(posID)) {
                    UNIFIED_INTERS_AD_MAP[posID]!!.closeAD()
                }
                UNIFIED_INTERS_AD_MAP[posID] = IntersAD(posID, registrar.messenger())
                result.success(true)
            }
            "showSplash" -> {
                val posID = "${arguments["posID"]}"
                val bgPic = "${arguments["bgPic"]}"
                if (splashAD != null) splashAD?.closeAD()
                splashAD = SplashAD(
                        registrar.activity(),
                        registrar.messenger(),
                        posID,
                        bgPic,
                        null
                )
                splashAD?.showAD()
            }
            "closeSplash" -> splashAD!!.closeAD()
            else -> result.notImplemented()
        }
    }

    // 获取必要权限
    @Suppress("SpellCheckingInspection")
    @TargetApi(Build.VERSION_CODES.M)
    private fun checkAndRequestPermission() {
        when {
            phoneSTAT > 0 && activity.checkSelfPermission(READ_PHONE_STATE) != PERMISSION_GRANTED
            -> {
                lackedPermission.add(READ_PHONE_STATE)
            }
            lackedPermission.size > 0 -> {
                val requestPermissions = arrayOfNulls<String>(lackedPermission.size)
                lackedPermission.toArray(requestPermissions)
                registrar.addRequestPermissionsResultListener(this)
                requestCode = SimpleDateFormat("MMddHHmmss", Locale.CHINA).format(Date()).toInt()
                activity.requestPermissions(requestPermissions, requestCode)
                Log.i(TAG, "请求权限中...")
            }
            fineLOC > 0 && activity.checkSelfPermission(ACCESS_FINE_LOCATION) != PERMISSION_GRANTED
            -> {
                lackedPermission.add(ACCESS_FINE_LOCATION)
            }
        }
    }

    private fun isPermissionsFine(grantResults: IntArray): Boolean {
        for (i in grantResults.indices) {
            val grantResult = grantResults[i]
            // 有必须权限未授予
            when {
                grantResult == PERMISSION_DENIED && (lackedPermission[i] == ACCESS_FINE_LOCATION
                        && fineLOC == 2 ||
                        lackedPermission[i] == READ_PHONE_STATE && phoneSTAT == 2) -> {
                    return false
                }
            }
        }
        return true
    }

    override fun onRequestPermissionsResult(
            requestCode: Int,
            permissions: Array<String>,
            grantResults: IntArray
    ) = when (requestCode) {
        this.requestCode -> {
            Log.i(TAG, "onRequestPermissionsResult $requestCode")
            if (!isPermissionsFine(grantResults)) {
                Log.i(TAG, "权限被禁止")
                val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
                intent.data = Uri.parse("package:" + activity.packageName)
                activity.startActivity(intent)
                activity.finish()
            }
            true
        }
        else -> false
    }

    companion object {
        private lateinit var registrar: Registrar
        private lateinit var instance: TencentADPlugin
        private val UNIFIED_INTERS_AD_MAP: MutableMap<String, IntersAD?> = HashMap()
        internal val activity get() = registrar.activity()

        // 插件注册
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            Companion.registrar = registrar
            instance = TencentADPlugin()
            MethodChannel(registrar.messenger(), O.pluginID).setMethodCallHandler(instance)
            registrar.platformViewRegistry().registerViewFactory(
                    bannerID,
                    BannerADFactory(registrar.messenger())
            )
            registrar.platformViewRegistry().registerViewFactory(
                    nativeID,
                    NativeADFactory(registrar.messenger())
            )
        }

        internal fun removeInterstitial(posID: String?) {
            UNIFIED_INTERS_AD_MAP.remove(posID)
        }
    }
}
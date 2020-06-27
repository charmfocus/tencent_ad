package tencent.ad

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.FrameLayout.LayoutParams
import android.widget.FrameLayout.LayoutParams.MATCH_PARENT
import com.qq.e.ads.splash.SplashAD
import com.qq.e.ads.splash.SplashADListener
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import tencent.ad.O.TAG

class SplashAD(
        private val activity: Activity,
        private val context: Context,
        private val messenger: BinaryMessenger?,
        private val posID: String?,
        private var instance: SplashAD?,
        private val id: Int?
) : SplashADListener, PlatformView, MethodChannel.MethodCallHandler {
    private var methodChannel: MethodChannel
    private val container = FrameLayout(context)

    fun showAD(posID: String?) = fetchSplashAD(activity, null, posID ?: this.posID!!, this, 0)

    private fun closeAD() {
        val parent = container.parent as ViewGroup
        parent.removeView(container)
        instance = null
    }

    /**
     * 拉取开屏广告，开屏广告的构造方法有3种，详细说明请参考文档。
     * @param activity        展示广告的activity
     * @param skipContainer   自定义的跳过按钮：只需绘制样式
     * @param posID           广告位ID
     * @param adListener      广告状态监听器
     * @param fetchDelay      拉取广告的超时时长：[3000, 5000]，0为默认
     */
    @Suppress("SameParameterValue")
    private fun fetchSplashAD(
            activity: Activity,
            skipContainer: View?,
            posID: String,
            adListener: SplashADListener,
            fetchDelay: Int
    ) {
        Log.i(TAG, "fetchSplashAD: ${O.splashID}_$posID")
        if (instance != null) return
        instance = skipContainer?.let {
            SplashAD(activity, it, posID, adListener, fetchDelay)
        } ?: SplashAD(activity, posID, adListener, fetchDelay)
        instance!!.fetchAndShowIn(container)
//        activity.window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_FULLSCREEN
    }

    init {
        val key = if (posID == null || posID.isEmpty()) {
            "${O.splashID}_${id}"
        } else {
            "${O.splashID}_${posID}"
        }

        methodChannel = MethodChannel(messenger, key)
        methodChannel.setMethodCallHandler(this)
        container.layoutParams = LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
        container.setBackgroundColor(Color.WHITE)
//        activity.addContentView(container, LayoutParams(MATCH_PARENT, MATCH_PARENT))
    }

    override fun onADExposure() = methodChannel.invokeMethod("onADExposure", null)
    override fun onADPresent() = methodChannel.invokeMethod("onADPresent", null)
    override fun onADLoaded(time: Long) = methodChannel.invokeMethod("onADLoaded", null)
    override fun onADClicked() = methodChannel.invokeMethod("onADClicked", null)
    override fun onADTick(time: Long) = methodChannel.invokeMethod("onADTick", null)

    override fun onADDismissed() {
        closeAD()
        methodChannel.invokeMethod("onADDismissed", null)
    }

    override fun onNoAD(error: AdError) {
        methodChannel.invokeMethod("onNoAD", null)
        Log.i(TAG, "SplashAD onNoAD:无广告 错误码:${error.errorCode} ${error.errorMsg}")
        closeAD()
    }

    override fun getView(): View {
        return container
    }

    override fun dispose() {
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> {
                val posID = call.argument<String>("posID")
                showAD(posID)
            }
            else -> result.notImplemented()
        }
    }
}
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
import androidx.core.content.ContextCompat
import com.qq.e.ads.splash.SplashAD
import com.qq.e.ads.splash.SplashADListener
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import tencent.ad.O.TAG
import tencent.ad.TencentADPlugin.Companion.activity

class SplashAD(
        context: Context,
        messenger: BinaryMessenger?,
        private val poID: String,
        bgPic: String?,
        private var instance: SplashAD?
) : SplashADListener {
    private val methodChannel = MethodChannel(messenger, O.splashID)
    private val container = FrameLayout(context)

    fun showAD() = fetchSplashAD(activity, null, O.appID, poID, this, 0)

    fun closeAD() {
        methodChannel.setMethodCallHandler(null)
        val parent = container.parent as ViewGroup
        parent.removeView(container)
        instance = null
    }

    /**
     * 拉取开屏广告，开屏广告的构造方法有3种，详细说明请参考文档。
     * @param activity        展示广告的activity
     * @param skipContainer   自定义的跳过按钮：只需绘制样式
     * @param appID           应用ID
     * @param posID           广告位ID
     * @param adListener      广告状态监听器
     * @param fetchDelay      拉取广告的超时时长：[3000, 5000]，0为默认
     */
    @Suppress("SameParameterValue")
    private fun fetchSplashAD(
            activity: Activity,
            skipContainer: View?,
            appID: String,
            posID: String,
            adListener: SplashADListener,
            fetchDelay: Int
    ) {
        if (instance != null) return
        instance = skipContainer?.let {
            SplashAD(activity, it, appID, posID, adListener, fetchDelay)
        } ?: SplashAD(activity, appID, posID, adListener, fetchDelay)
        instance!!.fetchAndShowIn(container)
    }

    init {
        container.setBackgroundColor(Color.WHITE)
        if (bgPic != null) {
            try {
                val manager = activity.packageManager
                val resources = manager.getResourcesForApplication(bgPic
                        .substring(0, bgPic.indexOf(":")))
                val resourceID = resources.getIdentifier(bgPic, null, null)
                container.background = ContextCompat.getDrawable(context, resourceID)
            } catch (e: Exception) {
                Log.i(TAG, "广告背景未获取, 资源:$bgPic", e)
            }
        }
        container.layoutParams = LayoutParams(MATCH_PARENT, MATCH_PARENT)
        activity.addContentView(container, LayoutParams(MATCH_PARENT, MATCH_PARENT))
    }

    override fun onADExposure() = methodChannel.invokeMethod("onADExposure", null)
    override fun onADPresent() = methodChannel.invokeMethod("onADPresent", null)
    override fun onADLoaded(time: Long) = methodChannel.invokeMethod("onADLoaded", time)
    override fun onADClicked() = methodChannel.invokeMethod("onADClicked", null)
    override fun onADTick(time: Long) = methodChannel.invokeMethod("onADTick", time)

    override fun onADDismissed() {
        closeAD()
        methodChannel.invokeMethod("onADDismissed", null)
    }

    override fun onNoAD(error: AdError) {
        methodChannel.invokeMethod("onNoAD", null)
        Log.i(TAG, "SplashAD onNoAD:无广告 错误码:${error.errorCode} ${error.errorMsg}")
        closeAD()
    }
}
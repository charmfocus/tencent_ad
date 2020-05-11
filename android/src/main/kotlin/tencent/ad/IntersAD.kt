package tencent.ad

import android.util.Log
import com.qq.e.ads.interstitial2.UnifiedInterstitialAD
import com.qq.e.ads.interstitial2.UnifiedInterstitialADListener
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class IntersAD(private val posID: String, messenger: BinaryMessenger?) :
        MethodCallHandler, UnifiedInterstitialADListener {
    private var iad: UnifiedInterstitialAD? = null
    private val methodChannel = MethodChannel(messenger, "${O.intersID}_$posID")

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(methodCall: MethodCall, result: MethodChannel.Result) {
        when (methodCall.method) {
            "load" -> {
                iAD.loadAD()
                result.success(true)
            }
            "show" -> {
                showAD()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    fun closeAD() {
        if (iad != null) {
            iad!!.destroy()
            iad = null
        }
        methodChannel.setMethodCallHandler(null)
        TencentADPlugin.removeInterstitial(posID)
    }

    private val iAD: UnifiedInterstitialAD
        get() {
            if (iad != null) {
                return iad!!
            }
            iad = UnifiedInterstitialAD(TencentADPlugin.activity, O.appID, posID, this)
            return iad!!
        }

    private fun showAD() {
        iAD.showAsPopupWindow()
    }

    override fun onNoAD(error: AdError) {
        iad = null
        methodChannel.invokeMethod("onNoAD", null)
        Log.i(O.TAG, "IntersAD onNoAD:无广告 错误码:${error.errorCode} ${error.errorMsg}")
    }

    override fun onADClosed() {
        iad = null
        methodChannel.invokeMethod("onADClosed", null)
    }

    override fun onADReceive() = methodChannel.invokeMethod("onADReceived", null)
    override fun onADExposure() = methodChannel.invokeMethod("onADExposure", null)
    override fun onADClicked() = methodChannel.invokeMethod("onADClicked", null)
    override fun onADLeftApplication() = methodChannel.invokeMethod("onADLeftApplication", null)
    override fun onADOpened() = methodChannel.invokeMethod("onADOpened", null)
    override fun onVideoCached() = methodChannel.invokeMethod("onVideoCached", null)

}
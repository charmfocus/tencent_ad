package tencent.ad

import android.content.Context
import com.qq.e.ads.cfg.VideoOption
import com.qq.e.ads.nativ.NativeADUnifiedListener
import com.qq.e.ads.nativ.NativeUnifiedAD
import com.qq.e.ads.nativ.NativeUnifiedADData
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class NativeADDIY(
        private val context: Context,
        private val posID: String,
        messenger: BinaryMessenger
) : MethodCallHandler, NativeADUnifiedListener {
    private lateinit var nativeUnifiedAD: NativeUnifiedAD  // 广告UI
    private var adData: NativeUnifiedADData? = null // 广告数据

    private val methodChannel: MethodChannel by lazy {
        MethodChannel(messenger, "${O.nativeDIYID}_$posID")
    }

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "load" -> {
                loadAD()
                adData?.destroy()
                nativeUnifiedAD.loadData(1)
                result.success(adData)
            }
            "destroy" -> {
                adData?.destroy()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    private fun loadAD() {
        nativeUnifiedAD = NativeUnifiedAD(context, O.nativeDIYID, this)
        nativeUnifiedAD.run {
            setMinVideoDuration(0)
            setMaxVideoDuration(0)
            setVideoPlayPolicy(VideoOption.VideoPlayPolicy.AUTO)
            setVideoADContainerRender(VideoOption.VideoADContainerRender.SDK)
            loadData(1)
        }
    }
//
//    fun closeAD() {
//        methodChannel.setMethodCallHandler(null)
//        TencentADPlugin.removeRender(posID)
//    }

    override fun onNoAD(error: AdError) = methodChannel.invokeMethod("onNoAD", null)

    override fun onADLoaded(adDataList: MutableList<NativeUnifiedADData>) =
            methodChannel.invokeMethod("onADLoaded", adDataList)
}
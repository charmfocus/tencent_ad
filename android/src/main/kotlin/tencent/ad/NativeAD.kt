package tencent.ad

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.qq.e.ads.nativ.NativeADUnifiedListener
import com.qq.e.ads.nativ.NativeUnifiedADData
import com.qq.e.comm.util.AdError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class NativeAD(
        context: Context,
        messenger: BinaryMessenger,
        unitID: Int,
        params: Map<String, Any>
) : PlatformView, MethodCallHandler, NativeADUnifiedListener {
    private lateinit var container: FrameLayout

    private val methodChannel: MethodChannel by lazy {
        MethodChannel(messenger, O.intersID + "_" + unitID)
    }

    init {
        methodChannel.setMethodCallHandler(this)
    }

    override fun getView(): View {
        methodChannel.invokeMethod("getView", null)
        return container
    }

    override fun dispose() {
        methodChannel.invokeMethod("dispose", null)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "" -> result.success(true)
            else -> result.notImplemented()
        }
    }

    override fun onNoAD(error: AdError) = methodChannel.invokeMethod("onNoAD", error)

    override fun onADLoaded(adDataList: MutableList<NativeUnifiedADData>) =
            methodChannel.invokeMethod("onADLoaded", adDataList)

    class NativeADFactory(private val messenger: BinaryMessenger) :
            PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        @Suppress("UNCHECKED_CAST")
        override fun create(context: Context, viewId: Int, args: Any) = NativeAD(
                context, messenger, viewId, args as Map<String, Any>)
    }
}
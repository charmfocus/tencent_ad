package tencent.ad

import android.app.Activity
import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class SplashADFactory(private val activity: Activity, private val messenger: BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    fun getView(): SplashAD? {
        return splashAD
    }

    private var splashAD: SplashAD? = null

    override fun create(context: Context, id: Int, o: Any?): PlatformView {
        splashAD = SplashAD(activity, context, messenger, "", null, id)
        return splashAD as SplashAD
    }

}

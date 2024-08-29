package flutter.kakao.flutter_adfit

import android.app.Activity
import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.JSONMessageCodec
import io.flutter.plugin.platform.PlatformViewFactory

class BizBoardAdFactory
    private constructor(private val messenger: BinaryMessenger)
            : PlatformViewFactory(JSONMessageCodec.INSTANCE) {

    lateinit var activity: Activity
    private var adView: BizBoardAdBuilder? = null

    override fun create(context: Context?, id: Int, args: Any?): BizBoardAdBuilder {
        return BizBoardAdBuilder(activity, messenger, id, args).also { adView = it }
    }

    fun onDestroy() {
        adView?.dispose()
    }

    companion object {
        /**
         * Flutter Android v2 API (using FlutterPluginBinding)
         */
        fun registerWith(flutterPluginBinding: FlutterPluginBinding): BizBoardAdFactory {
            val plugin = BizBoardAdFactory(flutterPluginBinding.binaryMessenger)
            flutterPluginBinding.platformViewRegistry.registerViewFactory(
                "flutter.kakao.adfit/AdFitView/native", plugin)
            return plugin
        }
    }
}
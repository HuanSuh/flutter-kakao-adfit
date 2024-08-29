package flutter.kakao.flutter_adfit

import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FlutterAdfitPlugin */
class FlutterAdfitPlugin: FlutterPlugin, ActivityAware {

  private lateinit var adViewFactory : AdViewFactory
  private lateinit var bizBoardAdFactory: BizBoardAdFactory

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    adViewFactory = AdViewFactory.registerWith(flutterPluginBinding)
    bizBoardAdFactory = BizBoardAdFactory.registerWith(flutterPluginBinding)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    adViewFactory.onDestroy()
    bizBoardAdFactory.onDestroy()
  }

  override fun onDetachedFromActivity() {}
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
  override fun onDetachedFromActivityForConfigChanges() {}
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    adViewFactory.activity = binding.activity;
    bizBoardAdFactory.activity = binding.activity;
  }
}

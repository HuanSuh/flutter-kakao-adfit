package flutter.kakao.flutter_adfit

import android.app.Activity
import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FlutterAdfitPlugin */
class FlutterAdfitPlugin: FlutterPlugin, ActivityAware {

  private lateinit var adViewFactory : AdViewFactory

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    adViewFactory = AdViewFactory.registerWith(flutterPluginBinding)
  }
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      AdViewFactory.registerWith(registrar)
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    adViewFactory.onDestroy()
  }

  override fun onDetachedFromActivity() {}
  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
  override fun onDetachedFromActivityForConfigChanges() {}
  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    adViewFactory.activity = binding.activity;
  }
}

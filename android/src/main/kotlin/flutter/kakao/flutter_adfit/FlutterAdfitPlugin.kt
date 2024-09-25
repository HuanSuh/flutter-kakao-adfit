package flutter.kakao.flutter_adfit

import android.annotation.SuppressLint
import android.app.Activity
import android.util.Log
import android.webkit.CookieManager
import androidx.annotation.NonNull
import com.kakao.adfit.AdFitSdk
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar

/** FlutterAdfitPlugin */
class FlutterAdfitPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {

    private var pluginBinding: FlutterPlugin.FlutterPluginBinding? = null
    private lateinit var channel: MethodChannel
    private lateinit var adViewFactory: AdViewFactory

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.pluginBinding = flutterPluginBinding
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_adfit")
        channel.setMethodCallHandler(this)

        adViewFactory = AdViewFactory.registerWith(flutterPluginBinding)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        adViewFactory.onDestroy()
    }

    @SuppressLint("SetJavaScriptEnabled")
    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "registerInAppWebView" -> {
                val windowId: Int = call.argument<Int>("webViewId")?.let {
                    return@let it
                } ?: run {
                    result.error("400", "Invalid windowId : ${call.arguments}", null)
                    return
                }
//                AdFitSdk.register(webViewId, pluginBinding?.getFlutterEngine())
                result.success(windowId)
            }

            "registerWebViewFlutter" -> {
                val windowId: Long = call.argument<Int>("webViewId")?.let {
                    return@let it.toLong()
                } ?: run {
                    result.error("400", "Invalid windowId : ${call.arguments}", null)
                    return
                }
                WebViewFinder.findWebViewFlutter(pluginBinding?.flutterEngine, windowId)
                    ?.let { webView ->
                        // 3자 쿠키 사용 설정 허용
                        CookieManager.getInstance().setAcceptThirdPartyCookies(webView, true)
                        // JavaScript 사용 설정
                        webView.settings.javaScriptEnabled = true
                        // Local Storage 사용 설정
                        webView.settings.domStorageEnabled = true
                        // 비디오 자동 재생 허용 설정
                        webView.settings.mediaPlaybackRequiresUserGesture = false
                        val registered = AdFitSdk.register(webView)
                        result.success(registered)
                    } ?: run {
                    result.error("401", "Failed to find webView", "")
                }
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onDetachedFromActivity() {}
    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}
    override fun onDetachedFromActivityForConfigChanges() {}
    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        adViewFactory.activity = binding.activity;
    }
}
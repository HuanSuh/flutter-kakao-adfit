package flutter.kakao.flutter_adfit

import android.webkit.WebView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin
import io.flutter.plugins.webviewflutter.InstanceManager

interface WebViewFinder {
    companion object {
        fun findWebViewFlutter(engine: FlutterEngine?, identifier: Long): WebView? {
            val webViewPlugin: WebViewFlutterPlugin? =
                engine?.plugins?.get(WebViewFlutterPlugin::class.java) as WebViewFlutterPlugin?
            val instanceManager: InstanceManager? = webViewPlugin?.instanceManager
            return instanceManager?.let {
                val instance: WebView? = it.getInstance<WebView>(identifier)
                return@let instance
            }
        }
    }
}

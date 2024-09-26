package flutter.kakao.flutter_adfit

import android.webkit.WebView
import com.pichillilorenzo.flutter_inappwebview_android.InAppWebViewFlutterPlugin
import com.pichillilorenzo.flutter_inappwebview_android.webview.in_app_webview.FlutterWebView
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.webviewflutter.WebViewFlutterPlugin
import io.flutter.plugins.webviewflutter.InstanceManager

interface WebViewFinder {
    companion object {
        fun findInAppWebView(engine: FlutterEngine?, identifier: String): WebView? {
            val webViewPlugin: InAppWebViewFlutterPlugin? =
                engine?.plugins?.get(InAppWebViewFlutterPlugin::class.java) as InAppWebViewFlutterPlugin?
            val instance: WebView? =
                webViewPlugin?.inAppWebViewManager?.keepAliveWebViews?.get(identifier)?.webView
            return instance
        }

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

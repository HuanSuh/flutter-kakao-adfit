package flutter.kakao.flutter_adfit

import android.content.Context
import android.content.ContextWrapper
import android.view.View
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleObserver
import androidx.lifecycle.OnLifecycleEvent
import com.kakao.adfit.ads.AdListener
import com.kakao.adfit.ads.ba.BannerAdView
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import org.json.JSONException
import org.json.JSONObject

class NativeAdView(context: Context, messenger: BinaryMessenger, viewId: Int, arguments: Any?)
    : PlatformView, EventChannel.StreamHandler, MethodCallHandler {
    private var adView: BannerAdView = BannerAdView(context)
    private var eventSink: EventSink? = null
    private var methodChannel: MethodChannel? = null

    init {
        try {
            methodChannel = with(MethodChannel(messenger,
                    "flutter_adfit_view_$viewId")) {
                setMethodCallHandler(this@NativeAdView)
                return@with this
            }
            /* open an event channel */
            EventChannel(messenger, "flutter_adfit_event_$viewId", JSONMethodCodec.INSTANCE).setStreamHandler(this)

            loadAd(arguments as JSONObject)
        } catch (e: Exception) { /* ignore */ }
    }

    private fun loadAd(args: JSONObject) {
        val adId = args.getString("adId")
        with(adView) {
            setClientId(adId)  // 할당
            setAdListener(object : AdListener {
                // optional :: 광고 수신 리스너 설정
                // 배너 광고 노출 완료 시 호출
                override fun onAdLoaded() {
                    callback("didReceiveAd", adId)
                }

                // 배너 광고 노출 실패 시 호출
                override fun onAdFailed(errorCode: Int) {
                    callback("didFailToReceive", adId, errorCode.toString())
                }

                // 배너 광고 클릭 시 호출
                override fun onAdClicked() {
                    callback("didClickAd", adId)
                }
            })
            loadAd()
        }


//        // activity 또는 fragment의 lifecycle에 따라 호출
//        lifecycle.addObserver(object : LifecycleObserver {
//            @OnLifecycleEvent(Lifecycle.Event.ON_RESUME)
//            fun onResume() {
//                adView.resume()
//            }
//            @OnLifecycleEvent(Lifecycle.Event.ON_PAUSE)
//            fun onPause() {
//                adView.pause()
//            }
//            @OnLifecycleEvent(Lifecycle.Event.ON_DESTROY)
//            fun onDestroy() {
//                adView.destroy()
//            }
//        })
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "onDataChanged") {
            onDataChanged(call.arguments)
            result.success(true)
        } else {
            result.notImplemented()
        }
    }

    private fun onDataChanged(args: Any) {
        if (args is HashMap<*, *>) {
            loadAd(JSONObject(args))
        } else {
            callback("onError", null, "Invalid argument - $args");
        }
    }

    private fun callback(event: String, adId: String?) {
        callback(event, adId, null)
    }
    private fun callback(event: String, adId: String?, message: String?) {
        val data = JSONObject()
        data.put("event", event)
        data.put("adId", adId)
        data.put("message", message)
        eventSink?.success(data)
    }

    override fun getView(): View {
        return adView
    }

    override fun dispose() {
        adView.destroy()
        methodChannel?.setMethodCallHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}

package flutter.kakao.flutter_adfit

import android.content.Context
import android.view.View
import com.kakao.adfit.ads.na.AdFitAdInfoIconPosition
import com.kakao.adfit.ads.na.AdFitBizBoardAdTemplateLayout
import com.kakao.adfit.ads.na.AdFitNativeAdBinder
import com.kakao.adfit.ads.na.AdFitNativeAdLoader
import com.kakao.adfit.ads.na.AdFitNativeAdRequest
import com.kakao.adfit.ads.na.AdFitVideoAutoPlayPolicy
import io.flutter.plugin.common.*
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.platform.PlatformView
import org.json.JSONObject

class BizBoardAdBuilder(context: Context, messenger: BinaryMessenger, viewId: Int, arguments: Any?)
    : PlatformView, EventChannel.StreamHandler, MethodCallHandler {
    private val bizBoardAdTemplateLayout: AdFitBizBoardAdTemplateLayout = AdFitBizBoardAdTemplateLayout(context)
    private var eventSink: EventSink? = null
    private var methodChannel: MethodChannel? = null
    private lateinit var nativeAdLoader: AdFitNativeAdLoader


    init {
        try {
            methodChannel = with(MethodChannel(messenger,
                "flutter_adfit_view_$viewId")) {
                setMethodCallHandler(this@BizBoardAdBuilder)
                return@with this
            }
            /* open an event channel */
            EventChannel(messenger, "flutter_adfit_event_$viewId", JSONMethodCodec.INSTANCE).setStreamHandler(this)

            loadAd(context, arguments as JSONObject)
        } catch (e: Exception) { /* ignore */ }
    }

    private fun loadAd(context: Context, args: JSONObject) {
        val adId = args.getString("adId")
        nativeAdLoader = AdFitNativeAdLoader.create(context, adId)
        val request = AdFitNativeAdRequest.Builder()
            .setAdInfoIconPosition(AdFitAdInfoIconPosition.RIGHT_TOP) // 광고 정보 아이콘 위치 설정
            .setVideoAutoPlayPolicy(AdFitVideoAutoPlayPolicy.WIFI_ONLY) // 비디오 광고 자동 재생 정책 설정
            .build()


        nativeAdLoader.loadAd(request, object : AdFitNativeAdLoader.AdLoadListener {

            override fun onAdLoaded(binder: AdFitNativeAdBinder) {
                binder.bind(bizBoardAdTemplateLayout)
                callback("didReceiveAd", adId)
            }

            override fun onAdLoadError(errorCode: Int) {
                callback("didFailToReceive", adId, errorCode.toString())
            }
        })
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
//        if (args is HashMap<*, *>) {
//            loadAd(context, JSONObject(args))
//        } else {
//            callback("onError", null, "Invalid argument - $args");
//        }
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
        return bizBoardAdTemplateLayout
    }

    override fun dispose() {
//        bizBoardAdTemplateLayout.destroy()
        methodChannel?.setMethodCallHandler(null)
    }

    override fun onListen(arguments: Any?, events: EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}
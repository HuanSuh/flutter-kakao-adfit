import Foundation
import AdFitSDK
import AppTrackingTransparency
import AdSupport

class AdViewFactory: NSObject, FlutterPlatformViewFactory {
    
    var nativeAdView:NativeAdView?
    var registrar:FlutterPluginRegistrar?
    private var messenger:FlutterBinaryMessenger
    
    /* register video player */
    static func register(with registrar: FlutterPluginRegistrar) {
        let plugin = AdViewFactory(messenger: registrar.messenger())
        plugin.registrar = registrar
        registrar.register(plugin, withId: "flutter.kakao.adfit/AdFitView")
    }
    
    init(messenger:FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        self.nativeAdView = NativeAdView(frame: frame, viewId: viewId, messenger: messenger, args: args)
        self.registrar?.addApplicationDelegate(self.nativeAdView!)
        return self.nativeAdView!
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterJSONMessageCodec()
    }
    
    public func applicationDidEnterBackground() {}
    public func applicationWillEnterForeground() {}
}

class NativeAdView: NSObject, FlutterPlugin, FlutterStreamHandler, FlutterPlatformView, AdFitBannerAdViewDelegate {
    
    static func register(with registrar: FlutterPluginRegistrar) { }
    
    private var _view: UIView
    
    /* Flutter event streamer properties */
    private var eventChannel:FlutterEventChannel?
    private var flutterEventSink:FlutterEventSink?
    
    private var adView:AdFitBannerAdView?
    private var adId:String?
    
    deinit {
        print("[dealloc] adfit_view")
    }
    
    init(frame:CGRect, viewId: Int64, messenger: FlutterBinaryMessenger, args: Any?) {
        /* set view properties */
        self._view = UIView()
        super.init()
        self.inflateAdView(args)

        setupEventChannel(viewId: viewId, messenger: messenger, instance: self)
        setupMethodChannel(viewId: viewId, messenger: messenger)
    }
    
    /* set Flutter event channel */
    private func setupEventChannel(viewId: Int64, messenger:FlutterBinaryMessenger, instance:NativeAdView) {
        /* register for Flutter event channel */
        instance.eventChannel = FlutterEventChannel(name: "flutter_adfit_event_" + String(viewId), binaryMessenger: messenger, codec: FlutterJSONMethodCodec.sharedInstance())
        instance.eventChannel!.setStreamHandler(instance)
    }
    
    /* set Flutter method channel */
    private func setupMethodChannel(viewId: Int64, messenger:FlutterBinaryMessenger) {
        
        let nativeMethodsChannel = FlutterMethodChannel(name: "flutter_adfit_view_" + String(viewId), binaryMessenger: messenger);
        nativeMethodsChannel.setMethodCallHandler({
            (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if ("onDataChanged" == call.method) {
                self.inflateAdView(call.arguments)
            }
            /* not implemented yet */
            else { result(FlutterMethodNotImplemented) }
        })
    }
    
    /* create html native view */
    func view() -> UIView {
        return _view
    }
    
    private func inflateAdView(_ args: Any?) {
        /* data as JSON */
        if let parsedData = args as? [String: Any] {
            if let adId = parsedData["adId"] as? String, let width = parsedData["width"] as? Int,  let height = parsedData["height"] as? Int {
                _view.frame = CGRect(x: 0, y: 0, width: width, height: height)
                _view.subviews.forEach { $0.removeFromSuperview() }
                
                self.adId = adId
                self.adView = AdFitBannerAdView(clientId: adId, adUnitSize: "\(width)x\(height)")
                self.adView?.delegate = self
                adView?.frame = CGRect(x: 0, y: 0, width: width, height: height)
                _view.addSubview(adView!)
                loadAd()
                return
            }
        }
        
        self.flutterEventSink?(["event":"onError", "message": "Invalid arguments : \(args)"])
    }
    
    private func loadAd() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                self?.adView?.loadAd()
            }
        } else {
            self.adView?.loadAd()
        }
    }
    
    func adViewDidReceiveAd(_ bannerAdView: AdFitBannerAdView) {
        self.flutterEventSink?(["event":"didReceiveAd", "adId": bannerAdView.clientId])
    }
    
    func adViewDidFailToReceiveAd(_ bannerAdView: AdFitBannerAdView, error: Error) {
        self.flutterEventSink?(["event":"didFailToReceive", "adId": bannerAdView.clientId, "message":String(describing: error)])
    }
    
    func adViewDidClickAd(_ bannerAdView: AdFitBannerAdView) {
        self.flutterEventSink?(["event":"didClickAd", "adId": bannerAdView.clientId])
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        flutterEventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        flutterEventSink = nil
        return nil
    }
}

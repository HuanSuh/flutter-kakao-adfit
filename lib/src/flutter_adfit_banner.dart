part of flutter_adfit;

class AdFitBanner extends StatefulWidget {
  final String adId;
  final AdFitBannerSize adSize;

  /// [AdFitEvent] callback.
  /// Function([AdFitEvent] event, [AdFitEventData] data) { ... }
  final OnAdFitEvent? listener;

  /// true 시, ListView 등에서 광고 로드 재호출 방지
  /// (default true)
  final bool wantKeepAlive;

  final bool invisibleOnLoad;

  /// (Test)
  /// true 시, 상위 위젯 사이즈만큼 비율 유지하여 확대
  /// (default false, AdFitSDK 정책 검토 필요)
  final bool fillParent;

  const AdFitBanner({
    required this.adId,
    this.adSize = AdFitBannerSize.BANNER,
    this.listener,
    this.fillParent = false,
    this.wantKeepAlive = true,
    this.invisibleOnLoad = false,
    Key? key,
  }) : super(key: key);

  @override
  _AdFitBannerState createState() => _AdFitBannerState();
}

class _AdFitBannerState extends State<AdFitBanner>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.wantKeepAlive;

  late MethodChannel _channel;
  bool? _visible;
  bool get _isVisible => _visible != false;
  set visible(bool? value) {
    if (_visible != value) {
      _visible = value;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void didUpdateWidget(AdFitBanner oldWidget) {
    if (oldWidget.adId != widget.adId || oldWidget.adSize != widget.adSize) {
      _onDataChanged(widget.adId, widget.adSize);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onDataChanged(String adId, AdFitBannerSize adSize) {
    visible = null;
    _channel.invokeMethod("onDataChanged", {
      "adId": widget.adId,
      "width": widget.adSize.width,
      "height": widget.adSize.height,
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (Platform.isAndroid || Platform.isIOS) {
      return LayoutBuilder(builder: (_, constraint) {
        double scale = _getScale(constraint, widget.adSize);
        return Visibility(
            visible: _isVisible,
            child: (1.0 != scale)
                ? Container(
                    alignment: Alignment.center,
                    width: widget.adSize.width * scale,
                    height: widget.adSize.height * scale,
                    child: Transform.scale(
                      scale: scale,
                      child: _buildAdView(),
                    ),
                  )
                : _buildAdView());
        if (1.0 < scale) {
          return Container(
            alignment: Alignment.center,
            width: widget.adSize.width * scale,
            height: widget.adSize.height * scale,
            child: Transform.scale(
              scale: scale,
              child: _buildAdView(),
            ),
          );
        }
        return _buildAdView();
      });
    }
    debugPrint(
      'flutter_adfit package only support for Android and IOS.\n'
      'Current platform is ${Platform.operatingSystem}',
    );
    return Container();
  }

  /// scale 여부 체크 및 scale factor 리턴 (min 1.0 : scale 축소 방지)
  double _getScale(BoxConstraints constraints, AdFitBannerSize adSize) {
    if (!_isVisible) return 0.0;
    double scale = 1.0;
    if (widget.fillParent == true) {
      Size constraintSize = constraints.biggest;
      if (adSize.width <= constraintSize.width &&
          adSize.height <= constraintSize.height) {
        scale = min(
          constraintSize.width / adSize.width,
          constraintSize.height / adSize.height,
        );
      }
    }
    return max(1.0, scale);
  }

  Widget _buildAdView() {
    if (Platform.isAndroid) {
      return SizedBox(
        width: widget.adSize.width * 1.0,
        height: widget.adSize.height * 1.0,
        child: AndroidView(
          viewType: 'flutter.kakao.adfit/AdFitView',
          creationParams: {
            "adId": widget.adId,
            "width": widget.adSize.width,
            "height": widget.adSize.height,
          },
          creationParamsCodec: const JSONMessageCodec(),
          onPlatformViewCreated: (viewId) => _onPlatformViewCreated(viewId),
        ),
      );
    } else if (Platform.isIOS) {
      return SizedBox(
        width: widget.adSize.width * 1.0,
        height: widget.adSize.height * 1.0,
        child: UiKitView(
          viewType: 'flutter.kakao.adfit/AdFitView',
          creationParams: {
            "adId": widget.adId,
            "width": widget.adSize.width,
            "height": widget.adSize.height,
          },
          creationParamsCodec: const JSONMessageCodec(),
          onPlatformViewCreated: (viewId) => _onPlatformViewCreated(viewId),
        ),
      );
    }
    return Container();
  }

  void _onPlatformViewCreated(int viewId) {
    _channel = MethodChannel('flutter_adfit_view_$viewId');
    _listenForNativeEvents(viewId);
  }

  void _listenForNativeEvents(int viewId) {
    EventChannel eventChannel =
        EventChannel("flutter_adfit_event_$viewId", const JSONMethodCodec());
    eventChannel.receiveBroadcastStream().listen(_processNativeEvent);
  }

  void _processNativeEvent(dynamic data) async {
    AdFitEventData eventData = AdFitEventData._build(data);
    if (eventData.event != null) {
      switch (eventData.event) {
        case AdFitEvent.AdReceived:
          visible = true;
          break;
        case AdFitEvent.AdClicked:
          break;
        case AdFitEvent.AdReceiveFailed:
          visible = false;
          break;
        case AdFitEvent.OnError:
          visible = false;
          break;
      }
      widget.listener?.call(eventData.event!, eventData);
    }
  }
}

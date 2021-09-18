import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// AdFitSDK 에서 제공하는 Banner size
class AdFitBannerSize {
  /// Banner width
  final int width;

  /// Banner height
  final int height;

  const AdFitBannerSize._(this.width, this.height);

  static const AdFitBannerSize LARGE_RECTANGLE = AdFitBannerSize._(300, 250);
  static const AdFitBannerSize BANNER = AdFitBannerSize._(320, 100);
  static const AdFitBannerSize SMALL_BANNER = AdFitBannerSize._(320, 50);
}

/// [AdFitEvent] callback
typedef OnAdFitEvent = Function(AdFitEvent event, AdFitEventData data);

/// [OnAdFitEvent] callback 에 사용되는 event type
enum AdFitEvent {
  /// 배너 광고 노출 완료 시
  AdReceived,

  /// 배너 광고 클릭 시
  AdClicked,

  /// 배너 광고 노출 실패 시 (AdFitSDK 에러 메시지)
  AdReceiveFailed,

  /// 패키지 내부에서 에러 발생 시
  OnError,
}

/// [OnAdFitEvent] callback 에 사용되는 event data
class AdFitEventData {
  /// Event type
  final AdFitEvent? event;

  /// 호출된 ad Id
  final String? adId;

  /// Event message
  final String? message;

  /// Default constructor
  AdFitEventData._({this.event, this.adId, this.message});

  factory AdFitEventData._build(dynamic data) {
    AdFitEvent event;
    if (data is Map<String, dynamic>) {
      String eventName = data["event"];
      switch (eventName) {
        case "didReceiveAd":
          event = AdFitEvent.AdReceived;
          break;
        case "didClickAd":
          event = AdFitEvent.AdClicked;
          break;
        case "didFailToReceive":
          event = AdFitEvent.AdReceiveFailed;
          break;
        case "onError":
          event = AdFitEvent.OnError;
          break;
        default:
          return AdFitEventData._();
      }
      return AdFitEventData._(
        event: event,
        adId: data["adId"],
        message: data["message"],
      );
    }
    return AdFitEventData._();
  }

  @override
  String toString() {
    return 'AdFitEventData{event: $event, adId: $adId, message: $message}';
  }
}

class AdFitBanner extends StatefulWidget {
  final String adId;
  final AdFitBannerSize adSize;

  /// [AdFitEvent] callback.
  /// Function([AdFitEvent] event, [AdFitEventData] data) { ... }
  final OnAdFitEvent? listener;

  /// true 시, ListView 등에서 광고 로드 재호출 방지
  /// (default true)
  final bool wantKeepAlive;

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

  @override
  void didUpdateWidget(AdFitBanner oldWidget) {
    if (oldWidget.adId != widget.adId || oldWidget.adSize != widget.adSize) {
      _onDataChanged(widget.adId, widget.adSize);
    }
    super.didUpdateWidget(oldWidget);
  }

  void _onDataChanged(String adId, AdFitBannerSize adSize) {
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
        if (1.0 < scale) {
          return Transform.scale(
            scale: scale,
            child: _buildAdView(),
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
      widget.listener?.call(eventData.event!, eventData);
    }
  }
}

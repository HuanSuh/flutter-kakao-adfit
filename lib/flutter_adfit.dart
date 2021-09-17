import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

///
///
///
class AdFitBannerSize {
  final int width;
  final int height;

  const AdFitBannerSize._(this.width, this.height);

  static const AdFitBannerSize LARGE_RECTANGLE = AdFitBannerSize._(300, 250);
  static const AdFitBannerSize BANNER = AdFitBannerSize._(320, 100);
  static const AdFitBannerSize SMALL_BANNER = AdFitBannerSize._(320, 50);
}

///
///
///
typedef OnAdFitEvent = Function(AdFitEvent event, AdFitEventData data);
enum AdFitEvent {
  AdReceived,
  AdClicked,
  AdReceiveFailed,
  OnError,
}

class AdFitEventData {
  final String adId;
  final String message;

  AdFitEventData({this.adId, this.message});

  @override
  String toString() {
    return 'AdFitEventData{adId: $adId, message: $message}';
  }
}

///
///
///
class AdFitBanner extends StatefulWidget {
  final String androidAdId;
  final String iosAdId;
  // final String webAdId;
  final AdFitBannerSize adSize;
  final OnAdFitEvent listener;
  final bool fillParent;
  final bool wantKeepAlive;

  AdFitBanner({
    this.androidAdId,
    this.iosAdId,
    // this.webAdId,
    this.adSize: AdFitBannerSize.BANNER,
    this.listener,
    this.fillParent: false,
    this.wantKeepAlive: true,
    Key key,
  }) : super(key: key);

  @override
  _AdFitBannerState createState() => _AdFitBannerState();

  String get adId {
    if (Platform.isAndroid) {
      return androidAdId ?? '';
    }
    if (Platform.isIOS) {
      return iosAdId ?? '';
    }
    return '';
  }
}

class _AdFitBannerState extends State<AdFitBanner>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => widget.wantKeepAlive;

  MethodChannel _channel;

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
        double scale = getScale(constraint, widget.adSize);
        if (1.0 < scale)
          return Transform.scale(
            scale: scale,
            child: _buildAdView(),
          );
        return _buildAdView();
      });
    }
    debugPrint(
      'flutter_adfit package only support for Android and IOS.\n'
      'Current platform is ${Platform.operatingSystem}',
    );
    return Container();
  }

  double getScale(BoxConstraints constraints, AdFitBannerSize adSize) {
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
      return Container(
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
      return Container(
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
        EventChannel("flutter_adfit_event_$viewId", JSONMethodCodec());
    eventChannel.receiveBroadcastStream().listen(_processNativeEvent);
  }

  void _processNativeEvent(dynamic data) async {
    if (data is Map<String, dynamic>) {
      String eventName = data["event"];
      AdFitEvent event;
      AdFitEventData eventData =
          AdFitEventData(adId: data["adId"], message: data["message"]);

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
          return;
      }
      widget.listener?.call(event, eventData);
    }
  }
}

part of flutter_adfit;

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

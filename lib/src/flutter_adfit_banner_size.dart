part of flutter_adfit;

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

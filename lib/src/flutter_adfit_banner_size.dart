// ignore_for_file: constant_identifier_names

part of '../flutter_adfit.dart';

/// AdFitSDK 에서 제공하는 Banner size
class AdFitBannerSize {
  /// Banner width
  final int width;

  /// Banner height
  final int height;

  final bool isNative;

  const AdFitBannerSize._(this.width, this.height, [this.isNative = false]);

  static const AdFitBannerSize LARGE_RECTANGLE = AdFitBannerSize._(300, 250);
  static const AdFitBannerSize BANNER = AdFitBannerSize._(320, 100);
  static const AdFitBannerSize SMALL_BANNER = AdFitBannerSize._(320, 50);
  static const AdFitBannerSize NATIVE_BIZBOARD = AdFitBannerSize._(780, 200, true);
}

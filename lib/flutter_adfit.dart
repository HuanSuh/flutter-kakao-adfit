library flutter_adfit;

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

part 'src/flutter_adfit_banner.dart';
part 'src/flutter_adfit_banner_size.dart';
part 'src/flutter_adfit_event.dart';

class FlutterAdFit {
  static FlutterAdFit get instance => _instance;
  static const FlutterAdFit _instance = FlutterAdFit._();

  const FlutterAdFit._();

  final MethodChannel _channel = const MethodChannel('flutter_adfit');

  Future<dynamic> registerInAppWebView(InAppWebViewController controller) {
    return _channel.invokeMethod('registerInAppWebView', <dynamic, dynamic>{
      'webViewId': controller.platform.id,
    });
  }

  Future<dynamic> registerWebViewFlutter(WebViewController controller) {
    int webViewIdentifier(WebViewController controller) {
      if (WebViewPlatform.instance is AndroidWebViewPlatform) {
        return (controller.platform as AndroidWebViewController).webViewIdentifier;
      } else if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        return (controller.platform as WebKitWebViewController).webViewIdentifier;
      } else {
        throw UnsupportedError('This method only supports Android and iOS.');
      }
    }

    return _channel.invokeMethod('registerWebViewFlutter', <dynamic, dynamic>{
      'webViewId': webViewIdentifier(controller),
    });
  }
}

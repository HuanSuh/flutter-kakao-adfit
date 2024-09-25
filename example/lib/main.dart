import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_adfit/flutter_adfit.dart';

import 'webview/inapp_webview_page.dart';
import 'webview/webview_flutter_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AdFit example app')),
        body: Column(
          children: [
            AdFitBanner(
              adId: Platform.isIOS
                  ? '<IOS_AD_ID>'
                  : Platform.isAndroid
                      ? '<ANDROID_AD_ID>'
                      : '',
              adSize: AdFitBannerSize.BANNER,
              listener: (AdFitEvent event, AdFitEventData data) {
                print('$event, $data');
                switch (event) {
                  case AdFitEvent.AdReceived:
                    break;
                  case AdFitEvent.AdClicked:
                    break;
                  case AdFitEvent.AdReceiveFailed:
                    break;
                  case AdFitEvent.OnError:
                    break;
                }
              },
            ),
            _WebViewEntry(),
          ],
        ),
      ),
    );
  }
}

class _WebViewEntry extends StatelessWidget {
  const _WebViewEntry();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          FilledButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => InAppWebViewPage())),
            child: Text('InAppWebView'),
          ),
          const SizedBox(width: 16),
          FilledButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => WebViewFlutterPage())),
            child: Text('WebViewFlutter'),
          ),
        ],
      ),
    );
  }
}

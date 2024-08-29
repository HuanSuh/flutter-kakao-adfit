import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_adfit/flutter_adfit.dart';

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
        appBar: AppBar(title: const Text('AdFit example app'), elevation: 1),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: double.infinity),
              // AdFitBanner(
              //   adId: Platform.isIOS
              //       ? 'DAN-DqeMUOeGq61IAM9W'
              //       : Platform.isAndroid
              //           ? 'DAN-iw2qYFS5yQQWk0DF'
              //           : '',
              //   adSize: AdFitBannerSize.BANNER,
              //   listener: (event, data) => _listener(event, data, 'BANNER'),
              // ),
              const SizedBox(height: 16),
              AdfitBizBoardBanner(
                adId: Platform.isIOS
                    ? 'DAN-DqeMUOeGq61IAM9W'
                    : Platform.isAndroid
                        ? 'DAN-gmtNhb8XIbY2mJte'
                        : '',
                listener: (event, data) => _listener(event, data, 'NATIVE_BIZBOARD'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _listener(AdFitEvent event, AdFitEventData data, String adType) {
    print('[$adType] $event, $data');
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
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_adfit/flutter_adfit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

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
        body: Center(
          child: AdFitBanner(
            iosAdId: "<IOS_AD_ID>",
            androidAdId: "<ANDROID_AD_ID>",
            adSize: AdFitBannerSize.BANNER,
            fillParent: true,
            listener: (event, data) {
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
        ),
      ),
    );
  }
}

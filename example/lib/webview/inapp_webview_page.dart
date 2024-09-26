import 'package:flutter/material.dart';
import 'package:flutter_adfit/flutter_adfit.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'sample_web_page.dart';

class InAppWebViewPage extends StatefulWidget {
  InAppWebViewPage({super.key});

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  final InAppWebViewKeepAlive _keepAlive = InAppWebViewKeepAlive();

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: InAppWebView(
        keepAlive: _keepAlive,
        onConsoleMessage: (controller, consoleMessage) {
          print(consoleMessage);
        },
        onWebViewCreated: (controller) {
          FlutterAdFit.instance.registerInAppWebView(controller).catchError((e) {
            print(e);
          });
          SampleWebPage.build().then((uri) {
            controller.loadUrl(urlRequest: URLRequest(url: WebUri.uri(uri)));
          });
        },
      ),
    );
  }
}

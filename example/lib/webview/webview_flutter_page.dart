import 'package:flutter/material.dart';
import 'package:flutter_adfit/flutter_adfit.dart';
import 'package:flutter_adfit_example/webview/sample_web_page.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewFlutterPage extends StatefulWidget {
  WebViewFlutterPage({super.key});

  @override
  State<WebViewFlutterPage> createState() => _WebViewFlutterPageState();
}

class _WebViewFlutterPageState extends State<WebViewFlutterPage> {
  final WebViewController _controller = WebViewController();

  @override
  void initState() {
    super.initState();
    SampleWebPage.build().then((uri) {
      _controller.loadFile(uri.toFilePath());
    });
    FlutterAdFit.instance.registerWebViewFlutter(_controller).catchError((e) {
      print(e);
    });
    _controller.setOnConsoleMessage((msg) {
      print(msg);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }
}

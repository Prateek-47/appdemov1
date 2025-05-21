import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Bufkes extends StatefulWidget {
  @override
  _Bufkes createState() => _Bufkes();
}

class _Bufkes extends State<Bufkes> {
  final WebViewController _webViewController = WebViewController();

  @override
  void initState() {
    super.initState();

    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('http://comics-strips.s3-website-us-east-1.amazonaws.com/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       // Replace with your sidebar widget
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Bufkes (Tiel)'),
      ),
      body: WebViewWidget(
        controller: _webViewController,
      ),
    );
  }
}

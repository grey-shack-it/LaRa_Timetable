import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';

class KakaoAddressSearch extends StatefulWidget {
  const KakaoAddressSearch({super.key});

  @override
  State<KakaoAddressSearch> createState() => _KakaoAddressSearchState();
}

class _KakaoAddressSearchState extends State<KakaoAddressSearch> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            debugPrint('페이지 로드 완료: $url');
          },
          onWebResourceError: (error) {
            debugPrint('웹뷰 오류: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'AddressChannel',
        onMessageReceived: (message) {
          Get.back(result: message.message);
        },
      )
      ..loadHtmlString(_buildHtml(), baseUrl: 'https://t1.daumcdn.net');
  }

  String _buildHtml() {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
  <style>
    * { margin: 0; padding: 0; }
    html, body { width: 100%; height: 100%; }
    #wrap { width: 100%; height: 100vh; }
  </style>
</head>
<body>
  <div id="wrap"></div>
  <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
  <script>
    window.onload = function() {
      new daum.Postcode({
        oncomplete: function(data) {
          var result = JSON.stringify({
            address_full: data.roadAddress || data.jibunAddress,
            address_sido: data.sido,
            address_sigungu: data.sigungu,
            address_dong: data.bname
          });
          AddressChannel.postMessage(result);
        },
        width: "100%",
        height: "100%"
      }).embed(document.getElementById("wrap"));
    };
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightPurple,
      appBar: AppBar(
        backgroundColor: AppColors.lightPurple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkPurple),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '주소 검색',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: AppColors.darkPurple,
          ),
        ),
        centerTitle: true,
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}

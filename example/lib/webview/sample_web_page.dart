import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class SampleWebPage {
  static String buildData() {
    return """
<ins class="kakao_ad_area" style="display:none;width:100%;"  
data-ad-unit="AD-ID" 
data-ad-width="250" 
data-ad-height="200" 
data-ad-onfail="callBackFunc"></ins>
<script type="text/javascript" src="https://t1.daumcdn.net/kas/static/ba.min.js" async></script>
""";
  }

  static Future<Uri> build() async {
    return _generateUri(htmlBody: buildData());
  }

  static Future<Uri> _generateUri({
    required String htmlBody,
  }) async {
    final tempDir = await getTemporaryDirectory();

    final htmlPath = join(tempDir.path, 'page.html');

    final data = """
<!doctype html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta http-equiv="X-UA-Compatible" content="ie=edge">
        <script async src="http://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js"></script>
        <script type="text/javascript">
        function callBackFunc(elm) {
            console.log('callBackFunc');
        }  
        </script>
    </head>
    <body>
          $htmlBody
    </body>
</html>
""";

    File(htmlPath).writeAsStringSync(data);
    return Uri(scheme: 'file', path: htmlPath);
  }
}

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

Future<bool> downloadKeyFile(String fileName, String content) async {
  try {
    final blob = html.Blob([content], 'application/octet-stream');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..style.display = 'none';
    html.document.body!.children.add(anchor);
    anchor.click();
    html.document.body!.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
    return true;
  } catch (e) {
    return false;
  }
}

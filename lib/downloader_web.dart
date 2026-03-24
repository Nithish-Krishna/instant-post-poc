import 'package:flutter/services.dart';
import 'dart:html' as html;

void downloadImage(String url, String fileName) {
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..setAttribute('target', '_blank')
    ..click();
}

Future<void> downloadAsset(String assetPath, String fileName) async {
  try {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
      
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error downloading asset: $e');
  }
}

Future<void> downloadBytes(Uint8List bytes, String fileName) async {
  try {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
      
    html.Url.revokeObjectUrl(url);
  } catch (e) {
    print('Error downloading bytes: $e');
  }
}

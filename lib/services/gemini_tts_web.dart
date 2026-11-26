import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

class GeminiHttpResult {
  const GeminiHttpResult(this.statusCode, this.body);

  final int statusCode;
  final String body;
}

Future<GeminiHttpResult> postGeminiJson(
  String url,
  String jsonBody, {
  required Duration timeout,
}) async {
  final headers = web.Headers();
  headers.append('Content-Type', 'application/json');
  final init = web.RequestInit(
    method: 'POST',
    headers: headers,
    body: jsonBody.toJS,
  );
  final response = await web.window
      .fetch(url.toJS, init)
      .toDart
      .timeout(timeout);
  final text = (await response.text().toDart.timeout(timeout)).toDart;
  return GeminiHttpResult(response.status, text);
}

Future<bool> verifyCachedSourceExists(String uriOrPath, bool isFile) async {
  return true;
}

Future<String?> readDiskCachedAudio(String hash) async {
  return null;
}

Future<({String uriOrPath, bool isFile})> saveCachedAudio(
  String hash,
  Uint8List wavBytes,
) async {
  return (
    uriOrPath: Uri.dataFromBytes(wavBytes, mimeType: 'audio/wav').toString(),
    isFile: false,
  );
}

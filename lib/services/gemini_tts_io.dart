import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

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
  final client = HttpClient()..connectionTimeout = timeout;
  try {
    final request = await client.postUrl(Uri.parse(url)).timeout(timeout);
    request.headers.contentType = ContentType.json;
    request.add(utf8.encode(jsonBody));
    final response = await request.close().timeout(timeout);
    final body = await utf8.decoder.bind(response).join().timeout(timeout);
    return GeminiHttpResult(response.statusCode, body);
  } finally {
    client.close(force: true);
  }
}

Future<bool> verifyCachedSourceExists(String uriOrPath, bool isFile) async {
  if (!isFile) return true;
  final file = File(uriOrPath);
  return file.existsSync() && file.lengthSync() > 44;
}

Future<String?> readDiskCachedAudio(String hash) async {
  final file = File('${Directory.systemTemp.path}/gendhis_tts_$hash.wav');
  if (file.existsSync() && file.lengthSync() > 44) {
    return file.path;
  }
  return null;
}

Future<({String uriOrPath, bool isFile})> saveCachedAudio(
  String hash,
  Uint8List wavBytes,
) async {
  final file = File('${Directory.systemTemp.path}/gendhis_tts_$hash.wav');
  await file.writeAsBytes(wavBytes, flush: true);
  return (uriOrPath: file.path, isFile: true);
}

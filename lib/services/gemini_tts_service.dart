import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:jawakarsa/services/network_service.dart';
import 'gemini_tts_io.dart' if (dart.library.js_interop) 'gemini_tts_web.dart';

enum AudioSourceKind { asset, file, url }

class PlayableAudioSource {
  const PlayableAudioSource({required this.uriOrPath, required this.kind});

  final String uriOrPath;
  final AudioSourceKind kind;

  bool get isFile => kind == AudioSourceKind.file;
}

class GeminiTtsConfigException implements Exception {
  const GeminiTtsConfigException([
    this.message = 'Kunci suara AI belum terpasang pada aplikasi ini.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class GeminiRateLimitException implements Exception {
  const GeminiRateLimitException([
    this.message =
        'Kuota suara AI penuh sementara. Tunggu sekitar 1 menit lalu coba lagi.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class GeminiTtsException implements Exception {
  const GeminiTtsException([
    this.message = 'Suara AI sedang sibuk. Coba lagi sebentar.',
  ]);

  final String message;

  @override
  String toString() => message;
}

class GeminiTtsService {
  GeminiTtsService._();

  static final GeminiTtsService instance = GeminiTtsService._();

  static const String _compileTimeApiKeysRaw = String.fromEnvironment(
    'GEMINI_API_KEYS',
  );
  static const String _compileTimeSingleApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
  );

  static const List<String> modelOrder = [
    'gemini-3.1-flash-tts-preview',
    'gemini-3.8-flash-tts',
    'gemini-2.5-flash-preview-tts',
  ];

  static const Map<String, String> bundledPresetAssets = {
    'penjelajah': 'assets/audio/presets/preset_penjelajah.mp3',
    'jawakarsa': 'assets/audio/presets/preset_jawakarsa.mp3',
    'bagaskara': 'assets/audio/presets/preset_bagaskara.mp3',
    'gendhis ayu': 'assets/audio/presets/preset_gendhis_ayu.mp3',
    'nusantara jaya': 'assets/audio/presets/preset_nusantara_jaya.mp3',
  };

  static const String voiceName = 'Aoede';
  static const int _maxMemoryCacheEntries = 40;
  static const Duration _rateLimitCooldown = Duration(seconds: 65);
  static const Duration _authErrorCooldown = Duration(minutes: 10);

  @visibleForTesting
  List<String>? debugApiKeysOverride;

  @visibleForTesting
  String? debugApiKeyOverride;

  @visibleForTesting
  Future<Uint8List> Function(String spokenText)? debugSynthesizerOverride;

  @visibleForTesting
  Future<GeminiHttpResult> Function(
    String url,
    String jsonBody,
    Duration timeout,
  )?
  debugPostJsonOverride;

  @visibleForTesting
  DateTime Function()? debugClock;

  final LinkedHashMap<String, PlayableAudioSource> _memoryCache =
      LinkedHashMap<String, PlayableAudioSource>();
  final Map<String, DateTime> _slotCooldownUntil = <String, DateTime>{};
  int _nextKeyIndex = 0;

  static String normalizeKey(String text) {
    return text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String? bundledPresetAssetFor(String text) {
    return bundledPresetAssets[normalizeKey(text)];
  }

  static List<String> parseApiKeys(String multiRaw, [String singleRaw = '']) {
    final seen = <String>{};
    final keys = <String>[];
    void addToken(String token) {
      final cleaned = token.trim();
      if (cleaned.isNotEmpty && seen.add(cleaned)) {
        keys.add(cleaned);
      }
    }

    for (final part in multiRaw.split(RegExp(r'[,;\s]+'))) {
      addToken(part);
    }
    addToken(singleRaw);
    return keys;
  }

  static String hashKey(String normalized) {
    int hash = 0x811c9dc5;
    for (final unit in utf8.encode(normalized)) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }

  static String formatSpokenPrompt(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.endsWith('.') ||
        trimmed.endsWith('!') ||
        trimmed.endsWith('?')) {
      return trimmed;
    }
    return '$trimmed.';
  }

  static Uint8List ensureWavBytes(Uint8List rawBytes, String mimeType) {
    final lowerMime = mimeType.toLowerCase();
    final hasRiffHeader =
        rawBytes.length >= 12 &&
        rawBytes[0] == 0x52 &&
        rawBytes[1] == 0x49 &&
        rawBytes[2] == 0x46 &&
        rawBytes[3] == 0x46 &&
        rawBytes[8] == 0x57 &&
        rawBytes[9] == 0x41 &&
        rawBytes[10] == 0x56 &&
        rawBytes[11] == 0x45;
    if (lowerMime.contains('wav') && hasRiffHeader) {
      return rawBytes;
    }

    final rateMatch = RegExp(r'rate=(\d+)').firstMatch(lowerMime);
    final sampleRate = rateMatch != null
        ? (int.tryParse(rateMatch.group(1)!) ?? 24000)
        : 24000;
    final channelsMatch = RegExp(r'channels=(\d+)').firstMatch(lowerMime);
    final channels = channelsMatch != null
        ? (int.tryParse(channelsMatch.group(1)!) ?? 1)
        : 1;

    final pcmBytes = rawBytes.length.isOdd
        ? rawBytes.sublist(0, rawBytes.length - 1)
        : rawBytes;
    final pcmLength = pcmBytes.length;
    const bitsPerSample = 16;
    final byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
    final blockAlign = channels * (bitsPerSample ~/ 8);

    final header = ByteData(44);
    header.setUint32(0, 0x46464952, Endian.little);
    header.setUint32(4, 36 + pcmLength, Endian.little);
    header.setUint32(8, 0x45564157, Endian.little);
    header.setUint32(12, 0x20746d66, Endian.little);
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitsPerSample, Endian.little);
    header.setUint32(36, 0x61746164, Endian.little);
    header.setUint32(40, pcmLength, Endian.little);

    final result = Uint8List(44 + pcmLength);
    result.setRange(0, 44, header.buffer.asUint8List());
    result.setRange(44, 44 + pcmLength, pcmBytes);
    return result;
  }

  static Uint8List? extractWavFromGeminiResponse(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map<String, dynamic>) return null;
    final candidates = decoded['candidates'];
    if (candidates is! List) return null;

    for (final candidate in candidates) {
      if (candidate is! Map<String, dynamic>) continue;
      final content = candidate['content'];
      if (content is! Map<String, dynamic>) continue;
      final parts = content['parts'];
      if (parts is! List) continue;
      for (final part in parts) {
        if (part is! Map<String, dynamic>) continue;
        final inlineData = part['inlineData'];
        if (inlineData is! Map<String, dynamic>) continue;
        final data = inlineData['data'];
        if (data is! String || data.isEmpty) continue;
        final mimeType =
            inlineData['mimeType'] as String? ??
            'audio/l16; rate=24000; channels=1';
        final raw = base64Decode(data);
        final wav = ensureWavBytes(raw, mimeType);
        if (wav.length > 44) return wav;
      }
    }
    return null;
  }

  void _storeInMemoryCache(String key, PlayableAudioSource source) {
    _memoryCache.remove(key);
    _memoryCache[key] = source;
    while (_memoryCache.length > _maxMemoryCacheEntries) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
  }

  List<String> _resolveApiKeys() {
    if (debugApiKeysOverride != null) {
      return debugApiKeysOverride!
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (debugApiKeyOverride != null) {
      return parseApiKeys(debugApiKeyOverride!);
    }
    return parseApiKeys(_compileTimeApiKeysRaw, _compileTimeSingleApiKey);
  }

  Future<PlayableAudioSource> synthesizeToPlayableSource(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) {
      throw const GeminiTtsException('Teks kosong.');
    }

    final key = normalizeKey(clean);
    final presetAsset = bundledPresetAssets[key];
    if (presetAsset != null) {
      return PlayableAudioSource(
        uriOrPath: presetAsset,
        kind: AudioSourceKind.asset,
      );
    }

    final cached = _memoryCache[key];
    if (cached != null &&
        await verifyCachedSourceExists(cached.uriOrPath, cached.isFile)) {
      _storeInMemoryCache(key, cached);
      return cached;
    }
    _memoryCache.remove(key);

    final hash = hashKey(key);
    final diskPath = await readDiskCachedAudio(hash);
    if (diskPath != null) {
      final diskSource = PlayableAudioSource(
        uriOrPath: diskPath,
        kind: AudioSourceKind.file,
      );
      _storeInMemoryCache(key, diskSource);
      return diskSource;
    }

    final online = await NetworkService.instance.hasInternet();
    if (!online) {
      throw const NoInternetException();
    }

    final spokenPrompt = formatSpokenPrompt(clean);
    final Uint8List wavBytes;
    if (debugSynthesizerOverride != null) {
      wavBytes = await debugSynthesizerOverride!(spokenPrompt);
    } else {
      final apiKeys = _resolveApiKeys();
      if (apiKeys.isEmpty) {
        throw const GeminiTtsConfigException();
      }
      wavBytes = await _requestGeminiAudio(spokenPrompt, apiKeys);
    }

    final saved = await saveCachedAudio(hash, wavBytes);
    final source = PlayableAudioSource(
      uriOrPath: saved.uriOrPath,
      kind: saved.isFile ? AudioSourceKind.file : AudioSourceKind.url,
    );
    _storeInMemoryCache(key, source);
    return source;
  }

  Future<Uint8List> _requestGeminiAudio(
    String spokenText,
    List<String> apiKeys,
  ) async {
    final payload = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': spokenText},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.4,
        'responseModalities': ['AUDIO'],
        'speechConfig': {
          'voiceConfig': {
            'prebuiltVoiceConfig': {'voiceName': voiceName},
          },
        },
      },
    });

    final now = (debugClock ?? DateTime.now)();
    final startKeyIdx = _nextKeyIndex % apiKeys.length;
    bool sawRateLimit = false;
    bool sawTimeout = false;
    bool attemptedAny = false;

    for (final model in modelOrder) {
      for (int offset = 0; offset < apiKeys.length; offset++) {
        final keyIdx = (startKeyIdx + offset) % apiKeys.length;
        final slotId = '$keyIdx:$model';
        final keyBlockId = '$keyIdx:*';

        final keyBlockedUntil = _slotCooldownUntil[keyBlockId];
        if (keyBlockedUntil != null && keyBlockedUntil.isAfter(now)) {
          continue;
        }
        final slotBlockedUntil = _slotCooldownUntil[slotId];
        if (slotBlockedUntil != null && slotBlockedUntil.isAfter(now)) {
          sawRateLimit = true;
          continue;
        }

        attemptedAny = true;
        final apiKey = apiKeys[keyIdx];
        final url =
            'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey';

        try {
          const timeout = Duration(seconds: 18);
          final result = debugPostJsonOverride != null
              ? await debugPostJsonOverride!(url, payload, timeout)
              : await postGeminiJson(url, payload, timeout: timeout);

          if (result.statusCode == 200) {
            final wav = extractWavFromGeminiResponse(result.body);
            if (wav != null && wav.length > 44) {
              _nextKeyIndex = (keyIdx + 1) % apiKeys.length;
              _slotCooldownUntil.remove(slotId);
              return wav;
            }
          } else if (result.statusCode == 429) {
            sawRateLimit = true;
            _slotCooldownUntil[slotId] = now.add(_rateLimitCooldown);
          } else if (result.statusCode == 401 || result.statusCode == 403) {
            _slotCooldownUntil[keyBlockId] = now.add(_authErrorCooldown);
          }
        } on TimeoutException {
          sawTimeout = true;
        } catch (_) {}
      }
    }

    if (sawRateLimit || !attemptedAny) {
      throw const GeminiRateLimitException();
    }
    if (sawTimeout) {
      throw TimeoutException('Gemini TTS timeout');
    }
    throw const GeminiTtsException(
      'Suara AI sedang sibuk. Coba lagi sebentar.',
    );
  }

  @visibleForTesting
  void resetForTest() {
    _memoryCache.clear();
    _slotCooldownUntil.clear();
    _nextKeyIndex = 0;
    debugApiKeysOverride = null;
    debugApiKeyOverride = null;
    debugSynthesizerOverride = null;
    debugPostJsonOverride = null;
    debugClock = null;
  }
}

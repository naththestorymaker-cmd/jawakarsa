import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:jawakarsa/services/gemini_tts_service.dart';
import 'package:jawakarsa/services/network_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GendhisVoiceService {
  GendhisVoiceService._();

  static final GendhisVoiceService instance = GendhisVoiceService._();
  static const _kMutedKey = 'gendhis_voice_muted';

  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);
  final ValueNotifier<String?> activeAsset = ValueNotifier<String?>(null);
  final ValueNotifier<bool> isMuted = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isSpeakingText = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isLoadingText = ValueNotifier<bool>(false);
  final ValueNotifier<String?> textSpeechError = ValueNotifier<String?>(null);

  @visibleForTesting
  bool debugDisableAudio = false;

  @visibleForTesting
  double debugLastVolume = 1.0;

  AudioPlayer? _player;
  StreamSubscription<PlayerState>? _stateSub;
  int _speechRequestId = 0;
  bool _isPlayingSpeech = false;

  AudioPlayer _ensurePlayer() {
    if (_player != null) return _player!;
    final player = AudioPlayer();
    _stateSub = player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_isPlayingSpeech) {
          _isPlayingSpeech = false;
          isSpeakingText.value = false;
        }
        isPlaying.value = false;
        activeAsset.value = null;
      } else if (!_isPlayingSpeech) {
        isPlaying.value = state.playing;
      }
    });
    _player = player;
    return player;
  }

  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isMuted.value = prefs.getBool(_kMutedKey) ?? false;
    } catch (_) {}
  }

  Future<void> playAsset(String assetPath, {bool ignoreMute = false}) async {
    await stopTextSpeech();

    final targetVolume = (isMuted.value && !ignoreMute) ? 0.0 : 1.0;
    debugLastVolume = targetVolume;

    if (debugDisableAudio) {
      activeAsset.value = assetPath;
      isPlaying.value = true;
      return;
    }

    try {
      final player = _ensurePlayer();
      await player.stop();
      _isPlayingSpeech = false;
      activeAsset.value = assetPath;
      isPlaying.value = true;
      await player.setAsset(assetPath);
      await player.setVolume(targetVolume);
      await player.play();
    } catch (_) {
      isPlaying.value = false;
      activeAsset.value = null;
    }
  }

  Future<void> stop() async {
    _speechRequestId++;
    _isPlayingSpeech = false;
    isPlaying.value = false;
    activeAsset.value = null;
    isLoadingText.value = false;
    isSpeakingText.value = false;
    if (debugDisableAudio) return;
    try {
      await _player?.stop();
    } catch (_) {}
  }

  Future<void> toggleMute() async {
    final nextMuted = !isMuted.value;
    isMuted.value = nextMuted;
    final targetVolume = nextMuted ? 0.0 : 1.0;
    debugLastVolume = targetVolume;

    if (!debugDisableAudio) {
      try {
        await _player?.setVolume(targetVolume);
      } catch (_) {}
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kMutedKey, nextMuted);
    } catch (_) {}
  }

  void clearTextSpeechError() {
    textSpeechError.value = null;
  }

  Future<void> speakText(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    await stop();
    final requestId = ++_speechRequestId;
    textSpeechError.value = null;

    if (debugDisableAudio) {
      final hasPreset =
          GeminiTtsService.bundledPresetAssetFor(cleanText) != null;
      if (!hasPreset && NetworkService.instance.isForcedOffline) {
        textSpeechError.value = const NoInternetException().message;
        return;
      }
      debugLastVolume = 1.0;
      isSpeakingText.value = true;
      return;
    }

    isLoadingText.value = true;
    try {
      final source = await GeminiTtsService.instance.synthesizeToPlayableSource(
        cleanText,
      );
      if (requestId != _speechRequestId) return;

      final player = _ensurePlayer();
      await player.stop();
      if (requestId != _speechRequestId) return;

      switch (source.kind) {
        case AudioSourceKind.asset:
          await player.setAsset(source.uriOrPath);
        case AudioSourceKind.file:
          await player.setFilePath(source.uriOrPath);
        case AudioSourceKind.url:
          await player.setUrl(source.uriOrPath);
      }
      if (requestId != _speechRequestId) return;

      debugLastVolume = 1.0;
      await player.setVolume(1.0);
      _isPlayingSpeech = true;
      isLoadingText.value = false;
      isSpeakingText.value = true;
      await player.play();
    } on NoInternetException catch (e) {
      if (requestId == _speechRequestId) {
        _isPlayingSpeech = false;
        isLoadingText.value = false;
        isSpeakingText.value = false;
        textSpeechError.value = e.message;
      }
    } on GeminiRateLimitException catch (e) {
      if (requestId == _speechRequestId) {
        _isPlayingSpeech = false;
        isLoadingText.value = false;
        isSpeakingText.value = false;
        textSpeechError.value = e.message;
      }
    } on TimeoutException {
      if (requestId == _speechRequestId) {
        _isPlayingSpeech = false;
        isLoadingText.value = false;
        isSpeakingText.value = false;
        textSpeechError.value =
            'Koneksi lambat. Ketuk lagi untuk mencoba ulang.';
      }
    } on GeminiTtsConfigException catch (e) {
      if (requestId == _speechRequestId) {
        _isPlayingSpeech = false;
        isLoadingText.value = false;
        isSpeakingText.value = false;
        textSpeechError.value = e.message;
      }
    } catch (_) {
      if (requestId == _speechRequestId) {
        _isPlayingSpeech = false;
        isLoadingText.value = false;
        isSpeakingText.value = false;
        textSpeechError.value = 'Suara AI sedang sibuk. Coba lagi sebentar.';
      }
    }
  }

  Future<void> stopTextSpeech() async {
    _speechRequestId++;
    isLoadingText.value = false;
    isSpeakingText.value = false;
    textSpeechError.value = null;
    if (!_isPlayingSpeech) return;
    _isPlayingSpeech = false;
    if (debugDisableAudio) return;
    try {
      await _player?.stop();
    } catch (_) {}
  }

  @visibleForTesting
  Future<void> disposeForTest() async {
    await _stateSub?.cancel();
    _stateSub = null;
    await _player?.dispose();
    _player = null;
    _speechRequestId = 0;
    _isPlayingSpeech = false;
    isPlaying.value = false;
    activeAsset.value = null;
    isMuted.value = false;
    isSpeakingText.value = false;
    isLoadingText.value = false;
    textSpeechError.value = null;
    debugLastVolume = 1.0;
  }
}

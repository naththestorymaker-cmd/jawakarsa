import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawakarsa/features/home/home_page.dart';
import 'package:jawakarsa/features/home/widgets/gendhis_tour_overlay.dart';
import 'package:jawakarsa/features/kawruh/models/aksara_model.dart';
import 'package:jawakarsa/features/kawruh/widgets/aksara_converter_section.dart';
import 'package:jawakarsa/features/kawruh/widgets/aksara_grid_section.dart';
import 'package:jawakarsa/services/gemini_tts_io.dart';
import 'package:jawakarsa/services/gemini_tts_service.dart';
import 'package:jawakarsa/services/gendhis_voice_service.dart';
import 'package:jawakarsa/services/network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NetworkService.instance.debugOverrideOnline = null;
    GeminiTtsService.instance.resetForTest();
    GendhisVoiceService.instance.debugDisableAudio = true;
    GendhisVoiceService.instance.isPlaying.value = false;
    GendhisVoiceService.instance.activeAsset.value = null;
    GendhisVoiceService.instance.isMuted.value = false;
    GendhisVoiceService.instance.isSpeakingText.value = false;
    GendhisVoiceService.instance.isLoadingText.value = false;
    GendhisVoiceService.instance.textSpeechError.value = null;
    GendhisVoiceService.instance.debugLastVolume = 1.0;
  });

  tearDown(() async {
    NetworkService.instance.debugOverrideOnline = null;
    GeminiTtsService.instance.resetForTest();
    await GendhisVoiceService.instance.disposeForTest();
    GendhisVoiceService.instance.debugDisableAudio = false;
  });

  group('Pre-generated Gemini TTS assets', () {
    test(
      'all 5 Tour Guide, 20 Kawruh, and 5 Preset MP3 assets exist and are non-empty',
      () {
        expect(gendhisTourSteps.length, 5);
        for (int i = 0; i < gendhisTourSteps.length; i++) {
          final step = gendhisTourSteps[i];
          expect(step.alignLeft, i.isEven);
          final f = File(step.audioAsset);
          expect(f.existsSync(), isTrue, reason: 'Missing ${step.audioAsset}');
          expect(
            f.lengthSync(),
            greaterThan(4000),
            reason: 'Asset too small: ${step.audioAsset}',
          );
        }

        expect(hanacarakaList.length, 20);
        for (final item in hanacarakaList) {
          final f = File(item.audioAssetPath);
          expect(
            f.existsSync(),
            isTrue,
            reason: 'Missing ${item.audioAssetPath}',
          );
          expect(
            f.lengthSync(),
            greaterThan(4000),
            reason: 'Asset too small: ${item.audioAssetPath}',
          );
        }

        expect(GeminiTtsService.bundledPresetAssets.length, 5);
        for (final assetPath in GeminiTtsService.bundledPresetAssets.values) {
          final f = File(assetPath);
          expect(f.existsSync(), isTrue, reason: 'Missing $assetPath');
          expect(
            f.lengthSync(),
            greaterThan(2000),
            reason: 'Preset asset too small: $assetPath',
          );
        }
      },
    );
  });

  group('GeminiTtsService WAV header, presets, failover & local cache', () {
    test(
      'parseApiKeys parses comma/whitespace separated keys cleanly without duplicates',
      () {
        expect(
          GeminiTtsService.parseApiKeys(' key1, key2 ; key1 \n key3 ', 'key2'),
          ['key1', 'key2', 'key3'],
        );
        expect(GeminiTtsService.parseApiKeys('', 'onlyKey'), ['onlyKey']);
        expect(GeminiTtsService.parseApiKeys(''), isEmpty);
      },
    );

    test(
      'ensureWavBytes wraps raw L16 PCM with 44-byte RIFF header and leaves WAV untouched',
      () {
        final rawPcm = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
        final wrapped = GeminiTtsService.ensureWavBytes(
          rawPcm,
          'audio/l16; rate=24000; channels=1',
        );
        expect(wrapped.length, 44 + rawPcm.length);
        expect(String.fromCharCodes(wrapped.sublist(0, 4)), 'RIFF');
        expect(String.fromCharCodes(wrapped.sublist(8, 12)), 'WAVE');
        expect(String.fromCharCodes(wrapped.sublist(12, 16)), 'fmt ');
        expect(String.fromCharCodes(wrapped.sublist(36, 40)), 'data');
        final bd = ByteData.sublistView(wrapped);
        expect(bd.getUint32(24, Endian.little), 24000);
        expect(bd.getUint32(40, Endian.little), rawPcm.length);

        final unchanged = GeminiTtsService.ensureWavBytes(wrapped, 'audio/wav');
        expect(identical(unchanged, wrapped), isTrue);
      },
    );

    test(
      'bundled preset words play from offline local asset without HTTP calls',
      () async {
        NetworkService.instance.debugOverrideOnline = false;
        int httpCalls = 0;
        GeminiTtsService.instance.debugPostJsonOverride = (_, _, _) async {
          httpCalls++;
          return const GeminiHttpResult(500, '{}');
        };

        final source = await GeminiTtsService.instance
            .synthesizeToPlayableSource('  bagaskara  ');
        expect(source.kind, AudioSourceKind.asset);
        expect(source.uriOrPath, 'assets/audio/presets/preset_bagaskara.mp3');
        expect(httpCalls, 0);
      },
    );

    test(
      'multi-key failover skips 429 cooldown keys, rotates round-robin, and throws GeminiRateLimitException when all exhausted',
      () async {
        final validPcmBase64 = base64Encode(List<int>.filled(64, 9));
        final successBody = jsonEncode({
          'candidates': [
            {
              'content': {
                'parts': [
                  {
                    'inlineData': {
                      'mimeType': 'audio/l16; rate=24000; channels=1',
                      'data': validPcmBase64,
                    },
                  },
                ],
              },
            },
          ],
        });

        final words = [
          'Failover Word Satu',
          'Failover Word Dua',
          'Failover Word Tiga',
          'Failover Word Empat',
        ];
        for (final w in words) {
          final h = GeminiTtsService.hashKey(GeminiTtsService.normalizeKey(w));
          final f = File('${Directory.systemTemp.path}/gendhis_tts_$h.wav');
          if (f.existsSync()) f.deleteSync();
          addTearDown(() {
            if (f.existsSync()) f.deleteSync();
          });
        }

        final calledKeys = <String>[];
        NetworkService.instance.debugOverrideOnline = true;
        GeminiTtsService.instance.debugClock = () => DateTime(2026, 11, 27, 0);
        GeminiTtsService.instance.debugApiKeysOverride = ['k1', 'k2', 'k3'];
        GeminiTtsService.instance.debugPostJsonOverride = (url, _, _) async {
          final key = Uri.parse(url).queryParameters['key']!;
          calledKeys.add(key);
          if (key == 'k1') {
            return const GeminiHttpResult(429, '{}');
          }
          return GeminiHttpResult(200, successBody);
        };

        await GeminiTtsService.instance.synthesizeToPlayableSource(words[0]);
        expect(calledKeys, ['k1', 'k2']);

        calledKeys.clear();
        await GeminiTtsService.instance.synthesizeToPlayableSource(words[1]);
        expect(calledKeys, ['k3']);

        calledKeys.clear();
        await GeminiTtsService.instance.synthesizeToPlayableSource(words[2]);
        expect(calledKeys, ['k2']);

        GeminiTtsService.instance.debugPostJsonOverride = (_, _, _) async {
          return const GeminiHttpResult(429, '{}');
        };
        await expectLater(
          GeminiTtsService.instance.synthesizeToPlayableSource(words[3]),
          throwsA(isA<GeminiRateLimitException>()),
        );
      },
    );

    test(
      'synthesizeToPlayableSource caches locally and serves cached file even when offline',
      () async {
        const sampleWord = 'Test Cache Gendhis Surakarta';
        final hash = GeminiTtsService.hashKey(
          GeminiTtsService.normalizeKey(sampleWord),
        );
        final cacheFile = File(
          '${Directory.systemTemp.path}/gendhis_tts_$hash.wav',
        );
        if (cacheFile.existsSync()) cacheFile.deleteSync();
        addTearDown(() {
          if (cacheFile.existsSync()) cacheFile.deleteSync();
        });

        int synthesizerCalls = 0;
        NetworkService.instance.debugOverrideOnline = true;
        GeminiTtsService.instance.debugSynthesizerOverride = (spoken) async {
          synthesizerCalls++;
          expect(spoken, '$sampleWord.');
          return GeminiTtsService.ensureWavBytes(
            Uint8List.fromList(List<int>.filled(64, 7)),
            'audio/l16; rate=24000; channels=1',
          );
        };

        final first = await GeminiTtsService.instance
            .synthesizeToPlayableSource(sampleWord);
        expect(first.isFile, isTrue);
        expect(synthesizerCalls, 1);

        NetworkService.instance.debugOverrideOnline = false;
        final second = await GeminiTtsService.instance
            .synthesizeToPlayableSource('  test  cache gendhis surakarta ');
        expect(second.uriOrPath, first.uriOrPath);
        expect(synthesizerCalls, 1);
      },
    );

    test(
      'uncached synthesizeToPlayableSource throws NoInternetException when offline',
      () async {
        const uncachedWord = 'Uncached Offline Word Test';
        final hash = GeminiTtsService.hashKey(
          GeminiTtsService.normalizeKey(uncachedWord),
        );
        final cacheFile = File(
          '${Directory.systemTemp.path}/gendhis_tts_$hash.wav',
        );
        if (cacheFile.existsSync()) cacheFile.deleteSync();

        NetworkService.instance.debugOverrideOnline = false;
        await expectLater(
          GeminiTtsService.instance.synthesizeToPlayableSource(uncachedWord),
          throwsA(isA<NoInternetException>()),
        );
      },
    );
  });

  group('Gendhis Tour Guide choice prompt, mute volume & choreography', () {
    testWidgets(
      'first-time user can choose Eksplor Sendiri directly without playing audio',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(home: HomePage(userName: 'Adi')),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        expect(find.byType(GendhisTourOverlay), findsOneWidget);
        expect(find.text('Jelajah Bareng Gendhis?'), findsOneWidget);
        expect(find.text('Eksplor Sendiri'), findsOneWidget);
        expect(find.text('Ditemani Gendhis'), findsOneWidget);
        expect(GendhisVoiceService.instance.isPlaying.value, isFalse);

        await tester.tap(find.text('Eksplor Sendiri'));
        await tester.pumpAndSettle();

        expect(find.byType(GendhisTourOverlay), findsNothing);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('has_seen_gendhis_tour'), isTrue);
      },
    );

    testWidgets(
      'choosing Ditemani Gendhis alternates left/right, keeps playing silently when muted, and stays dismissed after finish',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(home: HomePage(userName: 'Adi')),
        );
        expect(find.byType(GendhisTourOverlay), findsNothing);

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();
        expect(find.byType(GendhisTourOverlay), findsOneWidget);
        expect(find.text('Jelajah Bareng Gendhis?'), findsOneWidget);

        await tester.tap(find.text('Ditemani Gendhis'));
        await tester.pump();

        expect(find.text('Gendhis berbicara...'), findsNothing);
        expect(find.text('Sugeng Rawuh di JawaKarsa!'), findsOneWidget);
        expect(find.byKey(const ValueKey<String>('left_0')), findsOneWidget);
        expect(
          GendhisVoiceService.instance.activeAsset.value,
          gendhisTourSteps[0].audioAsset,
        );
        expect(GendhisVoiceService.instance.isPlaying.value, isTrue);
        expect(GendhisVoiceService.instance.debugLastVolume, 1.0);

        await tester.tap(find.byIcon(Icons.volume_up_rounded));
        await tester.pump();
        expect(GendhisVoiceService.instance.isMuted.value, isTrue);
        expect(GendhisVoiceService.instance.isPlaying.value, isTrue);
        expect(GendhisVoiceService.instance.debugLastVolume, 0.0);

        await tester.tap(find.text('Lanjut'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.text('Jelajah & Pencarian Budaya'), findsOneWidget);
        expect(find.byKey(const ValueKey<String>('right_1')), findsOneWidget);
        expect(
          GendhisVoiceService.instance.activeAsset.value,
          gendhisTourSteps[1].audioAsset,
        );
        expect(GendhisVoiceService.instance.isPlaying.value, isTrue);
        expect(GendhisVoiceService.instance.debugLastVolume, 0.0);

        await tester.tap(find.byIcon(Icons.volume_off_rounded));
        await tester.pump();
        expect(GendhisVoiceService.instance.isMuted.value, isFalse);
        expect(GendhisVoiceService.instance.debugLastVolume, 1.0);

        await tester.tap(find.text('Lanjut'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.text('Belajar 20 Hanacaraka Bersuara'), findsOneWidget);
        expect(find.byKey(const ValueKey<String>('left_2')), findsOneWidget);

        await tester.tap(find.text('Lanjut'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.text('Eksplorasi Pulau Jawa'), findsOneWidget);
        expect(find.byKey(const ValueKey<String>('right_3')), findsOneWidget);

        await tester.tap(find.text('Lanjut'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        expect(find.text('Tiga Mini-Game Seru!'), findsOneWidget);
        expect(find.byKey(const ValueKey<String>('left_4')), findsOneWidget);

        await tester.tap(find.text('Mulai Jelajah!'));
        await tester.pumpAndSettle();
        expect(find.byType(GendhisTourOverlay), findsNothing);
        expect(GendhisVoiceService.instance.isPlaying.value, isFalse);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('has_seen_gendhis_tour'), isTrue);

        await tester.pumpWidget(
          const MaterialApp(
            home: HomePage(key: ValueKey('second'), userName: 'Adi'),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();
        expect(find.byType(GendhisTourOverlay), findsNothing);
      },
    );
  });

  group('Kawruh Voice AI & Converter Voice', () {
    testWidgets(
      'tapping Ha shows Dengarkan Pelafalan & Arti without overflow and toggles GendhisVoiceService',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: AksaraGridSection()),
            ),
          ),
        );
        await tester.pump();

        await tester.tap(find.text('ha'));
        await tester.pumpAndSettle();

        expect(find.text('Dengarkan Pelafalan & Arti'), findsOneWidget);

        await tester.tap(find.text('Dengarkan Pelafalan & Arti'));
        await tester.pump();
        expect(
          GendhisVoiceService.instance.activeAsset.value,
          hanacarakaList.first.audioAssetPath,
        );
        expect(
          find.text('Sedang Membacakan... (Ketuk untuk Henti)'),
          findsOneWidget,
        );

        await tester.tap(find.text('Sedang Membacakan... (Ketuk untuk Henti)'));
        await tester.pump();
        expect(GendhisVoiceService.instance.isPlaying.value, isFalse);
      },
    );

    testWidgets(
      'AksaraConverterSection starts empty, renders cleanly at 320x640, and toggles voice for preset even when offline',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        NetworkService.instance.debugOverrideOnline = false;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: AksaraConverterSection()),
            ),
          ),
        );
        await tester.pump();

        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.controller?.text, isEmpty);
        expect(find.text('꧋ ... ꧋'), findsOneWidget);
        expect(find.text('Bacakan dengan Suara Gendhis'), findsOneWidget);

        await tester.ensureVisible(find.text('Bacakan dengan Suara Gendhis'));
        await tester.tap(find.text('Bacakan dengan Suara Gendhis'));
        await tester.pump();
        expect(GendhisVoiceService.instance.isSpeakingText.value, isFalse);

        await tester.enterText(find.byType(TextField), 'Bagaskara');
        await tester.pump();

        await tester.ensureVisible(find.text('Bacakan dengan Suara Gendhis'));
        await tester.tap(find.text('Bacakan dengan Suara Gendhis'));
        await tester.pump();
        expect(GendhisVoiceService.instance.isSpeakingText.value, isTrue);
        expect(
          find.text('Sedang Membacakan... (Ketuk untuk Henti)'),
          findsOneWidget,
        );

        await tester.tap(find.text('Sedang Membacakan... (Ketuk untuk Henti)'));
        await tester.pump();
        expect(GendhisVoiceService.instance.isSpeakingText.value, isFalse);
      },
    );

    testWidgets(
      'AksaraConverterSection displays offline message cleanly for custom uncached text when offline',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        NetworkService.instance.debugOverrideOnline = false;

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: AksaraConverterSection()),
            ),
          ),
        );
        await tester.pump();

        await tester.enterText(find.byType(TextField), 'Yogyakarta');
        await tester.pump();

        await tester.ensureVisible(find.text('Bacakan dengan Suara Gendhis'));
        await tester.tap(find.text('Bacakan dengan Suara Gendhis'));
        await tester.pump();

        expect(GendhisVoiceService.instance.isSpeakingText.value, isFalse);
        expect(GendhisVoiceService.instance.isLoadingText.value, isFalse);
        expect(
          find.text(
            'Tidak ada koneksi internet. Aktifkan WiFi atau data seluler terlebih dahulu.',
          ),
          findsOneWidget,
        );
      },
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawakarsa/features/knowledge/widgets/instant_knowledge_card_sheet.dart';
import 'package:jawakarsa/features/knowledge/widgets/platform_network_image.dart';
import 'package:jawakarsa/features/personalization/personalization_screen.dart';
import 'package:jawakarsa/models/knowledge_item.dart';
import 'package:jawakarsa/services/auth_service.dart';
import 'package:jawakarsa/services/network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    NetworkService.instance.debugOverrideOnline = false;
  });

  tearDown(() {
    NetworkService.instance.debugOverrideOnline = null;
  });

  group('Offline detection and instant fallbacks', () {
    test(
      'AuthService.signInWithGoogle throws NoInternetException when offline',
      () async {
        await expectLater(
          AuthService.instance.signInWithGoogle(),
          throwsA(isA<NoInternetException>()),
        );
      },
    );

    test(
      'AuthService.signInAndSaveName succeeds offline with local UID',
      () async {
        final uid = await AuthService.instance.signInAndSaveName('Budi');
        expect(uid, isNotEmpty);
        expect(await AuthService.instance.getSavedName(), 'Budi');
      },
    );

    testWidgets('PlatformNetworkImage shows offline fallback immediately', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlatformNetworkImage(
              imageUrl: 'https://example.com/photo.webp',
              height: 200,
              onOpenExternal: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
      expect(find.text('Tidak ada koneksi internet'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('Mp3AudioContainer shows offline fallback immediately on tap', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Mp3AudioContainer(
              audioUrl: 'https://example.com/gamelan.mp3',
              accentColor: Colors.teal,
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();

      expect(find.text('Tidak ada koneksi internet'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
      'InstantKnowledgeCardSheet video shows offline state immediately',
      (tester) async {
        tester.view.physicalSize = const Size(390, 960);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final item = KnowledgeItem(
          id: 'test_video',
          title: 'Uji Video',
          category: 'SENI PERTUNJUKAN & SASTRA',
          thumbnailUrl: 'assets/carousel/wayang.webp',
          originRegion: 'Yogyakarta',
          overview:
              'Artikel uji untuk memverifikasi fallback offline pada pemutar video.',
          keyFacts: const [KnowledgeFact(key: 'Asal', value: 'Jawa Tengah')],
          relatedTopics: const [],
          media: const [
            KnowledgeMedia(
              type: 'video',
              url: 'https://example.com/sample.mp4',
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: InstantKnowledgeCardSheet(item: item)),
          ),
        );
        await tester.pump();

        final playVideo = find.text('Putar Video');
        await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
        await tester.pumpAndSettle();
        await tester.ensureVisible(playVideo);
        await tester.pump();
        await tester.tap(playVideo);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
        expect(
          find.textContaining('Tidak ada koneksi internet'),
          findsOneWidget,
        );
        expect(find.text('Coba Lagi'), findsOneWidget);
      },
    );

    testWidgets(
      'PersonalizationScreen Google button fails fast with offline error',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(home: PersonalizationScreen()),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Masuk dengan Google'));
        await tester.pumpAndSettle();

        expect(
          find.textContaining('Tidak ada koneksi internet'),
          findsOneWidget,
        );
        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });
}

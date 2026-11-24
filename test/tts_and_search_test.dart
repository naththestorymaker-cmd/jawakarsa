import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawakarsa/data/knowledge_data.dart';
import 'package:jawakarsa/features/dolanan/games/tts_jawa_game.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('KnowledgeData.search relevance', () {
    test('typing "k" returns K-prefix titles first and excludes Batik', () {
      final results = KnowledgeData.search('k');
      expect(results, isNotEmpty);
      expect(results.first.title.toLowerCase().startsWith('k'), isTrue);
      expect(
        results.any((e) => e.title.toLowerCase().contains('batik')),
        isFalse,
      );
    });

    test('typing "keris" ranks Keris & Tosan Aji first', () {
      final results = KnowledgeData.search('keris');
      expect(results, isNotEmpty);
      expect(results.first.title, 'Keris & Tosan Aji');
    });

    test(
      'typing "ba" matches Batik Parang Rusak without irrelevant overview hits',
      () {
        final results = KnowledgeData.search('ba');
        expect(results, isNotEmpty);
        expect(results.first.title, 'Batik Parang Rusak');
        expect(
          results.every(
            (e) =>
                e.title.toLowerCase().startsWith('ba') ||
                RegExp(r'(?:^|[^a-z0-9])ba').hasMatch(e.title.toLowerCase()),
          ),
          isTrue,
        );
      },
    );
  });

  group('TtsJawaGame puzzle integrity across all 5 puzzles', () {
    test(
      'all 5 puzzles have zero collisions, zero start overlaps, and are connected',
      () {
        final puzzles = TtsJawaGame.debugPuzzles;
        expect(puzzles.length, 5);

        for (int pIdx = 0; pIdx < puzzles.length; pIdx++) {
          final clues = puzzles[pIdx];
          final cellLetters = <String, String>{};
          final cellOwners = <String, List<int>>{};
          final startCells = <String>{};
          int maxCols = 0;

          for (int cIdx = 0; cIdx < clues.length; cIdx++) {
            final cl = clues[cIdx];
            final startKey = '${cl.row},${cl.col}';
            expect(
              startCells.add(startKey),
              isTrue,
              reason: 'Puzzle #$pIdx clue #$cIdx overlaps start cell $startKey',
            );

            for (int k = 0; k < cl.answer.length; k++) {
              final r = cl.direction ? cl.row : cl.row + k;
              final c = cl.direction ? cl.col + k : cl.col;
              maxCols = max(maxCols, c + 1);
              final key = '$r,$c';
              final ch = cl.answer[k];

              if (cellLetters.containsKey(key)) {
                expect(
                  cellLetters[key],
                  ch,
                  reason:
                      'Puzzle #$pIdx collision at ($r,$c): existing "${cellLetters[key]}" vs "$ch" (${cl.answer})',
                );
              } else {
                cellLetters[key] = ch;
              }
              cellOwners.putIfAbsent(key, () => []).add(cIdx);
            }
          }

          expect(
            maxCols,
            lessThanOrEqualTo(8),
            reason: 'Puzzle #$pIdx exceeds 8 columns ($maxCols)',
          );

          final adj = <int, Set<int>>{
            for (int i = 0; i < clues.length; i++) i: <int>{},
          };
          for (final owners in cellOwners.values) {
            if (owners.length > 1) {
              for (final a in owners) {
                for (final b in owners) {
                  if (a != b) adj[a]!.add(b);
                }
              }
            }
          }
          final visited = <int>{0};
          final queue = <int>[0];
          while (queue.isNotEmpty) {
            final cur = queue.removeLast();
            for (final nxt in adj[cur]!) {
              if (visited.add(nxt)) queue.add(nxt);
            }
          }
          expect(
            visited.length,
            clues.length,
            reason: 'Puzzle #$pIdx is not connected (visited=$visited)',
          );
        }
      },
    );
  });

  group('TtsJawaGame has zero overflow across all 5 puzzle variations', () {
    for (final viewport in const [Size(360, 800), Size(320, 640)]) {
      for (int idx = 0; idx < 5; idx++) {
        testWidgets(
          'puzzle #$idx fits cleanly at ${viewport.width.toInt()}x${viewport.height.toInt()}',
          (tester) async {
            tester.view.physicalSize = viewport;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(() {
              tester.view.resetPhysicalSize();
              tester.view.resetDevicePixelRatio();
            });

            final errors = <FlutterErrorDetails>[];
            final prevOnError = FlutterError.onError;
            FlutterError.onError = (details) => errors.add(details);
            addTearDown(() => FlutterError.onError = prevOnError);

            await tester.pumpWidget(
              MaterialApp(home: TtsJawaGame(initialPuzzleIndex: idx)),
            );
            await tester.pump();

            expect(
              errors,
              isEmpty,
              reason:
                  'Overflow or layout error on puzzle #$idx at $viewport: $errors',
            );
          },
        );
      }
    }
  });

  group('TtsJawaGame real-user gameplay simulation', () {
    for (int idx = 0; idx < 5; idx++) {
      testWidgets('real user solves puzzle #$idx end-to-end with 200 poin', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(home: TtsJawaGame(initialPuzzleIndex: idx)),
        );
        await tester.pump();

        final clues = TtsJawaGame.debugPuzzles[idx];
        expect(find.text('0 poin'), findsOneWidget);

        for (int i = 0; i < clues.length; i++) {
          final cl = clues[i];
          await tester.ensureVisible(find.textContaining(cl.clue));
          await tester.tap(find.textContaining(cl.clue));
          await tester.pump();

          await tester.enterText(find.byType(TextField), ' ${cl.answer}');
          await tester.pump();

          expect(find.text('${(i + 1) * 50} poin'), findsOneWidget);
          expect(find.text('Benar'), findsNWidgets(i + 1));
        }

        await tester.pump(const Duration(milliseconds: 900));
        await tester.pump();

        expect(find.text('TTS Selesai!'), findsOneWidget);
        expect(find.text('Total Skor: 200 poin'), findsOneWidget);
      });
    }

    testWidgets(
      'single-fire input, wrong-letter overwrite, locked-intersection backspace, anti-farming, and intersection toggle',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(home: TtsJawaGame(initialPuzzleIndex: 0)),
        );
        await tester.pump();

        final gridRect = tester.getRect(find.byType(ClipRRect));
        final intersectionTap = Offset(
          gridRect.left + 2.5 * (gridRect.width / 7),
          gridRect.top + 1.5 * (gridRect.height / 8),
        );

        await tester.tapAt(intersectionTap);
        await tester.pump();
        await tester.enterText(find.byType(TextField), ' W');
        await tester.pump();
        expect(find.text('W'), findsOneWidget);

        await tester.tapAt(intersectionTap);
        await tester.pump();
        await tester.enterText(find.byType(TextField), ' B');
        await tester.pump();
        expect(find.text('B'), findsOneWidget);

        await tester.enterText(find.byType(TextField), '');
        await tester.pump();
        expect(find.text('B'), findsNothing);

        await tester.tap(
          find.textContaining('Seni pertunjukan boneka kulit Jawa'),
        );
        await tester.pump();
        await tester.enterText(find.byType(TextField), ' Z');
        await tester.pump();
        expect(find.text('Z'), findsOneWidget);

        await tester.enterText(find.byType(TextField), ' AYANG');
        await tester.pump();
        expect(find.text('Z'), findsNothing);
        expect(find.text('50 poin'), findsOneWidget);

        await tester.tap(find.text('Hapus'));
        await tester.pump();
        await tester.enterText(find.byType(TextField), ' W');
        await tester.pump();
        expect(find.text('50 poin'), findsOneWidget);

        await tester.tap(
          find.textContaining('Kain bermotif khas Jawa dengan lilin'),
        );
        await tester.pump();
        await tester.enterText(find.byType(TextField), ' BT');
        await tester.pump();

        await tester.tap(find.text('Hapus'));
        await tester.pump();
        await tester.tap(find.text('Hapus'));
        await tester.pump();
        expect(find.text('B'), findsNothing);
        expect(find.text('T'), findsNothing);
        expect(find.text('A'), findsNWidgets(2));
      },
    );
  });
}

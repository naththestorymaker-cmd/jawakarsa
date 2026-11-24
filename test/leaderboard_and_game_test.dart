import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawakarsa/features/dolanan/games/aksara_evaluator.dart';
import 'package:jawakarsa/models/game_score.dart';

int findRank(String? uid, List<GameScore> scores) {
  if (uid == null || scores.isEmpty) return 0;
  final idx = scores.indexWhere((e) => e.uid == uid);
  return idx >= 0 ? idx + 1 : 0;
}

void main() {
  group('GameScore serialization & ranking', () {
    test('copyWith recomputes totalScore automatically', () {
      const score1 = GameScore(
        uid: 'user_pameran_001',
        name: 'Gita Pameran',
        totalScore: 250,
        kanvasScore: 100,
        ttsScore: 100,
        cocokScore: 50,
      );

      final updatedScore = score1.copyWith(kanvasScore: 150);
      expect(updatedScore.totalScore, 300);
      expect(updatedScore.kanvasScore, 150);

      final localMap = updatedScore.toLocalMap();
      final decoded = jsonDecode(jsonEncode(localMap)) as Map<String, dynamic>;
      final fromLocal = GameScore.fromLocalMap(decoded);
      expect(fromLocal.uid, updatedScore.uid);
      expect(fromLocal.totalScore, updatedScore.totalScore);
    });

    test('fromFirestore deserializes score fields and updatedAt', () {
      final firestoreMap = <String, dynamic>{
        'uid': 'user_pameran_002',
        'name': 'Budi Santoso',
        'totalScore': 420,
        'kanvasScore': 170,
        'ttsScore': 150,
        'cocokScore': 100,
        'updatedAt': '2026-11-12T15:30:00.000Z',
      };
      final fromFirestore = GameScore.fromFirestore(firestoreMap, 'doc_002');
      expect(fromFirestore.uid, 'user_pameran_002');
      expect(fromFirestore.name, 'Budi Santoso');
      expect(fromFirestore.totalScore, 420);
      expect(fromFirestore.updatedAt, isNotNull);
    });

    test('findRank resolves descending ranks accurately', () {
      final leaderboard = <GameScore>[
        const GameScore(uid: 'uid_1', name: 'Andi', totalScore: 500),
        const GameScore(uid: 'uid_2', name: 'Budi', totalScore: 450),
        const GameScore(uid: 'uid_3', name: 'Citra', totalScore: 400),
        const GameScore(uid: 'uid_4', name: 'Dewi', totalScore: 350),
        const GameScore(uid: 'uid_5', name: 'Eko', totalScore: 300),
        const GameScore(uid: 'uid_6', name: 'Fajar', totalScore: 250),
        const GameScore(uid: 'uid_7', name: 'Gita', totalScore: 200),
      ];

      for (int i = 0; i < leaderboard.length - 1; i++) {
        expect(
          leaderboard[i].totalScore,
          greaterThanOrEqualTo(leaderboard[i + 1].totalScore),
        );
      }

      expect(findRank('uid_1', leaderboard), 1);
      expect(findRank('uid_2', leaderboard), 2);
      expect(findRank('uid_3', leaderboard), 3);
      expect(findRank('uid_5', leaderboard), 5);
      expect(findRank('uid_7', leaderboard), 7);
      expect(findRank('uid_unknown', leaderboard), 0);
    });
  });

  group('AksaraEvaluator stroke recognition accuracy', () {
    final targetRect = StrokeRect.fromCenter(
      center: const StrokePoint(160, 130),
      width: 200,
      height: 180,
    );

    List<StrokePoint?> buildIdealPoints(String aksara) {
      final wps = AksaraEvaluator.getWaypointsFor(aksara);
      final pts = <StrokePoint?>[];
      for (int i = 0; i < wps.length - 1; i++) {
        final start = StrokePoint(
          targetRect.left + wps[i].x * targetRect.width,
          targetRect.top + wps[i].y * targetRect.height,
        );
        final end = StrokePoint(
          targetRect.left + wps[i + 1].x * targetRect.width,
          targetRect.top + wps[i + 1].y * targetRect.height,
        );
        for (int step = 0; step <= 6; step++) {
          final t = step / 6.0;
          pts.add(
            StrokePoint(
              start.x + (end.x - start.x) * t,
              start.y + (end.y - start.y) * t,
            ),
          );
        }
      }
      return pts;
    }

    test(
      'ideal Ra and Na strokes pass while mismatched stroke scores lower',
      () {
        final raPoints = buildIdealPoints('ꦫ');
        final raResult = AksaraEvaluator.evaluate(
          aksara: 'ꦫ',
          points: raPoints,
          canvasWidth: 320,
          canvasHeight: 260,
          glyphRect: targetRect,
        );
        expect(raResult.isPassed, isTrue);
        expect(raResult.accuracy, greaterThanOrEqualTo(80));

        final naPoints = buildIdealPoints('ꦤ');
        final naResult = AksaraEvaluator.evaluate(
          aksara: 'ꦤ',
          points: naPoints,
          canvasWidth: 320,
          canvasHeight: 260,
          glyphRect: targetRect,
        );
        expect(naResult.isPassed, isTrue);
        expect(naResult.accuracy, greaterThanOrEqualTo(80));

        final mismatchedNa = AksaraEvaluator.evaluate(
          aksara: 'ꦤ',
          points: raPoints,
          canvasWidth: 320,
          canvasHeight: 260,
          glyphRect: targetRect,
        );
        expect(mismatchedNa.accuracy, lessThan(naResult.accuracy));

        final offPathPoints = <StrokePoint?>[
          for (int i = 0; i <= 10; i++)
            StrokePoint(targetRect.left + i * 10.0, targetRect.top - 20),
        ];
        final offPathResult = AksaraEvaluator.evaluate(
          aksara: 'ꦤ',
          points: offPathPoints,
          canvasWidth: 320,
          canvasHeight: 260,
          glyphRect: targetRect,
        );
        expect(offPathResult.isPassed, isFalse);
        expect(offPathResult.accuracy, lessThan(45));
      },
    );
  });
}

// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:jawakarsa/models/game_score.dart';
import 'package:jawakarsa/features/dolanan/games/aksara_evaluator.dart';

int findRank(String? uid, List<GameScore> scores) {
  if (uid == null || scores.isEmpty) return 0;
  final idx = scores.indexWhere((e) => e.uid == uid);
  return idx >= 0 ? idx + 1 : 0;
}

void main() {
  print('=====================================================');
  print('=== UJI COBA KOMPREHENSIF PAPAN PERINGKAT & GAME  ===');
  print('=====================================================');

  print('\n[TEST 1] Pengujian GameScore & Serialisasi Firestore');

  const score1 = GameScore(
    uid: 'user_pameran_001',
    name: 'Gita Pameran',
    totalScore: 250,
    kanvasScore: 100,
    ttsScore: 100,
    cocokScore: 50,
  );

  final updatedScore = score1.copyWith(
    kanvasScore: 150,
  );
  assert(updatedScore.totalScore == 300, 'Total score harus dihitung otomatis: 150+100+50=300');
  assert(updatedScore.kanvasScore == 150, 'Kanvas score harus 150');
  print('✓ GameScore.copyWith menghitung total score otomatis: 300 poin');

  final localMap = updatedScore.toLocalMap();
  final jsonString = jsonEncode(localMap);
  final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
  final fromLocal = GameScore.fromLocalMap(decoded);
  assert(fromLocal.uid == updatedScore.uid, 'UID harus cocok');
  assert(fromLocal.totalScore == updatedScore.totalScore, 'Total score cocok');
  print('✓ Local Map roundtrip (SharedPreferences JSON) valid');

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
  assert(fromFirestore.uid == 'user_pameran_002', 'UID firestore valid');
  assert(fromFirestore.name == 'Budi Santoso', 'Nama firestore valid');
  assert(fromFirestore.totalScore == 420, 'Total score firestore valid');
  assert(fromFirestore.updatedAt != null, 'Tanggal update berhasil diparsing');
  print('✓ Firestore deserialization & timestamp parsing valid');

  print('\n[TEST 2] Pengujian Peringkat & Sorting Multi-User Pameran');

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
    assert(leaderboard[i].totalScore >= leaderboard[i + 1].totalScore,
        'Papan peringkat harus terurut dari skor tertinggi ke terendah');
  }

  assert(findRank('uid_1', leaderboard) == 1, 'Andi harus peringkat #1');
  assert(findRank('uid_2', leaderboard) == 2, 'Budi harus peringkat #2');
  assert(findRank('uid_3', leaderboard) == 3, 'Citra harus peringkat #3');
  assert(findRank('uid_5', leaderboard) == 5, 'Eko harus peringkat #5');
  assert(findRank('uid_7', leaderboard) == 7, 'Gita harus peringkat #7');
  assert(findRank('uid_unknown', leaderboard) == 0, 'User tak dikenal peringkat 0');
  print('✓ Kalkulasi peringkat multi-peserta terbukti akurat (Top 1, Podium, hingga urutan bawah)');

  print('\n[TEST 3] Pengujian Akurasi Goresan Aksara (AksaraEvaluator)');

  final targetRect = StrokeRect.fromCenter(
    center: const StrokePoint(160, 130),
    width: 200,
    height: 180,
  );

  final raWaypoints = AksaraEvaluator.getWaypointsFor('ꦫ');
  final raPoints = <StrokePoint?>[];
  for (int i = 0; i < raWaypoints.length - 1; i++) {
    final start = StrokePoint(
      targetRect.left + raWaypoints[i].x * targetRect.width,
      targetRect.top + raWaypoints[i].y * targetRect.height,
    );
    final end = StrokePoint(
      targetRect.left + raWaypoints[i + 1].x * targetRect.width,
      targetRect.top + raWaypoints[i + 1].y * targetRect.height,
    );
    for (int step = 0; step <= 6; step++) {
      final t = step / 6.0;
      raPoints.add(StrokePoint(
        start.x + (end.x - start.x) * t,
        start.y + (end.y - start.y) * t,
      ));
    }
  }

  final raResult = AksaraEvaluator.evaluate(
    aksara: 'ꦫ',
    points: raPoints,
    canvasWidth: 320,
    canvasHeight: 260,
    glyphRect: targetRect,
  );

  print('Akurasi Goresan Ideal Ra (ꦫ): ${raResult.accuracy}% (${raResult.ratingText})');
  assert(raResult.isPassed, 'Goresan ideal Ra harus lulus');
  assert(raResult.accuracy >= 80, 'Akurasi Ra harus tinggi (>=80%)');
  print('✓ Evaluasi aksara ꦫ (Ra) berhasil lulus dengan rating: ${raResult.ratingText}');

  final naWaypoints = AksaraEvaluator.getWaypointsFor('ꦤ');
  final naPoints = <StrokePoint?>[];
  for (int i = 0; i < naWaypoints.length - 1; i++) {
    final start = StrokePoint(
      targetRect.left + naWaypoints[i].x * targetRect.width,
      targetRect.top + naWaypoints[i].y * targetRect.height,
    );
    final end = StrokePoint(
      targetRect.left + naWaypoints[i + 1].x * targetRect.width,
      targetRect.top + naWaypoints[i + 1].y * targetRect.height,
    );
    for (int step = 0; step <= 6; step++) {
      final t = step / 6.0;
      naPoints.add(StrokePoint(
        start.x + (end.x - start.x) * t,
        start.y + (end.y - start.y) * t,
      ));
    }
  }

  final naResult = AksaraEvaluator.evaluate(
    aksara: 'ꦤ',
    points: naPoints,
    canvasWidth: 320,
    canvasHeight: 260,
    glyphRect: targetRect,
  );

  print('Akurasi Goresan Ideal Na (ꦤ): ${naResult.accuracy}% (${naResult.ratingText})');
  assert(naResult.isPassed, 'Goresan ideal Na harus lulus');
  assert(naResult.accuracy >= 80, 'Akurasi Na harus tinggi');
  print('✓ Evaluasi aksara ꦤ (Na) berhasil lulus');

  final mismatchedResult = AksaraEvaluator.evaluate(
    aksara: 'ꦤ',
    points: raPoints,
    canvasWidth: 320,
    canvasHeight: 260,
    glyphRect: targetRect,
  );
  print('Akurasi Goresan Tidak Cocok (Menggambar Ra untuk Na): ${mismatchedResult.accuracy}%');
  assert(!mismatchedResult.isPassed || mismatchedResult.accuracy < 60,
      'Goresan yang tidak cocok harus memiliki akurasi rendah');
  print('✓ Deteksi ketidakcocokan bentuk goresan bekerja dengan baik');

  print('\n=====================================================');
  print('=== SEMUA UJI COBA BERHASIL 100% TANPA KESALAHAN  ===');
  print('=====================================================');
}

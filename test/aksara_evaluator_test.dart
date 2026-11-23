// ignore_for_file: avoid_print

import 'package:jawakarsa/features/dolanan/games/aksara_evaluator.dart';

void main() {
  print('=== Menjalankan Uji Coba AksaraEvaluator (Pure Dart) ===');

  const canvasW = 350.0;
  const canvasH = 280.0;
  final targetRect = StrokeRect.fromCenter(
    center: const StrokePoint(175, 140),
    width: 200,
    height: 180,
  );

  const allAksara = [
    'ꦲ', 'ꦤ', 'ꦕ', 'ꦫ', 'ꦏ',
    'ꦢ', 'ꦠ', 'ꦱ', 'ꦮ', 'ꦭ',
    'ꦥ', 'ꦝ', 'ꦗ', 'ꦪ', 'ꦚ',
    'ꦩ', 'ꦒ', 'ꦧ', 'ꦛ', 'ꦔ',
  ];

  for (final a in allAksara) {
    final wps = AksaraEvaluator.getWaypointsFor(a);
    assert(wps.isNotEmpty, 'Aksara $a harus memiliki waypoints');
    assert(wps.length >= 5, 'Aksara $a memiliki minimal 5 waypoints');
  }
  print('✓ Seluruh 20 aksara Hanacaraka memiliki waypoints valid.');

  final haWaypoints = AksaraEvaluator.getWaypointsFor('ꦲ');
  final accuratePoints = <StrokePoint?>[];
  for (int i = 0; i < haWaypoints.length - 1; i++) {
    final start = StrokePoint(
      targetRect.left + haWaypoints[i].x * targetRect.width,
      targetRect.top + haWaypoints[i].y * targetRect.height,
    );
    final end = StrokePoint(
      targetRect.left + haWaypoints[i + 1].x * targetRect.width,
      targetRect.top + haWaypoints[i + 1].y * targetRect.height,
    );
    for (int step = 0; step <= 5; step++) {
      final t = step / 5.0;
      accuratePoints.add(StrokePoint(
        start.x + (end.x - start.x) * t,
        start.y + (end.y - start.y) * t,
      ));
    }
  }

  final accurateResult = AksaraEvaluator.evaluate(
    aksara: 'ꦲ',
    points: accuratePoints,
    canvasWidth: canvasW,
    canvasHeight: canvasH,
    glyphRect: targetRect,
  );

  print('Akurasi Goresan Ideal Ha: ${accurateResult.accuracy}% (${accurateResult.ratingText})');
  print('Coverage: ${(accurateResult.coverage * 100).toStringAsFixed(1)}%, Precision: ${(accurateResult.precision * 100).toStringAsFixed(1)}%');
  assert(accurateResult.isPassed, 'Goresan ideal harus lulus');
  assert(accurateResult.accuracy >= 75, 'Akurasi harus tinggi untuk goresan ideal');
  print('✓ Goresan ideal Ha lulus dengan akurasi ${accurateResult.accuracy}%');

  final randomPoints = <StrokePoint?>[
    const StrokePoint(10, 10),
    const StrokePoint(12, 12),
    const StrokePoint(15, 15),
  ];
  final randomResult = AksaraEvaluator.evaluate(
    aksara: 'ꦲ',
    points: randomPoints,
    canvasWidth: canvasW,
    canvasHeight: canvasH,
    glyphRect: targetRect,
  );
  print('Akurasi Goresan Asal: ${randomResult.accuracy}% - Lulus: ${randomResult.isPassed}');
  assert(!randomResult.isPassed, 'Goresan asal tidak boleh lulus');
  print('✓ Goresan asal berhasil ditolak.');

  final wildPoints = <StrokePoint?>[];
  for (int x = 0; x < 100; x += 5) {
    wildPoints.add(StrokePoint(x.toDouble(), 10));
  }
  final wildResult = AksaraEvaluator.evaluate(
    aksara: 'ꦲ',
    points: wildPoints,
    canvasWidth: canvasW,
    canvasHeight: canvasH,
    glyphRect: targetRect,
  );
  print('Akurasi Coretan di Luar Jalur: ${wildResult.accuracy}% - Lulus: ${wildResult.isPassed}');
  assert(!wildResult.isPassed, 'Coretan liar tidak boleh lulus');
  print('✓ Coretan di luar jalur berhasil ditolak.');

  print('=== SEMUA PENGUJIAN AKSARAEVALUATOR BERHASIL (100% PASSED) ===');
}

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jawakarsa/features/dolanan/games/aksara_evaluator.dart';
import 'package:jawakarsa/features/dolanan/games/aksara_glyph_evaluator.dart';

Future<void> _loadHanacarakaFont() async {
  final loader = FontLoader('Hanacaraka');
  final regular = File(
    'assets/fonts/NotoSansJavanese-Regular.ttf',
  ).readAsBytesSync();
  final bold = File('assets/fonts/NotoSansJavanese-Bold.ttf').readAsBytesSync();
  loader.addFont(Future.value(ByteData.sublistView(regular)));
  loader.addFont(Future.value(ByteData.sublistView(bold)));
  await loader.load();
}

Future<List<Offset?>> _sampleTracePointsFromGlyph(
  String aksara,
  Size canvasSize,
) async {
  final tp = AksaraGlyphEvaluator.buildGhostTextPainter(
    aksara: aksara,
    canvasSize: canvasSize,
    color: Colors.black,
  );
  final topLeft = AksaraGlyphEvaluator.computeGhostTopLeft(canvasSize, tp);
  final w = canvasSize.width.round();
  final h = canvasSize.height.round();

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(
    recorder,
    Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
  );
  tp.paint(canvas, topLeft);
  final picture = recorder.endRecording();
  final image = await picture.toImage(w, h);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();
  picture.dispose();

  final bytes = byteData!.buffer.asUint8List();
  final pts = <Offset?>[];
  for (int y = 4; y < h; y += 12) {
    bool inStroke = false;
    for (int x = 4; x < w; x += 6) {
      final alpha = bytes[(y * w + x) * 4 + 3];
      if (alpha >= 128) {
        pts.add(Offset(x.toDouble(), y.toDouble()));
        inStroke = true;
      } else if (inStroke) {
        pts.add(null);
        inStroke = false;
      }
    }
    if (inStroke) pts.add(null);
  }
  return pts;
}

void main() {
  group('AksaraEvaluator (waypoint fallback)', () {
    const canvasW = 350.0;
    const canvasH = 280.0;
    final targetRect = StrokeRect.fromCenter(
      center: const StrokePoint(175, 140),
      width: 200,
      height: 180,
    );

    const allAksara = [
      'ꦲ',
      'ꦤ',
      'ꦕ',
      'ꦫ',
      'ꦏ',
      'ꦢ',
      'ꦠ',
      'ꦱ',
      'ꦮ',
      'ꦭ',
      'ꦥ',
      'ꦝ',
      'ꦗ',
      'ꦪ',
      'ꦚ',
      'ꦩ',
      'ꦒ',
      'ꦧ',
      'ꦛ',
      'ꦔ',
    ];

    test('all 20 Hanacaraka aksara have at least 5 waypoints', () {
      for (final a in allAksara) {
        final wps = AksaraEvaluator.getWaypointsFor(a);
        expect(wps, isNotEmpty, reason: 'Aksara $a harus memiliki waypoints');
        expect(
          wps.length,
          greaterThanOrEqualTo(5),
          reason: 'Aksara $a harus memiliki minimal 5 waypoints',
        );
      }
    });

    test('ideal stroke for Ha passes with high accuracy', () {
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
          accuratePoints.add(
            StrokePoint(
              start.x + (end.x - start.x) * t,
              start.y + (end.y - start.y) * t,
            ),
          );
        }
      }

      final accurateResult = AksaraEvaluator.evaluate(
        aksara: 'ꦲ',
        points: accuratePoints,
        canvasWidth: canvasW,
        canvasHeight: canvasH,
        glyphRect: targetRect,
      );

      expect(accurateResult.isPassed, isTrue);
      expect(accurateResult.accuracy, greaterThanOrEqualTo(75));
    });

    test('single horizontal line across middle fails evaluation', () {
      final linePoints = <StrokePoint?>[
        for (int i = 0; i <= 20; i++)
          StrokePoint(targetRect.left + 10 + i * 7.0, targetRect.top + 90),
      ];
      final result = AksaraEvaluator.evaluate(
        aksara: 'ꦢ',
        points: linePoints,
        canvasWidth: canvasW,
        canvasHeight: canvasH,
        glyphRect: targetRect,
      );
      expect(result.isPassed, isFalse);
      expect(result.accuracy, lessThan(50));
    });

    test('tiny random dots fail evaluation', () {
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
      expect(randomResult.isPassed, isFalse);
    });

    test('wild out-of-path stroke fails evaluation', () {
      final wildPoints = <StrokePoint?>[
        for (int x = 0; x < 100; x += 5) StrokePoint(x.toDouble(), 10),
      ];
      final wildResult = AksaraEvaluator.evaluate(
        aksara: 'ꦲ',
        points: wildPoints,
        canvasWidth: canvasW,
        canvasHeight: canvasH,
        glyphRect: targetRect,
      );
      expect(wildResult.isPassed, isFalse);
    });
  });

  group('AksaraGlyphEvaluator (real Hanacaraka pixel mask)', () {
    const canvasSize = Size(350, 330);

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await _loadHanacarakaFont();
    });

    test('single horizontal line across Da fails strictly', () async {
      final linePoints = <Offset?>[
        for (int i = 0; i <= 24; i++) Offset(75.0 + i * 5.5, 155.0),
      ];

      final eval = await AksaraGlyphEvaluator.evaluate(
        aksara: 'ꦢ',
        points: linePoints,
        canvasSize: canvasSize,
      );

      expect(eval.isPassed, isFalse);
      expect(eval.coverage, lessThan(0.50));
      expect(eval.accuracy, lessThan(50));
    });

    test('full-canvas scribble cheat fails due to low precision', () async {
      final scribblePoints = <Offset?>[];
      for (double y = 16; y <= 314; y += 18) {
        for (double x = 16; x <= 334; x += 14) {
          scribblePoints.add(Offset(x, y));
        }
        scribblePoints.add(null);
      }

      final eval = await AksaraGlyphEvaluator.evaluate(
        aksara: 'ꦢ',
        points: scribblePoints,
        canvasSize: canvasSize,
      );

      expect(eval.isPassed, isFalse);
      expect(eval.precision, lessThan(0.58));
    });

    test('tiny dot fails evaluation', () async {
      final eval = await AksaraGlyphEvaluator.evaluate(
        aksara: 'ꦢ',
        points: const [Offset(175, 165), Offset(177, 166), Offset(179, 165)],
        canvasSize: canvasSize,
      );

      expect(eval.isPassed, isFalse);
      expect(eval.accuracy, lessThan(30));
    });

    for (final aksara in const ['ꦢ', 'ꦲ', 'ꦫ', 'ꦤ']) {
      test(
        'real trace following rendered $aksara passes with high accuracy',
        () async {
          final tracePoints = await _sampleTracePointsFromGlyph(
            aksara,
            canvasSize,
          );

          final eval = await AksaraGlyphEvaluator.evaluate(
            aksara: aksara,
            points: tracePoints,
            canvasSize: canvasSize,
          );

          expect(eval.isPassed, isTrue);
          expect(eval.coverage, greaterThanOrEqualTo(0.80));
          expect(eval.precision, greaterThanOrEqualTo(0.80));
          expect(eval.accuracy, greaterThanOrEqualTo(80));
        },
      );
    }
  });
}

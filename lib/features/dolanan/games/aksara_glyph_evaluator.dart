import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/features/dolanan/games/aksara_evaluator.dart';

class AksaraGlyphEvaluator {
  AksaraGlyphEvaluator._();

  static const int _maxGridDim = 96;

  static double computeGhostFontSize(Size canvasSize) {
    return (canvasSize.shortestSide * 0.60).clamp(76.0, 168.0);
  }

  static TextPainter buildGhostTextPainter({
    required String aksara,
    required Size canvasSize,
    Color? color,
    Paint? foreground,
  }) {
    final fontSize = computeGhostFontSize(canvasSize);
    final baseStyle = AppTextStyles.aksara(
      fontSize: fontSize,
      color: foreground == null
          ? (color ?? const Color(0xFFC7CFE2))
          : Colors.black,
      fontWeight: FontWeight.w600,
      height: 1.0,
    );
    final style = foreground != null
        ? baseStyle.copyWith(color: null, foreground: foreground)
        : baseStyle;
    return TextPainter(
      text: TextSpan(text: aksara, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: canvasSize.width);
  }

  static Offset computeGhostTopLeft(Size canvasSize, TextPainter tp) {
    final center = Offset(canvasSize.width / 2, canvasSize.height / 2);
    return center - Offset(tp.width / 2, tp.height / 2);
  }

  static Future<AksaraEvaluation> evaluate({
    required String aksara,
    required List<Offset?> points,
    required Size canvasSize,
  }) async {
    final validCount = points.where((p) => p != null).length;
    if (validCount < 5 || canvasSize.width <= 0 || canvasSize.height <= 0) {
      return const AksaraEvaluation(
        accuracy: 10,
        coverage: 0.05,
        precision: 0.05,
        isPassed: false,
        rating: AksaraRating.kurang,
        feedback: 'Goresan terlalu sedikit! Yuk gambar seluruh bentuk aksara.',
      );
    }

    final scale = _maxGridDim / max(canvasSize.width, canvasSize.height);
    final gridW = max(16, (canvasSize.width * scale).round());
    final gridH = max(16, (canvasSize.height * scale).round());

    final tp = buildGhostTextPainter(
      aksara: aksara,
      canvasSize: canvasSize,
      color: Colors.black,
    );
    final ghostTopLeft = computeGhostTopLeft(canvasSize, tp);
    final ghostFontSize = computeGhostFontSize(canvasSize);

    final glyphMask = await _rasterizeAlphaMask(gridW, gridH, (canvas) {
      canvas.scale(scale, scale);
      tp.paint(canvas, ghostTopLeft);
    }, alphaThreshold: 48);

    if (glyphMask == null || !glyphMask.any((v) => v != 0)) {
      final fallbackPoints = points
          .map((p) => p != null ? StrokePoint(p.dx, p.dy) : null)
          .toList();
      return AksaraEvaluator.evaluate(
        aksara: aksara,
        points: fallbackPoints,
        canvasWidth: canvasSize.width,
        canvasHeight: canvasSize.height,
      );
    }

    final thinStrokeWidth = (canvasSize.shortestSide * 0.018).clamp(5.0, 8.0);
    final coverageBrushWidth = (ghostFontSize * 0.22).clamp(20.0, 34.0);

    final userThinMask = await _rasterizeAlphaMask(gridW, gridH, (canvas) {
      canvas.scale(scale, scale);
      _drawPoints(canvas, points, thinStrokeWidth);
    }, alphaThreshold: 32);

    final userCoverageMask = await _rasterizeAlphaMask(gridW, gridH, (canvas) {
      canvas.scale(scale, scale);
      _drawPoints(canvas, points, coverageBrushWidth);
    }, alphaThreshold: 32);

    if (userThinMask == null || userCoverageMask == null) {
      final fallbackPoints = points
          .map((p) => p != null ? StrokePoint(p.dx, p.dy) : null)
          .toList();
      return AksaraEvaluator.evaluate(
        aksara: aksara,
        points: fallbackPoints,
        canvasWidth: canvasSize.width,
        canvasHeight: canvasSize.height,
      );
    }

    double strokeLength = 0;
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      if (a != null && b != null) {
        strokeLength += (b - a).distance;
      }
    }

    final glyphDiag = sqrt(tp.width * tp.width + tp.height * tp.height);
    final precisionRadius = max(2, (scale * 7.0).round());

    return AksaraEvaluator.evaluateMasks(
      width: gridW,
      height: gridH,
      glyphMask: glyphMask,
      userThinMask: userThinMask,
      userCoverageMask: userCoverageMask,
      precisionRadius: precisionRadius,
      validPointCount: validCount,
      userStrokeLength: strokeLength,
      glyphDiagonal: glyphDiag,
    );
  }

  static void _drawPoints(
    Canvas canvas,
    List<Offset?> points,
    double strokeWidth,
  ) {
    final strokePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final current = points[i];
      if (current == null) continue;
      final hasPrev = i > 0 && points[i - 1] != null;
      final hasNext = i < points.length - 1 && points[i + 1] != null;
      if (!hasPrev && !hasNext) {
        canvas.drawCircle(current, strokeWidth / 2, dotPaint);
      } else if (hasNext) {
        canvas.drawLine(current, points[i + 1]!, strokePaint);
      }
    }
  }

  static Future<Uint8List?> _rasterizeAlphaMask(
    int width,
    int height,
    void Function(Canvas canvas) drawFn, {
    int alphaThreshold = 48,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    );
    drawFn(canvas);
    final picture = recorder.endRecording();
    ui.Image? image;
    try {
      image = await picture.toImage(width, height);
      final byteData = await image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (byteData == null) return null;
      final bytes = byteData.buffer.asUint8List();
      final total = width * height;
      final mask = Uint8List(total);
      for (int i = 0; i < total; i++) {
        if (bytes[i * 4 + 3] >= alphaThreshold) {
          mask[i] = 1;
        }
      }
      return mask;
    } finally {
      image?.dispose();
      picture.dispose();
    }
  }
}

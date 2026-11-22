import 'dart:math';

class StrokePoint {
  const StrokePoint(this.x, this.y);
  final double x;
  final double y;

  double distanceTo(StrokePoint other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  double distanceSquaredTo(StrokePoint other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return dx * dx + dy * dy;
  }
}

class StrokeRect {
  const StrokeRect({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });

  factory StrokeRect.fromCenter({
    required StrokePoint center,
    required double width,
    required double height,
  }) {
    return StrokeRect(
      left: center.x - width / 2,
      top: center.y - height / 2,
      width: width,
      height: height,
    );
  }

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
}

enum AksaraRating { sempurna, bagus, cukup, kurang }

class AksaraEvaluation {
  const AksaraEvaluation({
    required this.accuracy,
    required this.coverage,
    required this.precision,
    required this.isPassed,
    required this.rating,
    required this.feedback,
  });

  final int accuracy;

  final double coverage;

  final double precision;

  final bool isPassed;

  final AksaraRating rating;

  final String feedback;

  String get ratingText {
    switch (rating) {
      case AksaraRating.sempurna:
        return 'Sempurna! 🌟';
      case AksaraRating.bagus:
        return 'Apik Tenan! 👍';
      case AksaraRating.cukup:
        return 'Cukup Bagus! 👌';
      case AksaraRating.kurang:
        return 'Belum Pas';
    }
  }
}

class AksaraEvaluator {
  AksaraEvaluator._();

  static const Map<String, List<StrokePoint>> _aksaraWaypoints = {
    'ꦲ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.18, 0.45),
      StrokePoint(0.28, 0.22),
      StrokePoint(0.42, 0.38),
      StrokePoint(0.50, 0.70),
      StrokePoint(0.58, 0.38),
      StrokePoint(0.72, 0.22),
      StrokePoint(0.82, 0.45),
      StrokePoint(0.85, 0.82),
    ],
    'ꦤ': [
      StrokePoint(0.14, 0.82),
      StrokePoint(0.18, 0.40),
      StrokePoint(0.32, 0.22),
      StrokePoint(0.44, 0.52),
      StrokePoint(0.54, 0.82),
      StrokePoint(0.64, 0.38),
      StrokePoint(0.78, 0.22),
      StrokePoint(0.86, 0.82),
    ],
    'ꦕ': [
      StrokePoint(0.18, 0.50),
      StrokePoint(0.28, 0.22),
      StrokePoint(0.52, 0.25),
      StrokePoint(0.60, 0.55),
      StrokePoint(0.45, 0.78),
      StrokePoint(0.68, 0.82),
      StrokePoint(0.82, 0.55),
    ],
    'ꦫ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.25, 0.35),
      StrokePoint(0.50, 0.20),
      StrokePoint(0.75, 0.35),
      StrokePoint(0.82, 0.82),
    ],
    'ꦏ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.20, 0.40),
      StrokePoint(0.32, 0.22),
      StrokePoint(0.50, 0.48),
      StrokePoint(0.50, 0.75),
      StrokePoint(0.68, 0.22),
      StrokePoint(0.80, 0.40),
      StrokePoint(0.85, 0.82),
    ],
    'ꦢ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.45, 0.22),
      StrokePoint(0.62, 0.48),
      StrokePoint(0.58, 0.82),
      StrokePoint(0.80, 0.82),
    ],
    'ꦠ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.22, 0.30),
      StrokePoint(0.38, 0.22),
      StrokePoint(0.48, 0.58),
      StrokePoint(0.60, 0.58),
      StrokePoint(0.72, 0.25),
      StrokePoint(0.85, 0.82),
    ],
    'ꦱ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.25, 0.25),
      StrokePoint(0.42, 0.22),
      StrokePoint(0.50, 0.55),
      StrokePoint(0.68, 0.22),
      StrokePoint(0.82, 0.35),
      StrokePoint(0.85, 0.82),
    ],
    'ꦮ': [
      StrokePoint(0.20, 0.82),
      StrokePoint(0.28, 0.35),
      StrokePoint(0.50, 0.22),
      StrokePoint(0.75, 0.38),
      StrokePoint(0.72, 0.75),
      StrokePoint(0.50, 0.82),
      StrokePoint(0.35, 0.72),
    ],
    'ꦭ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.20, 0.35),
      StrokePoint(0.35, 0.22),
      StrokePoint(0.48, 0.60),
      StrokePoint(0.60, 0.35),
      StrokePoint(0.75, 0.22),
      StrokePoint(0.85, 0.82),
    ],
    'ꦥ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.45, 0.22),
      StrokePoint(0.62, 0.42),
      StrokePoint(0.78, 0.42),
      StrokePoint(0.82, 0.82),
    ],
    'ꦝ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.48, 0.22),
      StrokePoint(0.68, 0.42),
      StrokePoint(0.55, 0.65),
      StrokePoint(0.75, 0.75),
      StrokePoint(0.82, 0.82),
    ],
    'ꦗ': [
      StrokePoint(0.18, 0.50),
      StrokePoint(0.32, 0.22),
      StrokePoint(0.52, 0.32),
      StrokePoint(0.45, 0.68),
      StrokePoint(0.65, 0.82),
      StrokePoint(0.82, 0.52),
    ],
    'ꦪ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.20, 0.35),
      StrokePoint(0.35, 0.22),
      StrokePoint(0.48, 0.52),
      StrokePoint(0.60, 0.22),
      StrokePoint(0.75, 0.22),
      StrokePoint(0.85, 0.82),
    ],
    'ꦚ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.38, 0.22),
      StrokePoint(0.50, 0.55),
      StrokePoint(0.65, 0.22),
      StrokePoint(0.80, 0.35),
      StrokePoint(0.85, 0.82),
    ],
    'ꦩ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.38),
      StrokePoint(0.42, 0.22),
      StrokePoint(0.60, 0.38),
      StrokePoint(0.60, 0.75),
      StrokePoint(0.40, 0.82),
      StrokePoint(0.78, 0.82),
    ],
    'ꦒ': [
      StrokePoint(0.20, 0.82),
      StrokePoint(0.30, 0.35),
      StrokePoint(0.50, 0.20),
      StrokePoint(0.70, 0.35),
      StrokePoint(0.80, 0.82),
    ],
    'ꦧ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.42, 0.22),
      StrokePoint(0.52, 0.52),
      StrokePoint(0.70, 0.32),
      StrokePoint(0.82, 0.82),
    ],
    'ꦛ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.48, 0.22),
      StrokePoint(0.62, 0.42),
      StrokePoint(0.45, 0.65),
      StrokePoint(0.70, 0.82),
    ],
    'ꦔ': [
      StrokePoint(0.20, 0.82),
      StrokePoint(0.28, 0.35),
      StrokePoint(0.50, 0.22),
      StrokePoint(0.75, 0.38),
      StrokePoint(0.82, 0.68),
      StrokePoint(0.65, 0.82),
    ],
  };

  static List<StrokePoint> getWaypointsFor(String aksara) {
    return _aksaraWaypoints[aksara] ??
        const [
          StrokePoint(0.2, 0.8),
          StrokePoint(0.3, 0.3),
          StrokePoint(0.5, 0.2),
          StrokePoint(0.7, 0.3),
          StrokePoint(0.8, 0.8),
        ];
  }

  static AksaraEvaluation evaluate({
    required String aksara,
    required List<StrokePoint?> points,
    required double canvasWidth,
    required double canvasHeight,
    StrokeRect? glyphRect,
  }) {
    final validPoints = points.whereType<StrokePoint>().toList();
    if (validPoints.length < 5) {
      return const AksaraEvaluation(
        accuracy: 10,
        coverage: 0.1,
        precision: 0.1,
        isPassed: false,
        rating: AksaraRating.kurang,
        feedback: 'Goresan terlalu sedikit! Yuk gambar bentuk aksaranya.',
      );
    }

    final center = StrokePoint(canvasWidth / 2, canvasHeight / 2);
    final targetRect = glyphRect ??
        StrokeRect.fromCenter(
          center: center,
          width: (canvasWidth * 0.70).clamp(160.0, 260.0),
          height: (canvasHeight * 0.68).clamp(140.0, 220.0),
        );

    final rawWaypoints = getWaypointsFor(aksara);

    final canvasWaypoints = rawWaypoints.map((w) {
      return StrokePoint(
        targetRect.left + w.x * targetRect.width,
        targetRect.top + w.y * targetRect.height,
      );
    }).toList();

    final tolerance = (targetRect.width * 0.15).clamp(24.0, 40.0);
    final wideTolerance = tolerance * 1.5;

    double coveredScoreSum = 0;
    int hitCount = 0;

    for (final wp in canvasWaypoints) {
      double minDist = double.infinity;
      for (final p in validPoints) {
        final dist = wp.distanceTo(p);
        if (dist < minDist) minDist = dist;
      }

      if (minDist <= tolerance) {
        hitCount++;
        final factor = (1.0 - (minDist / tolerance)).clamp(0.0, 1.0);
        coveredScoreSum += (0.80 + 0.20 * factor);
      } else if (minDist <= wideTolerance) {
        final factor = (1.0 - ((minDist - tolerance) / (wideTolerance - tolerance))).clamp(0.0, 1.0);
        coveredScoreSum += (0.40 * factor);
      }
    }

    double coverage = (coveredScoreSum / canvasWaypoints.length).clamp(0.0, 1.0);

    int pointsInCorridor = 0;
    for (final p in validPoints) {
      double minDistToSkeleton = double.infinity;

      for (int i = 0; i < canvasWaypoints.length - 1; i++) {
        final dist = _distToSegment(p, canvasWaypoints[i], canvasWaypoints[i + 1]);
        if (dist < minDistToSkeleton) minDistToSkeleton = dist;
      }

      if (minDistToSkeleton <= wideTolerance) {
        pointsInCorridor++;
      }
    }

    final precision = (pointsInCorridor / validPoints.length).clamp(0.0, 1.0);

    double userStrokeLength = 0;
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        userStrokeLength += points[i]!.distanceTo(points[i + 1]!);
      }
    }

    double expectedLength = 0;
    for (int i = 0; i < canvasWaypoints.length - 1; i++) {
      expectedLength += canvasWaypoints[i].distanceTo(canvasWaypoints[i + 1]);
    }

    final double lengthRatio = expectedLength > 0 ? (userStrokeLength / expectedLength) : 1.0;
    double lengthScore;
    if (lengthRatio < 0.30) {
      lengthScore = (0.5 + 0.5 * (lengthRatio / 0.30)).clamp(0.5, 1.0);
    } else if (lengthRatio <= 2.2) {
      lengthScore = 1.0;
    } else {
      lengthScore = (1.0 - ((lengthRatio - 2.2) / 2.0)).clamp(0.2, 1.0);
    }

    final hitRatio = hitCount / canvasWaypoints.length;
    if (hitRatio < 0.40) {
      coverage *= (0.6 + 0.4 * (hitRatio / 0.40));
    }

    final rawAccuracy = (coverage * 0.60 + precision * 0.35 + lengthScore * 0.05) * 100;
    final int accuracy = rawAccuracy.round().clamp(5, 98);

    final bool isPassed = accuracy >= 45;

    AksaraRating rating;
    String feedback;

    if (accuracy >= 85) {
      rating = AksaraRating.sempurna;
      feedback = 'Luar biasa! Goresanmu sangat mirip dan proporsional!';
    } else if (accuracy >= 70) {
      rating = AksaraRating.bagus;
      feedback = 'Apik tenan! Goresan sudah mengikuti lekukan aksara dengan baik.';
    } else if (accuracy >= 50) {
      rating = AksaraRating.cukup;
      feedback = 'Bagus! Goresan cukup tepat, teruskan latihanmu.';
    } else {
      rating = AksaraRating.kurang;
      if (coverage < 0.45 || hitRatio < 0.5) {
        feedback = 'Goresan belum lengkap. Pastikan mengikuti semua lekuk huruf!';
      } else if (precision < 0.45) {
        feedback = 'Goresan agak melenceng keluar jalur. Coba lebih teliti ya!';
      } else {
        feedback = 'Belum pas. Ikuti bayangan abu-abu pada kanvas.';
      }
    }

    return AksaraEvaluation(
      accuracy: accuracy,
      coverage: coverage,
      precision: precision,
      isPassed: isPassed,
      rating: rating,
      feedback: feedback,
    );
  }

  static double _distToSegment(StrokePoint p, StrokePoint a, StrokePoint b) {
    final l2 = a.distanceSquaredTo(b);
    if (l2 == 0) return p.distanceTo(a);
    final t = (((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / l2).clamp(0.0, 1.0);
    final proj = StrokePoint(a.x + t * (b.x - a.x), a.y + t * (b.y - a.y));
    return p.distanceTo(proj);
  }
}

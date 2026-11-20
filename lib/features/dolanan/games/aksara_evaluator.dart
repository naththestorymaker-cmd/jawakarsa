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

  /// Persentase akurasi 0 - 100
  final int accuracy;

  /// Rasio cakupan waypoint aksara yang disentuh (0.0 - 1.0)
  final double coverage;

  /// Rasio ketepatan goresan berada di jalur aksara (0.0 - 1.0)
  final double precision;

  /// Lolos jika akurasi >= 50%
  final bool isPassed;

  /// Tingkat kualitas goresan
  final AksaraRating rating;

  /// Pesan umpan balik untuk pemain
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

/// Evaluator cerdas untuk memverifikasi goresan aksara Jawa pada kanvas.
/// Menggunakan analisis waypoint morfologis Hanacaraka, toleransi jarak adaptif,
/// dan rasio cakupan/presisi.
class AksaraEvaluator {
  AksaraEvaluator._();

  /// Sifat anatomi waypoint normalisasi (u, v) [0.0 - 1.0] untuk 20 aksara Nglegena.
  /// Waypoint mencerminkan jalur goresan alami Aksara Jawa.
  static const Map<String, List<StrokePoint>> _aksaraWaypoints = {
    // ꦲ (Ha): dua lengkungan (kiri dan kanan) dengan lembah tengah
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
    // ꦤ (Na): naik kiri, gelombang, kait tengah bawah, gelombang kanan, turun
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
    // ꦕ (Ca): lengkung kiri atas, diagonal ke tengah, lengkung bawah kanan
    'ꦕ': [
      StrokePoint(0.18, 0.50),
      StrokePoint(0.28, 0.22),
      StrokePoint(0.52, 0.25),
      StrokePoint(0.60, 0.55),
      StrokePoint(0.45, 0.78),
      StrokePoint(0.68, 0.82),
      StrokePoint(0.82, 0.55),
    ],
    // ꦫ (Ra): satu lengkungan utama sederhana
    'ꦫ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.25, 0.35),
      StrokePoint(0.50, 0.20),
      StrokePoint(0.75, 0.35),
      StrokePoint(0.82, 0.82),
    ],
    // ꦏ (Ka): mirip Ha dengan lingkaran/simpul di tengah
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
    // ꦢ (Da): lengkung atas, patahan tengah ke bawah, ekor kanan
    'ꦢ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.45, 0.22),
      StrokePoint(0.62, 0.48),
      StrokePoint(0.58, 0.82),
      StrokePoint(0.80, 0.82),
    ],
    // ꦠ (Ta): mirip Na dengan celah lekuk tengah tajam
    'ꦠ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.22, 0.30),
      StrokePoint(0.38, 0.22),
      StrokePoint(0.48, 0.58),
      StrokePoint(0.60, 0.58),
      StrokePoint(0.72, 0.25),
      StrokePoint(0.85, 0.82),
    ],
    // ꦱ (Sa): tiga gelombang puncak kecil
    'ꦱ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.25, 0.25),
      StrokePoint(0.42, 0.22),
      StrokePoint(0.50, 0.55),
      StrokePoint(0.68, 0.22),
      StrokePoint(0.82, 0.35),
      StrokePoint(0.85, 0.82),
    ],
    // ꦮ (Wa): mirip Ra berputar membulat ke dalam
    'ꦮ': [
      StrokePoint(0.20, 0.82),
      StrokePoint(0.28, 0.35),
      StrokePoint(0.50, 0.22),
      StrokePoint(0.75, 0.38),
      StrokePoint(0.72, 0.75),
      StrokePoint(0.50, 0.82),
      StrokePoint(0.35, 0.72),
    ],
    // ꦭ (La): dua lengkung bertingkat
    'ꦭ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.20, 0.35),
      StrokePoint(0.35, 0.22),
      StrokePoint(0.48, 0.60),
      StrokePoint(0.60, 0.35),
      StrokePoint(0.75, 0.22),
      StrokePoint(0.85, 0.82),
    ],
    // ꦥ (Pa): satu lengkung terbuka kanan
    'ꦥ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.45, 0.22),
      StrokePoint(0.62, 0.42),
      StrokePoint(0.78, 0.42),
      StrokePoint(0.82, 0.82),
    ],
    // ꦝ (Dha): lengkung ganda bersambung
    'ꦝ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.48, 0.22),
      StrokePoint(0.68, 0.42),
      StrokePoint(0.55, 0.65),
      StrokePoint(0.75, 0.75),
      StrokePoint(0.82, 0.82),
    ],
    // ꦗ (Ja): alur zigzag vertikal dengan gelombang
    'ꦗ': [
      StrokePoint(0.18, 0.50),
      StrokePoint(0.32, 0.22),
      StrokePoint(0.52, 0.32),
      StrokePoint(0.45, 0.68),
      StrokePoint(0.65, 0.82),
      StrokePoint(0.82, 0.52),
    ],
    // ꦪ (Ya): tiga gelombang khas
    'ꦪ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.20, 0.35),
      StrokePoint(0.35, 0.22),
      StrokePoint(0.48, 0.52),
      StrokePoint(0.60, 0.22),
      StrokePoint(0.75, 0.22),
      StrokePoint(0.85, 0.82),
    ],
    // ꦚ (Nya): empat segmen berulang
    'ꦚ': [
      StrokePoint(0.15, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.38, 0.22),
      StrokePoint(0.50, 0.55),
      StrokePoint(0.65, 0.22),
      StrokePoint(0.80, 0.35),
      StrokePoint(0.85, 0.82),
    ],
    // ꦩ (Ma): lengkung kiri atas dan mangkuk bawah
    'ꦩ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.38),
      StrokePoint(0.42, 0.22),
      StrokePoint(0.60, 0.38),
      StrokePoint(0.60, 0.75),
      StrokePoint(0.40, 0.82),
      StrokePoint(0.78, 0.82),
    ],
    // ꦒ (Ga): mirip payung / V terbalik sederhana
    'ꦒ': [
      StrokePoint(0.20, 0.82),
      StrokePoint(0.30, 0.35),
      StrokePoint(0.50, 0.20),
      StrokePoint(0.70, 0.35),
      StrokePoint(0.80, 0.82),
    ],
    // ꦧ (Ba): lengkung kiri bergelombang ke kanan
    'ꦧ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.42, 0.22),
      StrokePoint(0.52, 0.52),
      StrokePoint(0.70, 0.32),
      StrokePoint(0.82, 0.82),
    ],
    // ꦛ (Tha): lengkung ganda tertutup
    'ꦛ': [
      StrokePoint(0.18, 0.82),
      StrokePoint(0.22, 0.35),
      StrokePoint(0.48, 0.22),
      StrokePoint(0.62, 0.42),
      StrokePoint(0.45, 0.65),
      StrokePoint(0.70, 0.82),
    ],
    // ꦔ (Nga): lengkung atas dengan sayap kanan
    'ꦔ': [
      StrokePoint(0.20, 0.82),
      StrokePoint(0.28, 0.35),
      StrokePoint(0.50, 0.22),
      StrokePoint(0.75, 0.38),
      StrokePoint(0.82, 0.68),
      StrokePoint(0.65, 0.82),
    ],
  };

  /// Ambil daftar waypoint normalisasi untuk aksara tertentu
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

  /// Menghitung akurasi goresan pengguna terhadap target aksara.
  ///
  /// [points] daftar titik koordinat kanvas (termasuk null sebagai pemisah goresan).
  /// [canvasWidth] & [canvasHeight] ukuran kanvas saat menggambar.
  /// [aksara] karakter aksara Jawa (misalnya 'ꦲ').
  /// [glyphRect] area batas spesifik di mana huruf ditampilkan.
  static AksaraEvaluation evaluate({
    required String aksara,
    required List<StrokePoint?> points,
    required double canvasWidth,
    required double canvasHeight,
    StrokeRect? glyphRect,
  }) {
    // 1. Ekstrak titik-titik valid
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

    // 2. Tentukan area referensi aksara di kanvas
    final center = StrokePoint(canvasWidth / 2, canvasHeight / 2);
    final targetRect = glyphRect ??
        StrokeRect.fromCenter(
          center: center,
          width: (canvasWidth * 0.70).clamp(160.0, 260.0),
          height: (canvasHeight * 0.68).clamp(140.0, 220.0),
        );

    final rawWaypoints = getWaypointsFor(aksara);

    // Transformasikan waypoint normalisasi ke koordinat nyata kanvas
    final canvasWaypoints = rawWaypoints.map((w) {
      return StrokePoint(
        targetRect.left + w.x * targetRect.width,
        targetRect.top + w.y * targetRect.height,
      );
    }).toList();

    // Toleransi jarak adaptif yang pas untuk goresan jari di layar sentuh (24-40px)
    final tolerance = (targetRect.width * 0.15).clamp(24.0, 40.0);
    final wideTolerance = tolerance * 1.5;

    // 3. Evaluasi Coverage (Berapa banyak waypoint aksara yang disentuh goresan)
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

    // 4. Evaluasi Precision (Berapa banyak titik goresan yang berada di koridor aksara target)
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

    // 5. Evaluasi Total Panjang Goresan (stroke length completeness)
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
      // Goresan berlebihan/coretan acak bolak-balik dihukum
      lengthScore = (1.0 - ((lengthRatio - 2.2) / 2.0)).clamp(0.2, 1.0);
    }

    // Pinalti halus jika hanya sedikit sekali waypoint yang tersentuh (< 40%)
    final hitRatio = hitCount / canvasWaypoints.length;
    if (hitRatio < 0.40) {
      coverage *= (0.6 + 0.4 * (hitRatio / 0.40));
    }

    // 6. Hitung persentase akhir (Formula gabungan berbobot yang adil)
    // Coverage 60% + Precision 35% + Length 5%
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

  /// Menghitung jarak minimum titik [p] ke segmen garis [a]-[b]
  static double _distToSegment(StrokePoint p, StrokePoint a, StrokePoint b) {
    final l2 = a.distanceSquaredTo(b);
    if (l2 == 0) return p.distanceTo(a);
    final t = (((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / l2).clamp(0.0, 1.0);
    final proj = StrokePoint(a.x + t * (b.x - a.x), a.y + t * (b.y - a.y));
    return p.distanceTo(proj);
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import '../models/dolan_region.dart';

class JavaIslandMapCard extends StatelessWidget {
  const JavaIslandMapCard({
    super.key,
    required this.selectedRegionId,
    required this.onRegionSelected,
  });

  final int selectedRegionId;
  final ValueChanged<int> onRegionSelected;

  @override
  Widget build(BuildContext context) {
    final activeRegion = dolanRegions.firstWhere(
      (r) => r.id == selectedRegionId,
      orElse: () => dolanRegions.first,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.potBlack.withValues(alpha: 0.12),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.potBlack.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Hand-Drawn Compass Rose
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.rubyRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.rubyRed.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.near_me_rounded,
                                color: AppColors.rubyRed,
                                size: 13,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'PETA PULAU JAWA',
                                style: AppTextStyles.labelSmall(
                                  color: AppColors.rubyRed,
                                ).copyWith(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Pilih Daerah Jawa',
                      style: AppTextStyles.titleMedium().copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Text(
                      'Ketuk langsung pada pulau atau tombol nomor',
                      style: AppTextStyles.labelSmall(
                        color: AppColors.coastalStorm,
                      ),
                    ),
                  ],
                ),
              ),

              // Authentic Compass Rose from reference
              const _SketchCompassRose(),
            ],
          ),

          const SizedBox(height: 12),

          // Vector Canvas with Exact Reference Silhouette of Java Island
          Container(
            height: 185,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F5EE), // Warm parchment tone
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.potBlack.withValues(alpha: 0.08),
                width: 1.0,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return _InteractiveJavaMap(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  selectedId: selectedRegionId,
                  onSelect: onRegionSelected,
                );
              },
            ),
          ),

          const SizedBox(height: 14),

          // Active Region Name Callout
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.potBlack.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.rubyRed,
                  ),
                  child: Center(
                    child: Text(
                      '${activeRegion.id}',
                      style: AppTextStyles.labelSmall(
                        color: Colors.white,
                      ).copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeRegion.name.toUpperCase(),
                        style: AppTextStyles.labelLarge(
                          color: AppColors.potBlack,
                        ).copyWith(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        activeRegion.nickname,
                        style: AppTextStyles.labelSmall(
                          color: AppColors.coastalStorm,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.touch_app_outlined,
                  size: 16,
                  color: AppColors.coastalStorm,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Responsive Pagination Bar: < [1] [2] [3] [4] [5] [6] >
          _RegionNumberPagination(
            selectedId: selectedRegionId,
            totalRegions: dolanRegions.length,
            onSelect: onRegionSelected,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTHENTIC HAND-DRAWN COMPASS ROSE
// ─────────────────────────────────────────────────────────────────────────────
class _SketchCompassRose extends StatelessWidget {
  const _SketchCompassRose();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: CustomPaint(
        painter: _CompassPainter(),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2 + 2;
    final r = math.min(size.width, size.height) * 0.40;

    final paintStroke = Paint()
      ..color = AppColors.potBlack
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    final paintDark = Paint()
      ..color = AppColors.rubyRed
      ..style = PaintingStyle.fill;

    final paintLight = Paint()
      ..color = AppColors.potBlack.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    // 1. North Star Point
    final northPath = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx, cy)
      ..lineTo(cx - r * 0.25, cy - r * 0.2)
      ..close();
    canvas.drawPath(northPath, paintDark);
    canvas.drawPath(northPath, paintStroke);

    final northRightPath = Path()
      ..moveTo(cx, cy - r)
      ..lineTo(cx, cy)
      ..lineTo(cx + r * 0.25, cy - r * 0.2)
      ..close();
    canvas.drawPath(northRightPath, paintLight);
    canvas.drawPath(northRightPath, paintStroke);

    // 2. South Point
    final southPath = Path()
      ..moveTo(cx, cy + r * 0.75)
      ..lineTo(cx, cy)
      ..lineTo(cx + r * 0.2, cy + r * 0.15)
      ..close();
    canvas.drawPath(southPath, paintDark);
    canvas.drawPath(southPath, paintStroke);

    // 3. East Point
    final eastPath = Path()
      ..moveTo(cx + r * 0.8, cy)
      ..lineTo(cx, cy)
      ..lineTo(cx + r * 0.18, cy - r * 0.18)
      ..close();
    canvas.drawPath(eastPath, paintDark);
    canvas.drawPath(eastPath, paintStroke);

    // 4. West Point
    final westPath = Path()
      ..moveTo(cx - r * 0.8, cy)
      ..lineTo(cx, cy)
      ..lineTo(cx - r * 0.18, cy + r * 0.18)
      ..close();
    canvas.drawPath(westPath, paintDark);
    canvas.drawPath(westPath, paintStroke);

    void drawLetter(String char, Offset pos, {bool isNorth = false}) {
      final span = TextSpan(
        text: char,
        style: TextStyle(
          color: isNorth ? AppColors.rubyRed : AppColors.potBlack,
          fontSize: isNorth ? 10 : 8,
          fontWeight: isNorth ? FontWeight.w900 : FontWeight.w700,
          fontFamily: 'sans-serif',
        ),
      );
      final tp = TextPainter(
        text: span,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
    }

    drawLetter('U', Offset(cx, cy - r - 7), isNorth: true);
    drawLetter('T', Offset(cx + r + 5, cy));
    drawLetter('S', Offset(cx, cy + r + 5));
    drawLetter('B', Offset(cx - r - 5, cy));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE MAP WITH ACCURATE SILHOUETTE & POLISHED COMPACT PINS
// ─────────────────────────────────────────────────────────────────────────────
class _InteractiveJavaMap extends StatefulWidget {
  const _InteractiveJavaMap({
    required this.size,
    required this.selectedId,
    required this.onSelect,
  });

  final Size size;
  final int selectedId;
  final ValueChanged<int> onSelect;

  @override
  State<_InteractiveJavaMap> createState() => _InteractiveJavaMapState();
}

class _InteractiveJavaMapState extends State<_InteractiveJavaMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;

  static const double baseW = 600.0;
  static const double baseH = 190.0;

  // Realistic centroids corresponding to the reference outline
  static const centroids = <int, Offset>{
    1: Offset(64.0, 72.0),   // Banten
    2: Offset(118.0, 38.0),  // DKI Jakarta
    3: Offset(170.0, 76.0),  // Jawa Barat
    4: Offset(308.0, 88.0),  // Jawa Tengah
    5: Offset(324.0, 128.0), // D.I. Yogyakarta (clearly separated below Jateng)
    6: Offset(478.0, 116.0), // Jawa Timur
  };

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scaleX = widget.size.width / baseW;
    final scaleY = widget.size.height / baseH;
    final scale = math.min(scaleX, scaleY);

    final offsetX = (widget.size.width - baseW * scale) / 2;
    final offsetY = (widget.size.height - baseH * scale) / 2;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) {
        final local = details.localPosition;
        final unscaledX = (local.dx - offsetX) / scale;
        final unscaledY = (local.dy - offsetY) / scale;
        final touchPoint = Offset(unscaledX, unscaledY);

        final paths = _JavaSilhouettePainter.buildPaths();
        for (final entry in paths.entries) {
          if (entry.value.contains(touchPoint)) {
            widget.onSelect(entry.key);
            return;
          }
        }

        // Proximity detection fallback
        int closestId = widget.selectedId;
        double minDist = 55.0;
        centroids.forEach((id, centroid) {
          final dist = (centroid - touchPoint).distance;
          if (dist < minDist) {
            minDist = dist;
            closestId = id;
          }
        });
        widget.onSelect(closestId);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Exact Reference Silhouette Painter
          CustomPaint(
            size: widget.size,
            painter: _JavaSilhouettePainter(
              selectedId: widget.selectedId,
              scale: scale,
              offsetX: offsetX,
              offsetY: offsetY,
            ),
          ),

          // Sleek, Compact Pins (does NOT obscure the island outline)
          ...centroids.entries.map((e) {
            final id = e.key;
            final pt = e.value;
            final isSelected = id == widget.selectedId;
            final screenX = offsetX + pt.dx * scale;
            final screenY = offsetY + pt.dy * scale;

            final pinSize = isSelected ? 24.0 : 18.0;

            return Positioned(
              left: screenX - pinSize / 2,
              top: screenY - pinSize / 2,
              child: GestureDetector(
                onTap: () => widget.onSelect(id),
                behavior: HitTestBehavior.opaque,
                child: AnimatedBuilder(
                  animation: _pulseCtrl,
                  builder: (context, _) {
                    return Container(
                      width: pinSize,
                      height: pinSize,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : AppColors.potBlack,
                        border: Border.all(
                          color: isSelected ? AppColors.rubyRed : Colors.white,
                          width: isSelected ? 2.0 : 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isSelected ? AppColors.rubyRed : AppColors.potBlack)
                                .withValues(alpha: isSelected ? 0.35 : 0.2),
                            blurRadius: isSelected ? 6 : 3,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Text(
                        '$id',
                        style: TextStyle(
                          color: isSelected ? AppColors.rubyRed : Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: isSelected ? 11 : 9,
                          fontFamily: 'sans-serif',
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTER DERIVED 100% FROM THE EXACT USER REFERENCE SILHOUETTE
// ─────────────────────────────────────────────────────────────────────────────
class _JavaSilhouettePainter extends CustomPainter {
  const _JavaSilhouettePainter({
    required this.selectedId,
    required this.scale,
    required this.offsetX,
    required this.offsetY,
  });

  final int selectedId;
  final double scale;
  final double offsetX;
  final double offsetY;

  // 1. Banten Polygon
  static const _pts1 = <Offset>[
    Offset(63.4, 28.9),
    Offset(67.8, 28.9),
    Offset(72.1, 36.8),
    Offset(74.3, 36.8),
    Offset(78.6, 30.9),
    Offset(89.5, 36.8),
    Offset(91.6, 34.9),
    Offset(102.5, 34.9),
    Offset(102.5, 111.8),
    Offset(96.0, 111.8),
    Offset(89.5, 107.8),
    Offset(89.5, 99.9),
    Offset(98.1, 92.0),
    Offset(93.8, 86.1),
    Offset(87.3, 90.1),
    Offset(82.9, 90.1),
    Offset(67.8, 80.2),
    Offset(65.6, 82.2),
    Offset(54.7, 82.2),
    Offset(39.5, 86.1),
    Offset(30.9, 86.1),
    Offset(26.5, 82.2),
    Offset(20.0, 84.2),
    Offset(20.0, 78.2),
    Offset(24.3, 74.3),
    Offset(30.9, 72.3),
    Offset(35.2, 80.2),
    Offset(41.7, 72.3),
    Offset(41.7, 64.4),
    Offset(54.7, 60.5),
    Offset(52.6, 48.7),
    Offset(63.4, 28.9),
  ];

  // 2. DKI Jakarta Polygon
  static const _pts2 = <Offset>[
    Offset(122.0, 28.9),
    Offset(128.5, 28.9),
    Offset(128.5, 52.6),
    Offset(104.7, 52.6),
    Offset(104.7, 34.9),
    Offset(106.8, 38.8),
    Offset(113.3, 38.8),
    Offset(115.5, 36.8),
    Offset(119.8, 38.8),
    Offset(122.0, 36.8),
    Offset(122.0, 28.9),
  ];

  // 3. Jawa Barat Polygon
  static const _pts3 = <Offset>[
    Offset(130.7, 28.9),
    Offset(143.7, 28.9),
    Offset(154.6, 40.8),
    Offset(158.9, 40.8),
    Offset(163.3, 44.7),
    Offset(169.8, 40.8),
    Offset(176.3, 40.8),
    Offset(187.1, 46.7),
    Offset(191.5, 46.7),
    Offset(195.8, 42.7),
    Offset(202.3, 42.7),
    Offset(213.2, 52.6),
    Offset(217.5, 64.4),
    Offset(228.4, 72.3),
    Offset(228.4, 121.6),
    Offset(221.9, 121.6),
    Offset(217.5, 127.5),
    Offset(206.7, 129.5),
    Offset(204.5, 127.5),
    Offset(169.8, 123.6),
    Offset(158.9, 115.7),
    Offset(152.4, 113.7),
    Offset(117.7, 113.7),
    Offset(115.5, 111.8),
    Offset(104.7, 111.8),
    Offset(104.7, 54.6),
    Offset(128.5, 54.6),
    Offset(130.7, 52.6),
    Offset(130.7, 28.9),
  ];

  // 4. Jawa Tengah Polygon (Includes iconic Muria Peninsula)
  static const _pts4 = <Offset>[
    Offset(354.3, 42.7),
    Offset(362.9, 42.7),
    Offset(367.3, 46.7),
    Offset(367.3, 145.3),
    Offset(362.9, 143.3),
    Offset(349.9, 143.3),
    Offset(347.8, 141.3),
    Offset(347.8, 119.6),
    Offset(345.6, 117.7),
    Offset(304.3, 117.7),
    Offset(302.2, 119.6),
    Offset(302.2, 125.6),
    Offset(284.8, 123.6),
    Offset(282.6, 121.6),
    Offset(280.5, 123.6),
    Offset(271.8, 123.6),
    Offset(267.4, 119.6),
    Offset(230.5, 121.6),
    Offset(230.5, 72.3),
    Offset(232.7, 70.4),
    Offset(250.1, 70.4),
    Offset(260.9, 74.3),
    Offset(276.1, 68.4),
    Offset(297.8, 74.3),
    Offset(319.5, 70.4),
    Offset(328.2, 76.3),
    Offset(336.9, 70.4),
    Offset(343.4, 58.5),
    Offset(343.4, 48.7),
    Offset(354.3, 42.7),
  ];

  // 5. D.I. Yogyakarta Polygon
  static const _pts5 = <Offset>[
    Offset(304.3, 119.6),
    Offset(345.6, 119.6),
    Offset(345.6, 141.3),
    Offset(306.5, 127.5),
    Offset(304.3, 125.6),
    Offset(304.3, 119.6),
  ];

  // 6. Jawa Timur Mainland Polygon
  static const _pts6 = <Offset>[
    Offset(369.5, 50.6),
    Offset(376.0, 58.5),
    Offset(389.0, 58.5),
    Offset(395.5, 52.6),
    Offset(408.5, 60.5),
    Offset(423.7, 60.5),
    Offset(430.2, 68.4),
    Offset(436.7, 68.4),
    Offset(443.3, 64.4),
    Offset(454.1, 64.4),
    Offset(458.4, 66.4),
    Offset(462.8, 72.3),
    Offset(462.8, 88.1),
    Offset(465.0, 90.1),
    Offset(475.8, 90.1),
    Offset(473.6, 99.9),
    Offset(480.2, 103.9),
    Offset(491.0, 105.8),
    Offset(499.7, 111.8),
    Offset(508.4, 111.8),
    Offset(517.1, 105.8),
    Offset(521.4, 107.8),
    Offset(534.4, 107.8),
    Offset(545.3, 101.9),
    Offset(569.1, 109.8),
    Offset(571.3, 117.7),
    Offset(569.1, 119.6),
    Offset(569.1, 131.5),
    Offset(564.8, 145.3),
    Offset(573.5, 155.1),
    Offset(580.0, 157.1),
    Offset(580.0, 163.0),
    Offset(577.8, 165.0),
    Offset(575.7, 163.0),
    Offset(569.1, 163.0),
    Offset(562.6, 161.1),
    Offset(560.5, 157.1),
    Offset(558.3, 159.1),
    Offset(543.1, 157.1),
    Offset(534.4, 151.2),
    Offset(519.2, 149.2),
    Offset(514.9, 145.3),
    Offset(508.4, 145.3),
    Offset(504.0, 141.3),
    Offset(488.8, 141.3),
    Offset(486.7, 145.3),
    Offset(478.0, 151.2),
    Offset(465.0, 151.2),
    Offset(462.8, 149.2),
    Offset(443.3, 147.3),
    Offset(441.1, 145.3),
    Offset(417.2, 145.3),
    Offset(412.9, 149.2),
    Offset(404.2, 149.2),
    Offset(391.2, 145.3),
    Offset(369.5, 145.3),
    Offset(369.5, 50.6),
  ];

  // Madura Island Polygon (from reference)
  static const _ptsMadura = <Offset>[
    Offset(527.9, 60.5),
    Offset(538.8, 60.5),
    Offset(549.6, 66.4),
    Offset(536.6, 72.3),
    Offset(538.8, 78.2),
    Offset(523.6, 76.3),
    Offset(519.2, 80.2),
    Offset(521.4, 82.2),
    Offset(519.2, 84.2),
    Offset(512.7, 84.2),
    Offset(510.5, 82.2),
    Offset(504.0, 82.2),
    Offset(501.9, 84.2),
    Offset(482.3, 84.2),
    Offset(478.0, 80.2),
    Offset(469.3, 80.2),
    Offset(467.1, 78.2),
    Offset(465.0, 82.2),
    Offset(467.1, 84.2),
    Offset(473.6, 84.2),
    Offset(475.8, 88.1),
    Offset(465.0, 88.1),
    Offset(465.0, 74.3),
    Offset(469.3, 72.3),
    Offset(475.8, 64.4),
    Offset(514.9, 64.4),
    Offset(517.1, 62.5),
    Offset(525.7, 62.5),
    Offset(527.9, 60.5),
  ];

  static Path _buildPolygon(List<Offset> pts) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
    return path;
  }

  static Map<int, Path> buildPaths() {
    final paths = <int, Path>{};
    paths[1] = _buildPolygon(_pts1);
    paths[2] = _buildPolygon(_pts2);
    paths[3] = _buildPolygon(_pts3);
    paths[4] = _buildPolygon(_pts4);
    paths[5] = _buildPolygon(_pts5);

    final jatimMain = _buildPolygon(_pts6);
    final madura = _buildPolygon(_ptsMadura);
    paths[6] = Path.combine(PathOperation.union, jatimMain, madura);

    return paths;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    final paths = buildPaths();

    // 1. Draw subtle ocean halo aura around the coastline
    final waterPaint = Paint()
      ..color = const Color(0xFFE8EEEC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final path in paths.values) {
      canvas.drawPath(path, waterPaint);
    }

    // 2. Draw Unselected Regions (Parchment Paper Fill + Inked Border)
    for (final entry in paths.entries) {
      if (entry.key != selectedId) {
        final fillPaint = Paint()
          ..color = const Color(0xFFFBF9F4)
          ..style = PaintingStyle.fill;
        canvas.drawPath(entry.value, fillPaint);

        final strokePaint = Paint()
          ..color = AppColors.potBlack.withValues(alpha: 0.8)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke;
        canvas.drawPath(entry.value, strokePaint);
      }
    }

    // 3. Draw Selected Region (Rich Ruby Red Fill + Clean Inked Stroke)
    final selectedPath = paths[selectedId];
    if (selectedPath != null) {
      // Glow shadow
      final shadowPaint = Paint()
        ..color = AppColors.rubyRed.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(selectedPath, shadowPaint);

      final selectedFill = Paint()
        ..color = AppColors.rubyRed
        ..style = PaintingStyle.fill;
      canvas.drawPath(selectedPath, selectedFill);

      final selectedStroke = Paint()
        ..color = AppColors.potBlack
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;
      canvas.drawPath(selectedPath, selectedStroke);
    }

    // 4. Draw Hand-Drawn Dividing Lines cleanly between provinces
    final dividerPaint = Paint()
      ..color = AppColors.potBlack
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Line 1: Banten - Jabar boundary
    canvas.drawLine(const Offset(102.5, 34.9), const Offset(102.5, 111.8), dividerPaint);
    // Line 2: Jabar - Jateng boundary
    canvas.drawLine(const Offset(228.4, 72.3), const Offset(228.4, 121.6), dividerPaint);
    // Line 3: Jateng - DIY boundary arch
    canvas.drawLine(const Offset(304.3, 117.7), const Offset(345.6, 117.7), dividerPaint);
    // Line 4: Jateng - Jatim boundary
    canvas.drawLine(const Offset(367.3, 46.7), const Offset(367.3, 145.3), dividerPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _JavaSilhouettePainter oldDelegate) {
    return oldDelegate.selectedId != selectedId ||
        oldDelegate.scale != scale ||
        oldDelegate.offsetX != offsetX ||
        oldDelegate.offsetY != offsetY;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REGION NUMBER PAGINATION BAR: < [1] [2] [3] [4] [5] [6] >
// ─────────────────────────────────────────────────────────────────────────────
class _RegionNumberPagination extends StatelessWidget {
  const _RegionNumberPagination({
    required this.selectedId,
    required this.totalRegions,
    required this.onSelect,
  });

  final int selectedId;
  final int totalRegions;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Left Chevron Arrow
        _NavArrowButton(
          icon: Icons.chevron_left_rounded,
          onTap: () {
            final prev = selectedId > 1 ? selectedId - 1 : totalRegions;
            onSelect(prev);
          },
        ),

        const SizedBox(width: 6),

        // Number Buttons 1..6 (Expanded for flexible layout without overflow)
        ...List.generate(totalRegions, (i) {
          final id = i + 1;
          final isSelected = id == selectedId;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.5),
              child: GestureDetector(
                onTap: () => onSelect(id),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.potBlack : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.potBlack
                          : AppColors.potBlack.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.potBlack.withValues(alpha: 0.22),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$id',
                      style: AppTextStyles.labelLarge(
                        color: isSelected ? Colors.white : AppColors.potBlack,
                      ).copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(width: 6),

        // Right Chevron Arrow
        _NavArrowButton(
          icon: Icons.chevron_right_rounded,
          onTap: () {
            final next = selectedId < totalRegions ? selectedId + 1 : 1;
            onSelect(next);
          },
        ),
      ],
    );
  }
}

class _NavArrowButton extends StatelessWidget {
  const _NavArrowButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.potBlack.withValues(alpha: 0.18),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.potBlack,
          size: 20,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import '../models/aksara_model.dart';

class AksaraGridSection extends StatefulWidget {
  const AksaraGridSection({
    super.key,
    this.onAksaraTap,
  });

  final ValueChanged<AksaraItem>? onAksaraTap;

  @override
  State<AksaraGridSection> createState() => _AksaraGridSectionState();
}

class _AksaraGridSectionState extends State<AksaraGridSection> {
  bool _isPasanganMode = false;
  int? _selectedIndex;

  void _showAksaraDetail(AksaraItem item) {
    setState(() => _selectedIndex = item.index);
    widget.onAksaraTap?.call(item);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AksaraDetailModal(item: item),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Segmented Control: Carakan vs Pasangan (Matching Wireframe)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.potBlack.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.potBlack.withValues(alpha: 0.12),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ModeTabButton(
                  label: 'Carakan',
                  subtitle: 'Nglegena (Utuh)',
                  isActive: !_isPasanganMode,
                  onTap: () => setState(() => _isPasanganMode = false),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _ModeTabButton(
                  label: 'Pasangan',
                  subtitle: 'Mati (Penyambung)',
                  isActive: _isPasanganMode,
                  onTap: () => setState(() => _isPasanganMode = true),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. Contextual Legend Banner
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Container(
            key: ValueKey<bool>(_isPasanganMode),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (_isPasanganMode
                        ? AppColors.goldVarnishBrown
                        : AppColors.mallardish)
                    .withValues(alpha: 0.28),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isPasanganMode
                      ? Icons.layers_outlined
                      : Icons.auto_stories_outlined,
                  size: 18,
                  color: _isPasanganMode
                      ? AppColors.goldVarnishBrown
                      : AppColors.mallardish,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _isPasanganMode
                        ? 'Aksara Pasangan mematikan vokal aksara di depannya. Garis titik menunjukkan posisi aksara dasar.'
                        : '20 Aksara Carakan (Dentawyanjana) bersifat silabik dengan vokal bawaan "-a". Ketuk kotak untuk detail filosofi.',
                    style: AppTextStyles.labelSmall(
                      color: AppColors.potBlack.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 3. 20 Aksara Grid (4 Rows x 5 Columns - 100% Responsive via Expanded)
        ...List.generate(4, (rowIndex) {
          final rowItems = hanacarakaList.sublist(rowIndex * 5, (rowIndex + 1) * 5);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: List.generate(5, (colIndex) {
                final item = rowItems[colIndex];
                final isSelected = _selectedIndex == item.index;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: colIndex == 0 ? 0 : 4,
                      right: colIndex == 4 ? 0 : 4,
                    ),
                    child: _AksaraCardTile(
                      item: item,
                      isPasanganMode: _isPasanganMode,
                      isSelected: isSelected,
                      onTap: () => _showAksaraDetail(item),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEGMENTED TAB BUTTON (CARAKAN / PASANGAN)
// ─────────────────────────────────────────────────────────────────────────────
class _ModeTabButton extends StatelessWidget {
  const _ModeTabButton({
    required this.label,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(
                  color: AppColors.potBlack.withValues(alpha: 0.15),
                  width: 1.2,
                )
              : null,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.potBlack.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTextStyles.titleSmall(
                color: isActive ? AppColors.potBlack : AppColors.coastalStorm,
              ).copyWith(
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              subtitle,
              style: AppTextStyles.labelSmall(
                color: isActive ? AppColors.rubyRed : AppColors.coastalStorm,
              ).copyWith(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INDIVIDUAL AKSARA BOX TILE (1 of 20)
// ─────────────────────────────────────────────────────────────────────────────
class _AksaraCardTile extends StatelessWidget {
  const _AksaraCardTile({
    required this.item,
    required this.isPasanganMode,
    required this.isSelected,
    required this.onTap,
  });

  final AksaraItem item;
  final bool isPasanganMode;
  final bool isSelected;
  final VoidCallback onTap;

  Offset _getPasanganVisualOffset() {
    switch (item.pasanganPosition) {
      case PasanganPosition.sejajar:
        return const Offset(-7, 2);
      case PasanganPosition.bawahNaik:
        return const Offset(3, -5);
      case PasanganPosition.bawah:
        return const Offset(8, -10);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isInlinePasangan =
        item.pasanganPosition == PasanganPosition.sejajar;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.rubyRed.withValues(alpha: 0.12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 82,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.rubyRed.withValues(alpha: 0.08)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.rubyRed
                  : AppColors.potBlack.withValues(alpha: 0.16),
              width: isSelected ? 1.8 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.potBlack.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Position indicator dot in Pasangan Mode (Sejajar vs Bawah)
              if (isPasanganMode)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isInlinePasangan
                          ? AppColors.rubyRed
                          : AppColors.mallardish.withValues(alpha: 0.6),
                    ),
                  ),
                ),

              // Dotted reference baseline in Pasangan Mode (like Reference Chart Image 2)
              if (isPasanganMode)
                Positioned(
                  left: 10,
                  right: 10,
                  top: isInlinePasangan ? 46 : 20,
                  child: CustomPaint(
                    size: const Size(double.infinity, 1),
                    painter: _DottedLinePainter(
                      color: AppColors.coastalStorm.withValues(alpha: 0.45),
                    ),
                  ),
                ),

              // Main Content: Aksara Glyph + Latin Label
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: isPasanganMode
                              ? Transform.translate(
                                  offset: _getPasanganVisualOffset(),
                                  child: Text(
                                    item.pasanganDisplay,
                                    style: AppTextStyles.aksara(
                                      fontSize: 23,
                                      color: AppColors.potBlack,
                                      height: 1.1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Text(
                                  item.carakan,
                                  style: AppTextStyles.aksara(
                                    fontSize: 23,
                                    color: AppColors.potBlack,
                                    height: 1.1,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.rubyRed
                              : AppColors.background,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isPasanganMode
                              ? item.latinPasangan
                              : item.latinCarakan,
                          style: AppTextStyles.labelSmall(
                            color: isSelected
                                ? Colors.white
                                : AppColors.mallardish,
                          ).copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  const _DottedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      .. strokeCap = StrokeCap.round;

    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + 2, 0), paint);
      x += 5;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedLinePainter oldDelegate) =>
      oldDelegate.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// AKSARA DETAIL MODAL BOTTOM SHEET (FILOSOFI & CONTOH PENGGUNAAN)
// ─────────────────────────────────────────────────────────────────────────────
class _AksaraDetailModal extends StatelessWidget {
  const _AksaraDetailModal({required this.item});

  final AksaraItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.coastalStorm.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header with verse badge & Gendhis avatar
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.goldVarnishBrown.withValues(alpha: 0.12),
                  border: Border.all(
                    color: AppColors.goldVarnishBrown,
                    width: 1.5,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: SvgPicture.asset(
                  'assets/gendhis/gendhis_berpikir.svg',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.mallardish,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'AKSARA #${item.index} • ${item.barisTitle.toUpperCase()}',
                        style: AppTextStyles.labelSmall(
                          color: Colors.white,
                        ).copyWith(fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Aksara "${item.latinCarakan.toUpperCase()}"',
                      style: AppTextStyles.headlineMedium(),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                color: AppColors.coastalStorm,
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Side-by-side Comparison: Carakan vs Pasangan
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.potBlack.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'CARAKAN (UTUH)',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.coastalStorm,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.carakan,
                        style: AppTextStyles.aksara(
                          fontSize: 38,
                          color: AppColors.potBlack,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bunyi: "${item.latinCarakan}"',
                        style: AppTextStyles.labelLarge(
                          color: AppColors.mallardish,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.rubyRed.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'CONTOH PASANGAN',
                        style: AppTextStyles.labelSmall(
                          color: AppColors.rubyRed,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.pasanganInContext,
                        style: AppTextStyles.aksara(
                          fontSize: 38,
                          color: AppColors.rubyRed,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'nan + ${item.latinCarakan} → "n${item.latinCarakan}"',
                        style: AppTextStyles.labelLarge(
                          color: AppColors.potBlack,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Pasangan placement rule & Example word
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.goldVarnishBrown.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.goldVarnishBrown.withValues(alpha: 0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.rule_rounded,
                      size: 16,
                      color: AppColors.goldVarnishBrown,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Posisi Pasangan: ${item.pasanganPosition.description}',
                        style: AppTextStyles.labelLarge(
                          color: AppColors.potBlack,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contoh Kosakata:',
                          style: AppTextStyles.labelSmall(
                            color: AppColors.coastalStorm,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.exampleLatin} (${item.exampleMeaning})',
                          style: AppTextStyles.titleSmall(),
                        ),
                      ],
                    ),
                    Text(
                      item.exampleAksara,
                      style: AppTextStyles.aksara(
                        fontSize: 24,
                        color: AppColors.rubyRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Philosophical Meaning
          Text(
            'Filosofi Bait "${item.barisTitle}": ${item.barisMeaning}.',
            style: AppTextStyles.bodyMedium(color: AppColors.coastalStorm),
          ),
        ],
      ),
    );
  }
}


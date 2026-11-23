import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/data/facts_data.dart';

class TahukahKamuSection extends StatelessWidget {
  const TahukahKamuSection({super.key});

  static const int _displayCount = 6;

  @override
  Widget build(BuildContext context) {
    final displayed = allFacts.take(_displayCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text('Tahukah kamu?', style: AppTextStyles.titleMedium()),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Text(
            'Ketuk kartu untuk mengungkap fakta uniknya!',
            style: AppTextStyles.bodyMedium(),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.only(right: 20),
            itemCount: displayed.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) => _FlipCard(fact: displayed[index]),
          ),
        ),
      ],
    );
  }
}

class _FlipCard extends StatefulWidget {
  const _FlipCard({required this.fact});
  final FactItem fact;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _rotation;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _rotation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _flip() {
    if (_ctrl.isAnimating) return;
    if (_showBack) {
      _ctrl.reverse().then((_) => setState(() => _showBack = false));
    } else {
      _ctrl.forward().then((_) => setState(() => _showBack = true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: _flip,
        child: AnimatedBuilder(
          animation: _rotation,
          builder: (context, _) {
            final showFront = _rotation.value <= pi / 2;
            final textFlip = showFront ? 0.0 : pi;

            return Transform(
              transform: Matrix4.rotationY(_rotation.value),
              alignment: Alignment.center,
              child: Transform(
                transform: Matrix4.rotationY(textFlip),
                alignment: Alignment.center,
                child: showFront
                    ? _CardFront(fact: widget.fact)
                    : _CardBack(fact: widget.fact),
              ),
            );
          },
        ),
      ),
    );
  }
}

const double _cardWidth = 180;
const double _cardHeight = 240;
const double _cardRadius = 16;

class _CardFront extends StatelessWidget {
  const _CardFront({required this.fact});
  final FactItem fact;

  @override
  Widget build(BuildContext context) {
    final accent = fact.accentColor;

    return Container(
      width: _cardWidth,
      height: _cardHeight,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.potBlack.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _CategoryPill(label: fact.category, color: accent),
          const SizedBox(height: 12),
          Icon(Icons.help_outline_rounded, color: accent, size: 26),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              fact.question,
              style: AppTextStyles.bodyMedium(color: AppColors.potBlack),
              overflow: TextOverflow.fade,
            ),
          ),
          const SizedBox(height: 8),
          _HintRow(
            icon: Icons.touch_app_rounded,
            label: 'Ketuk untuk jawaban',
            color: AppColors.coastalStorm,
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.fact});
  final FactItem fact;

  @override
  Widget build(BuildContext context) {
    final accent = fact.accentColor;

    return Container(
      width: _cardWidth,
      height: _cardHeight,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.potBlack.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded, color: Colors.white70, size: 15),
              const SizedBox(width: 5),
              Text('Jawaban', style: AppTextStyles.labelLarge(color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Text(
                fact.answer,
                style: AppTextStyles.bodyMedium(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _HintRow(
            icon: Icons.refresh_rounded,
            label: 'Ketuk untuk kembali',
            color: Colors.white60,
          ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: AppTextStyles.labelSmall(color: Colors.white)),
    );
  }
}

class _HintRow extends StatelessWidget {
  const _HintRow({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.labelSmall(color: color)),
      ],
    );
  }
}

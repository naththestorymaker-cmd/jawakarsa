import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';


class _Fact {
  const _Fact({required this.question, required this.answer, required this.category});
  final String question;
  final String answer;
  final String category;
}

const _facts = [
  _Fact(
    category: 'Bahasa',
    question: 'Tahukah kamu ada berapa tingkatan bahasa dalam Bahasa Jawa?',
    answer:
        'Bahasa Jawa memiliki 3 tingkatan utama: Ngoko (akrab), Madya (semi-formal), dan Krama (formal/hormat). Ini mencerminkan filosofi Jawa tentang tata krama.',
  ),
  _Fact(
    category: 'Wayang',
    question: 'Sejak kapan pertunjukan Wayang Kulit diakui dunia?',
    answer:
        'UNESCO mengakui Wayang Kulit sebagai Masterpiece of Oral and Intangible Heritage of Humanity pada tahun 2003. Pertunjukan semalam suntuk bisa berlangsung hingga 8 jam!',
  ),
  _Fact(
    category: 'Batik',
    question: 'Apakah motif batik Parang punya pantangan tersendiri?',
    answer:
        'Ya! Motif Parang secara tradisional hanya boleh dikenakan oleh keluarga kerajaan Jawa. Kini aturan tersebut sudah lebih longgar, tapi saat di keraton tetap dihormati.',
  ),
  _Fact(
    category: 'Arsitektur',
    question: 'Mengapa puncak Gedung Sate di Bandung disebut "sate"?',
    answer:
        'Ornamen di puncak Gedung Sate berbentuk 6 tusuk sate yang melambangkan 6 juta gulden — biaya pembangunannya pada tahun 1920. Nama "sate" muncul dari lidah rakyat setempat.',
  ),
  _Fact(
    category: 'Kuliner',
    question: 'Dari mana asal-usul nama "Gudeg" makanan khas Yogyakarta?',
    answer:
        'Nama Gudeg berasal dari kata "hangudeg" dalam bahasa Jawa yang berarti mengaduk. Merujuk pada proses memasak nangka muda yang diaduk terus-menerus selama berjam-jam.',
  ),
];


class TahukahKamuSection extends StatelessWidget {
  const TahukahKamuSection({super.key});

  @override
  Widget build(BuildContext context) {
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
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 20),
            itemCount: _facts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _FlipCard(fact: _facts[index]),
          ),
        ),
      ],
    );
  }
}


class _FlipCard extends StatefulWidget {
  const _FlipCard({required this.fact});
  final _Fact fact;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _rotation;
  bool _showBack = false;

  static const _categoryColors = {
    'Bahasa': AppColors.mallardish,
    'Wayang': AppColors.rubyRed,
    'Batik': AppColors.goldVarnishBrown,
    'Arsitektur': AppColors.mallardish,
    'Kuliner': AppColors.rubyRed,
  };

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
    final accent =
        _categoryColors[widget.fact.category] ?? AppColors.goldVarnishBrown;

    return GestureDetector(
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
                  ? _CardFront(fact: widget.fact, accent: accent)
                  : _CardBack(fact: widget.fact, accent: accent),
            ),
          );
        },
      ),
    );
  }
}



class _CardFront extends StatelessWidget {
  const _CardFront({required this.fact, required this.accent});
  final _Fact fact;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              fact.category,
              style: AppTextStyles.labelSmall(color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),

          Icon(Icons.help_outline_rounded, color: accent, size: 28),
          const SizedBox(height: 8),

          Expanded(
            child: Text(
              fact.question,
              style: AppTextStyles.bodyMedium(color: AppColors.potBlack),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}



class _CardBack extends StatelessWidget {
  const _CardBack({required this.fact, required this.accent});
  final _Fact fact;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(16),
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
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 5),
              Text(
                'Jawaban',
                style: AppTextStyles.labelLarge(color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Expanded(
            child: Text(
              fact.answer,
              style: AppTextStyles.bodyMedium(color: Colors.white),
              overflow: TextOverflow.fade,
            ),
          ),

          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.refresh_rounded, size: 12, color: Colors.white60),
              const SizedBox(width: 4),
              Text(
                'Ketuk untuk kembali',
                style: AppTextStyles.labelSmall(color: Colors.white60),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';

enum GendhisEmotion { ramah, semangat, berpikir, bangga, semangati }

class GendhisCommentator extends StatefulWidget {
  const GendhisCommentator({super.key});

  static GendhisCommentatorState? of(BuildContext context) =>
      context.findAncestorStateOfType<GendhisCommentatorState>();

  @override
  State<GendhisCommentator> createState() => GendhisCommentatorState();
}

class GendhisCommentatorState extends State<GendhisCommentator>
    with SingleTickerProviderStateMixin {
  String? _comment;
  GendhisEmotion _emotion = GendhisEmotion.ramah;
  late AnimationController _ctrl;
  late Animation<double> _fade;
  Timer? _hideTimer;

  static const _svgMap = {
    GendhisEmotion.ramah: 'assets/gendhis/gendhis_ramah.svg',
    GendhisEmotion.semangat: 'assets/gendhis/gendhis_semangat.svg',
    GendhisEmotion.berpikir: 'assets/gendhis/gendhis_berpikir.svg',
    GendhisEmotion.bangga: 'assets/gendhis/gendhis_bangga.svg',
    GendhisEmotion.semangati: 'assets/gendhis/gendhis_semangati.svg',
  };

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void show(
    String comment,
    GendhisEmotion emotion, {
    Duration duration = const Duration(seconds: 3),
  }) {
    _hideTimer?.cancel();
    setState(() {
      _comment = comment;
      _emotion = emotion;
    });
    _ctrl.forward(from: 0);
    _hideTimer = Timer(duration, () {
      if (mounted) _ctrl.reverse();
    });
  }

  void correct() => show(
    _correctMessages[DateTime.now().millisecond % _correctMessages.length],
    GendhisEmotion.bangga,
  );

  void wrong() => show(
    _wrongMessages[DateTime.now().millisecond % _wrongMessages.length],
    GendhisEmotion.semangati,
  );

  void thinking() => show(
    _thinkingMessages[DateTime.now().millisecond % _thinkingMessages.length],
    GendhisEmotion.berpikir,
    duration: const Duration(seconds: 4),
  );

  void completed(int score) => show(
    'Luar biasa! Kamu dapat $score poin! 🎉',
    GendhisEmotion.bangga,
    duration: const Duration(seconds: 5),
  );

  static const _correctMessages = [
    'Betul sekali! Penak tenan! 🎊',
    'Wah, pinter banget kamu!',
    'Mantap! Teruskan semangatmu!',
    'Bener! Kamu memang jago!',
    'Bagus banget! Gendhis bangga!',
  ];

  static const _wrongMessages = [
    'Belum tepat, coba lagi ya!',
    'Hm, hampir... semangat!',
    'Jangan menyerah! Gendhis yakin kamu bisa!',
    'Salah dikit, tapi kamu pasti bisa!',
    'Yuk coba lagi, kamu pasti berhasil!',
  ];

  static const _thinkingMessages = [
    'Hmm... sepertinya kamu sedang mikir keras nih 🤔',
    'Jangan terburu-buru, pikirkan baik-baik...',
    'Kayak lama banget nih, butuh petunjuk?',
    'Kalau bingung, coba ingat-ingat lagi ya!',
  ];

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      right: 12,
      child: FadeTransition(
        opacity: _fade,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_comment != null)
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 160),
                child: Container(
                  margin: const EdgeInsets.only(right: 8, top: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.potBlack,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.potBlack.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _comment!,
                    style: AppTextStyles.labelSmall(color: Colors.white),
                  ),
                ),
              ),
            SvgPicture.asset(
              _svgMap[_emotion]!,
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import 'package:jawakarsa/services/gendhis_voice_service.dart';

class GendhisTourStep {
  const GendhisTourStep({
    required this.tabIndex,
    required this.alignLeft,
    required this.svgAsset,
    required this.badge,
    required this.title,
    required this.message,
    required this.audioAsset,
  });

  final int tabIndex;
  final bool alignLeft;
  final String svgAsset;
  final String badge;
  final String title;
  final String message;
  final String audioAsset;
}

const List<GendhisTourStep> gendhisTourSteps = [
  GendhisTourStep(
    tabIndex: 0,
    alignLeft: true,
    svgAsset: 'assets/gendhis/gendhis_ramah.svg',
    badge: 'SALAM KENAL',
    title: 'Sugeng Rawuh di JawaKarsa!',
    message:
        'Aku Gendhis, pemandu budaya Jawamu. Yuk, aku kenalkan fitur-fitur seru di aplikasi ini!',
    audioAsset: 'assets/audio/tour/tour_01_welcome.mp3',
  ),
  GendhisTourStep(
    tabIndex: 0,
    alignLeft: false,
    svgAsset: 'assets/gendhis/gendhis_semangat.svg',
    badge: 'BERANDA & CARI',
    title: 'Jelajah & Pencarian Budaya',
    message:
        'Di halaman Beranda ini, kamu bisa mencari budaya Jawa apa saja, membaca fakta singkat, serta menikmati foto, audio, dan video interaktif.',
    audioAsset: 'assets/audio/tour/tour_02_home.mp3',
  ),
  GendhisTourStep(
    tabIndex: 1,
    alignLeft: true,
    svgAsset: 'assets/gendhis/gendhis_berpikir.svg',
    badge: 'KAWRUH AKSARA',
    title: 'Belajar 20 Hanacaraka Bersuara',
    message:
        'Geser ke tab Kawruh untuk belajar dua puluh aksara Hanacaraka lengkap dengan suara penjelasan dan membuat Kartu Nama Aksara Jawamu sendiri.',
    audioAsset: 'assets/audio/tour/tour_03_kawruh.mp3',
  ),
  GendhisTourStep(
    tabIndex: 2,
    alignLeft: false,
    svgAsset: 'assets/gendhis/gendhis_semangat.svg',
    badge: 'PETA DOLAN',
    title: 'Eksplorasi Pulau Jawa',
    message:
        'Buka tab Dolan untuk menjelajah peta Pulau Jawa, menemukan cagar budaya dan kuliner legendaris, atau mencoba tombol Acak Dolan.',
    audioAsset: 'assets/audio/tour/tour_04_dolan.mp3',
  ),
  GendhisTourStep(
    tabIndex: 3,
    alignLeft: true,
    svgAsset: 'assets/gendhis/gendhis_bangga.svg',
    badge: 'DOLANAN',
    title: 'Tiga Mini-Game Seru!',
    message:
        'Terakhir, uji kemampuanmu lewat tiga permainan seru di Dolanan: Kanvas Aksara, TTS Jawa, dan Cocokologi. Selamat menjelajah budaya Jawa!',
    audioAsset: 'assets/audio/tour/tour_05_dolanan.mp3',
  ),
];

class GendhisTourOverlay extends StatefulWidget {
  const GendhisTourOverlay({
    super.key,
    required this.onSwitchTab,
    required this.onFinish,
    this.startWithPrompt = true,
  });

  final ValueChanged<int> onSwitchTab;
  final VoidCallback onFinish;
  final bool startWithPrompt;

  @override
  State<GendhisTourOverlay> createState() => _GendhisTourOverlayState();
}

class _GendhisTourOverlayState extends State<GendhisTourOverlay>
    with SingleTickerProviderStateMixin {
  int _stepIndex = 0;
  late bool _showingPrompt;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _showingPrompt = widget.startWithPrompt;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    if (!_showingPrompt) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _activateStep(0);
      });
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    GendhisVoiceService.instance.stop();
    super.dispose();
  }

  void _startGuidedTour() {
    setState(() {
      _showingPrompt = false;
      _stepIndex = 0;
    });
    _activateStep(0);
  }

  void _activateStep(int idx) {
    final step = gendhisTourSteps[idx];
    widget.onSwitchTab(step.tabIndex);
    GendhisVoiceService.instance.playAsset(step.audioAsset);
  }

  void _goToStep(int nextIdx) {
    if (nextIdx < 0 || nextIdx >= gendhisTourSteps.length) return;
    setState(() => _stepIndex = nextIdx);
    _activateStep(nextIdx);
  }

  void _replayAudio() {
    final step = gendhisTourSteps[_stepIndex];
    GendhisVoiceService.instance.playAsset(step.audioAsset, ignoreMute: true);
  }

  void _finishTour() {
    GendhisVoiceService.instance.stop();
    widget.onFinish();
  }

  Widget _buildChoicePrompt(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.goldVarnishBrown.withValues(alpha: 0.45),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.potBlack.withValues(alpha: 0.24),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 86,
                  height: 94,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.goldVarnishBrown,
                      width: 2,
                    ),
                  ),
                  child: SvgPicture.asset(
                    'assets/gendhis/gendhis_ramah.svg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.rubyRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'PEMANDU BUDAYA',
                    style: AppTextStyles.labelSmall(
                      color: AppColors.rubyRed,
                    ).copyWith(fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jelajah Bareng Gendhis?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleLarge(
                    color: AppColors.potBlack,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mau ditemani Gendhis berkeliling mengenal fitur JawaKarsa dengan panduan suara, atau langsung eksplor sendiri?',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(
                    color: AppColors.potBlack.withValues(alpha: 0.8),
                  ).copyWith(height: 1.45),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _finishTour,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.coastalStorm,
                          side: BorderSide(
                            color: AppColors.coastalStorm.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Eksplor Sendiri',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLarge(
                            color: AppColors.coastalStorm,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _startGuidedTour,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.rubyRed,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Ditemani Gendhis',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelLarge(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = gendhisTourSteps[_stepIndex];
    final voice = GendhisVoiceService.instance;
    final bottomPad = MediaQuery.viewPaddingOf(context).bottom;
    final isLast = _stepIndex == gendhisTourSteps.length - 1;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: ColoredBox(
                color: AppColors.potBlack.withValues(alpha: 0.48),
              ),
            ),
          ),
          if (_showingPrompt)
            Positioned.fill(child: _buildChoicePrompt(context))
          else
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomPad + 92,
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  voice.isPlaying,
                  voice.activeAsset,
                  voice.isMuted,
                ]),
                builder: (context, _) {
                  final isStepPlaying =
                      voice.isPlaying.value &&
                      voice.activeAsset.value == step.audioAsset;
                  final isMuted = voice.isMuted.value;

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: step.alignLeft
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 320),
                        curve: Curves.easeOutCubic,
                        alignment: step.alignLeft
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _GendhisMascotAvatar(
                            svgAsset: step.svgAsset,
                            isSpeaking: isStepPlaying,
                            pulseCtrl: _pulseCtrl,
                            keyName:
                                '${step.alignLeft ? 'left' : 'right'}_$_stepIndex',
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 240),
                        switchInCurve: Curves.easeOutCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: Offset(
                                step.alignLeft ? -0.04 : 0.04,
                                0.04,
                              ),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: Container(
                          key: ValueKey<int>(_stepIndex),
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(step.alignLeft ? 6 : 22),
                              topRight: Radius.circular(
                                step.alignLeft ? 22 : 6,
                              ),
                              bottomLeft: const Radius.circular(22),
                              bottomRight: const Radius.circular(22),
                            ),
                            border: Border.all(
                              color: AppColors.goldVarnishBrown.withValues(
                                alpha: 0.45,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.potBlack.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.rubyRed.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          '${_stepIndex + 1}/${gendhisTourSteps.length} • ${step.badge}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              AppTextStyles.labelSmall(
                                                color: AppColors.rubyRed,
                                              ).copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    tooltip: 'Putar ulang suara Gendhis',
                                    onPressed: _replayAudio,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    icon: const Icon(
                                      Icons.replay_rounded,
                                      size: 18,
                                      color: AppColors.mallardish,
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: isMuted
                                        ? 'Nyalakan suara'
                                        : 'Bisukan suara',
                                    onPressed: () => voice.toggleMute(),
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 28,
                                      minHeight: 28,
                                    ),
                                    icon: Icon(
                                      isMuted
                                          ? Icons.volume_off_rounded
                                          : Icons.volume_up_rounded,
                                      size: 18,
                                      color: isMuted
                                          ? AppColors.coastalStorm
                                          : AppColors.goldVarnishBrown,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _finishTour,
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                      ),
                                      minimumSize: const Size(0, 28),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Lewati',
                                      style: AppTextStyles.labelSmall(
                                        color: AppColors.coastalStorm,
                                      ).copyWith(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                step.title,
                                style: AppTextStyles.titleMedium(
                                  color: AppColors.potBlack,
                                ).copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                step.message,
                                style: AppTextStyles.bodyMedium(
                                  color: AppColors.potBlack.withValues(
                                    alpha: 0.82,
                                  ),
                                ).copyWith(height: 1.45),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: List.generate(
                                      gendhisTourSteps.length,
                                      (i) => AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        margin: const EdgeInsets.only(right: 4),
                                        width: i == _stepIndex ? 14 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: i == _stepIndex
                                              ? AppColors.rubyRed
                                              : AppColors.coastalStorm
                                                    .withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Wrap(
                                      alignment: WrapAlignment.end,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        if (_stepIndex > 0)
                                          TextButton(
                                            onPressed: () =>
                                                _goToStep(_stepIndex - 1),
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  AppColors.coastalStorm,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              minimumSize: const Size(0, 36),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: const Text('Sebelumnya'),
                                          ),
                                        ElevatedButton(
                                          onPressed: isLast
                                              ? _finishTour
                                              : () => _goToStep(_stepIndex + 1),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isLast
                                                ? AppColors.mallardish
                                                : AppColors.rubyRed,
                                            foregroundColor: Colors.white,
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 9,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            isLast
                                                ? 'Mulai Jelajah!'
                                                : 'Lanjut',
                                            style: AppTextStyles.labelLarge(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _GendhisMascotAvatar extends StatelessWidget {
  const _GendhisMascotAvatar({
    required this.svgAsset,
    required this.isSpeaking,
    required this.pulseCtrl,
    required this.keyName,
  });

  final String svgAsset;
  final bool isSpeaking;
  final AnimationController pulseCtrl;
  final String keyName;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (context, child) {
        final bobOffset = isSpeaking ? -4.0 * pulseCtrl.value : 0.0;
        final ringScale = isSpeaking ? 1.0 + 0.08 * pulseCtrl.value : 1.0;

        return Transform.translate(
          offset: Offset(0, bobOffset),
          child: Transform.scale(
            scale: ringScale,
            child: Container(
              width: 78,
              height: 86,
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSpeaking
                      ? AppColors.rubyRed
                      : AppColors.goldVarnishBrown,
                  width: 2.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        (isSpeaking
                                ? AppColors.rubyRed
                                : AppColors.goldVarnishBrown)
                            .withValues(alpha: isSpeaking ? 0.35 : 0.2),
                    blurRadius: isSpeaking ? 16 : 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SvgPicture.asset(
                svgAsset,
                key: ValueKey<String>(keyName),
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
}

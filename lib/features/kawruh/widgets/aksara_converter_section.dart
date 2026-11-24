import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jawakarsa/core/app_colors.dart';
import 'package:jawakarsa/core/app_text_styles.dart';
import '../models/aksara_model.dart';

enum KartuNamaTheme {
  lontarKlasik(
    label: 'Lontar Klasik',
    bgColor: AppColors.surface,
    borderColor: AppColors.goldVarnishBrown,
    aksaraColor: AppColors.potBlack,
    latinColor: AppColors.mallardish,
    accentColor: AppColors.rubyRed,
  ),
  keratonHitam(
    label: 'Keraton Hitam',
    bgColor: AppColors.potBlack,
    borderColor: AppColors.goldVarnishBrown,
    aksaraColor: AppColors.surface,
    latinColor: AppColors.goldVarnishBrown,
    accentColor: AppColors.goldVarnishBrown,
  ),
  prabuMerah(
    label: 'Prabu Merah',
    bgColor: AppColors.rubyRed,
    borderColor: AppColors.goldVarnishBrown,
    aksaraColor: Colors.white,
    latinColor: AppColors.surface,
    accentColor: AppColors.goldVarnishBrown,
  );

  const KartuNamaTheme({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.aksaraColor,
    required this.latinColor,
    required this.accentColor,
  });

  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color aksaraColor;
  final Color latinColor;
  final Color accentColor;
}

class AksaraConverterSection extends StatefulWidget {
  const AksaraConverterSection({super.key});

  @override
  State<AksaraConverterSection> createState() => _AksaraConverterSectionState();
}

class _AksaraConverterSectionState extends State<AksaraConverterSection> {
  late final TextEditingController _controller;
  String _inputText = 'Penjelajah JawaKarsa';
  KartuNamaTheme _selectedTheme = KartuNamaTheme.lontarKlasik;

  static const List<String> _quickPresets = [
    'Penjelajah',
    'JawaKarsa',
    'Bagaskara',
    'Gendhis Ayu',
    'Nusantara Jaya',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _inputText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _computeAdaptiveAksaraFontSize(int latinLength) {
    if (latinLength <= 10) return 32;
    if (latinLength <= 18) return 27;
    if (latinLength <= 28) return 23;
    if (latinLength <= 42) return 20;
    return 17;
  }

  void _copyAksaraToClipboard(String aksaraText) {
    if (aksaraText.isEmpty) return;
    final framedText = '꧋ $aksaraText ꧋';
    Clipboard.setData(ClipboardData(text: framedText));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.potBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.goldVarnishBrown,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Aksara Jawa "$framedText" berhasil disalin!',
                style: AppTextStyles.bodyMedium(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSaveKartuNama(String latinText, String aksaraText) {
    if (aksaraText.isEmpty) return;
    final framedText = '꧋ $aksaraText ꧋';
    Clipboard.setData(ClipboardData(text: framedText));

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _KartuNamaExportSheet(
        latinName: latinText,
        aksaraText: aksaraText,
        theme: _selectedTheme,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmedInput = _inputText.trim();
    final aksaraOutput = AksaraTransliterator.toJavanese(trimmedInput);
    final hasInput = trimmedInput.isNotEmpty && aksaraOutput.isNotEmpty;
    final adaptiveFontSize = _computeAdaptiveAksaraFontSize(
      trimmedInput.length,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.rubyRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.translate_rounded,
                color: AppColors.rubyRed,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Konverter Latin ke Aksara',
                    style: AppTextStyles.headlineMedium(),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ketik nama atau kata Latin untuk menghasilkan Kartu Nama',
                    style: AppTextStyles.bodyMedium(
                      color: AppColors.coastalStorm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.potBlack.withValues(alpha: 0.22),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.potBlack.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            onChanged: (val) => setState(() => _inputText = val),
            maxLength: 80,
            style: AppTextStyles.titleSmall(color: AppColors.potBlack),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'Ketik namamu atau kalimat di sini...',
              hintStyle: AppTextStyles.bodyMedium(
                color: AppColors.coastalStorm,
              ),
              prefixIcon: const Icon(
                Icons.badge_outlined,
                color: AppColors.mallardish,
                size: 22,
              ),
              suffixIcon: _inputText.isNotEmpty
                  ? IconButton(
                      tooltip: 'Hapus teks',
                      onPressed: () {
                        _controller.clear();
                        setState(() => _inputText = '');
                      },
                      icon: const Icon(
                        Icons.cancel_rounded,
                        color: AppColors.coastalStorm,
                        size: 20,
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              Text(
                'Coba Cepat:',
                style: AppTextStyles.labelSmall(
                  color: AppColors.coastalStorm,
                ).copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              ..._quickPresets.map((preset) {
                final isCurrent =
                    _inputText.trim().toLowerCase() == preset.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: GestureDetector(
                    onTap: () {
                      _controller.text = preset;
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: preset.length),
                      );
                      setState(() => _inputText = preset);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? AppColors.mallardish
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isCurrent
                              ? AppColors.mallardish
                              : AppColors.potBlack.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Text(
                        preset,
                        style:
                            AppTextStyles.labelSmall(
                              color: isCurrent
                                  ? Colors.white
                                  : AppColors.potBlack.withValues(alpha: 0.8),
                            ).copyWith(
                              fontWeight: isCurrent
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 215),
          decoration: BoxDecoration(
            color: _selectedTheme.bgColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _selectedTheme.borderColor.withValues(alpha: 0.55),
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.potBlack.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _KartuNamaOrnamentPainter(
                      color: _selectedTheme.borderColor.withValues(alpha: 0.18),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedTheme.accentColor.withValues(
                                alpha: 0.14,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedTheme.accentColor.withValues(
                                  alpha: 0.35,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 5),
                                Text(
                                  'KARTU NAMA AKSARA JAWA',
                                  style:
                                      AppTextStyles.labelSmall(
                                        color:
                                            _selectedTheme ==
                                                KartuNamaTheme.lontarKlasik
                                            ? AppColors.rubyRed
                                            : _selectedTheme.accentColor,
                                      ).copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _CardActionButton(
                                icon: Icons.copy_rounded,
                                tooltip: 'Salin Teks Aksara',
                                color: _selectedTheme.aksaraColor,
                                bgColor: _selectedTheme.aksaraColor.withValues(
                                  alpha: 0.08,
                                ),
                                onTap: hasInput
                                    ? () => _copyAksaraToClipboard(aksaraOutput)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              _CardActionButton(
                                icon: Icons.download_rounded,
                                tooltip: 'Unduh / Simpan Kartu Nama',
                                color:
                                    _selectedTheme ==
                                        KartuNamaTheme.lontarKlasik
                                    ? Colors.white
                                    : AppColors.potBlack,
                                bgColor:
                                    _selectedTheme ==
                                        KartuNamaTheme.lontarKlasik
                                    ? AppColors.potBlack
                                    : AppColors.goldVarnishBrown,
                                onTap: hasInput
                                    ? () => _handleSaveKartuNama(
                                        trimmedInput,
                                        aksaraOutput,
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      if (hasInput)
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: SelectableText(
                                '꧋ $aksaraOutput ꧋',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.aksara(
                                  fontSize: adaptiveFontSize,
                                  color: _selectedTheme.aksaraColor,
                                  height: 1.85,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedTheme.aksaraColor.withValues(
                                  alpha: 0.07,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                trimmedInput.toUpperCase(),
                                textAlign: TextAlign.center,
                                style:
                                    AppTextStyles.labelLarge(
                                      color: _selectedTheme.latinColor,
                                    ).copyWith(
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ),
                          ],
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 22),
                          child: Column(
                            children: [
                              Text(
                                '꧋ ... ꧋',
                                style: AppTextStyles.aksara(
                                  fontSize: 28,
                                  color: _selectedTheme.aksaraColor.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Ketik nama di kolom atas untuk melihat pratinjau Aksara Jawa secara otomatis',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.bodyMedium(
                                  color: _selectedTheme.aksaraColor.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: KartuNamaTheme.values.map((theme) {
                              final isSelected = _selectedTheme == theme;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedTheme = theme),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _selectedTheme.aksaraColor
                                                .withValues(alpha: 0.14)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? _selectedTheme.borderColor
                                            : _selectedTheme.aksaraColor
                                                  .withValues(alpha: 0.2),
                                        width: isSelected ? 1.2 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      theme.label,
                                      style:
                                          AppTextStyles.labelSmall(
                                            color: _selectedTheme.aksaraColor
                                                .withValues(
                                                  alpha: isSelected
                                                      ? 0.95
                                                      : 0.65,
                                                ),
                                          ).copyWith(
                                            fontSize: 10,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          if (hasInput)
                            Text(
                              '${trimmedInput.length} huruf',
                              style: AppTextStyles.labelSmall(
                                color: _selectedTheme.aksaraColor.withValues(
                                  alpha: 0.55,
                                ),
                              ).copyWith(fontSize: 10),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CardActionButton extends StatelessWidget {
  const _CardActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Tooltip(
          message: tooltip,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Icon(
              icon,
              size: 19,
              color: onTap != null ? color : color.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

class _KartuNamaOrnamentPainter extends CustomPainter {
  const _KartuNamaOrnamentPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(14),
    );
    canvas.drawRRect(innerRect, paint);

    const double cornerOffset = 16;
    final corners = [
      const Offset(cornerOffset, cornerOffset),
      Offset(size.width - cornerOffset, cornerOffset),
      Offset(cornerOffset, size.height - cornerOffset),
      Offset(size.width - cornerOffset, size.height - cornerOffset),
    ];

    for (final c in corners) {
      canvas.drawCircle(c, 2.5, paint..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(covariant _KartuNamaOrnamentPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _KartuNamaExportSheet extends StatelessWidget {
  const _KartuNamaExportSheet({
    required this.latinName,
    required this.aksaraText,
    required this.theme,
  });

  final String latinName;
  final String aksaraText;
  final KartuNamaTheme theme;

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
        children: [
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.coastalStorm.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.mallardish.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: AppColors.mallardish,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kartu Nama Siap Digunakan',
                      style: AppTextStyles.headlineMedium(),
                    ),
                    Text(
                      'Aksara Jawa juga telah disalin ke papan klip (clipboard)',
                      style: AppTextStyles.labelSmall(
                        color: AppColors.coastalStorm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            decoration: BoxDecoration(
              color: theme.bgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.borderColor, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.potBlack.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'JAWAKARSA • KARTU NAMA BUDAYA',
                  style: AppTextStyles.labelSmall(color: theme.accentColor)
                      .copyWith(
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  '꧋ $aksaraText ꧋',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.aksara(
                    fontSize: latinName.length > 22 ? 22 : 28,
                    color: theme.aksaraColor,
                    height: 1.85,
                  ),
                ),
                const SizedBox(height: 14),
                Divider(
                  color: theme.borderColor.withValues(alpha: 0.35),
                  indent: 32,
                  endIndent: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  latinName.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.titleMedium(
                    color: theme.latinColor,
                  ).copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: Text(
                'Selesai & Tutup',
                style: AppTextStyles.labelLarge(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.potBlack,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

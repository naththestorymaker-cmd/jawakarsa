import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract class AppTextStyles {
  AppTextStyles._();

  static TextStyle displayLarge({Color color = AppColors.potBlack}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.25,
      );

  static TextStyle headlineMedium({Color color = AppColors.potBlack}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  static TextStyle titleLarge({Color color = AppColors.potBlack}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.35,
      );

  static TextStyle titleMedium({Color color = AppColors.potBlack}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle titleSmall({Color color = AppColors.potBlack}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: color,
        height: 1.4,
      );

  static TextStyle bodyLarge({Color color = AppColors.potBlack}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.6,
      );

  static TextStyle bodyMedium({Color color = AppColors.coastalStorm}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: color,
        height: 1.55,
      );

  static TextStyle labelLarge({Color color = AppColors.potBlack}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.2,
        height: 1.4,
      );

  static TextStyle labelSmall({Color color = AppColors.coastalStorm}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: color,
        letterSpacing: 0.1,
        height: 1.4,
      );

  // ── Aksara Jawa (Hanacaraka / Noto Sans Javanese) ─────────────────────────
  /// Font khusus untuk merender Aksara Jawa (Carakan, Pasangan, Sandhangan).
  static TextStyle aksara({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.potBlack,
    double height = 1.6,
  }) =>
      TextStyle(
        fontFamily: 'Hanacaraka',
        fontFamilyFallback: const ['Noto Sans Javanese'],
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      );

  // ── Helper: tema global ───────────────────────────────────────────────────
  /// Pasang ke [ThemeData.textTheme] agar seluruh app inherit font ini.
  static TextTheme get textTheme => GoogleFonts.plusJakartaSansTextTheme();
}

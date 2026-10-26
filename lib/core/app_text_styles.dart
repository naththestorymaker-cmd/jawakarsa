import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tipografi terpusat JawaKarsa — semua menggunakan Plus Jakarta Sans.
///
/// Skala ukuran:
///   displayLarge   28  ExtraBold
///   headlineMedium 22  Bold
///   titleLarge     18  Bold
///   titleMedium    16  SemiBold
///   titleSmall     14  SemiBold
///   bodyLarge      15  Regular
///   bodyMedium     13  Regular
///   labelLarge     12  SemiBold   (tombol, badge, tab aktif)
///   labelSmall     11  Medium     (tab, caption)
abstract class AppTextStyles {
  AppTextStyles._();

  // ── Display ──────────────────────────────────────────────────────────────
  static TextStyle displayLarge({Color color = AppColors.potBlack}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: color,
        height: 1.25,
      );

  // ── Headline ─────────────────────────────────────────────────────────────
  static TextStyle headlineMedium({Color color = AppColors.potBlack}) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: color,
        height: 1.3,
      );

  // ── Title ─────────────────────────────────────────────────────────────────
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

  // ── Body ──────────────────────────────────────────────────────────────────
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

  // ── Label ─────────────────────────────────────────────────────────────────
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

  // ── Helper: tema global ───────────────────────────────────────────────────
  /// Pasang ke [ThemeData.textTheme] agar seluruh app inherit font ini.
  static TextTheme get textTheme => GoogleFonts.plusJakartaSansTextTheme();
}

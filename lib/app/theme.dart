import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Colour Palette ─────────────────────────────────────────────────────────
class AppColors {
  // Primary — deep midnight navy
  static const navy900 = Color(0xFF0D1B2A);
  static const navy800 = Color(0xFF1B2E45);
  static const navy700 = Color(0xFF243D5C);

  // Accent — warm gold
  static const gold400 = Color(0xFFD4A843);
  static const gold300 = Color(0xFFE8C068);
  static const gold200 = Color(0xFFF0D48A);
  static const gold100 = Color(0xFFFAEDC8);

  // Parchment — warm off-whites
  static const parchment100 = Color(0xFFFBF6EC);
  static const parchment200 = Color(0xFFF3E9D2);
  static const parchment300 = Color(0xFFE8D5B0);

  // Semantic
  static const error = Color(0xFFB94A48);
  static const success = Color(0xFF4A7C59);
}

// ── Typography ──────────────────────────────────────────────────────────────
class AppTypography {
  // Display — Playfair Display for headings (editorial, refined)
  static TextStyle display(BuildContext context) => GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle displaySmall(BuildContext context) =>
      GoogleFonts.playfairDisplay(
        fontSize: 24,
        fontWeight: FontWeight.w600,
      );

  // Body — Lora (humanist serif, readable for Quran content)
  static TextStyle body(BuildContext context) =>
      GoogleFonts.lora(fontSize: 16, height: 1.6);

  static TextStyle bodySmall(BuildContext context) =>
      GoogleFonts.lora(fontSize: 13, height: 1.5);

  // Arabic — system fallback chain that covers Uthmanic fonts
  // quran_flutter handles its own font internally
  static const arabicStyle = TextStyle(
    fontFamily: 'Scheherazade New',
    fontSize: 28,
    height: 2.2,
  );

  // Label / UI chrome — Outfit (clean geometric sans)
  static TextStyle label(BuildContext context) =>
      GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w500);

  static TextStyle labelLarge(BuildContext context) =>
      GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w600);
}

// ── Light Theme ─────────────────────────────────────────────────────────────
ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.parchment100,
    colorScheme: const ColorScheme.light(
      primary: AppColors.navy800,
      onPrimary: AppColors.parchment100,
      secondary: AppColors.gold400,
      onSecondary: AppColors.navy900,
      surface: AppColors.parchment100,
      onSurface: AppColors.navy900,
      surfaceContainerHighest: AppColors.parchment200,
      outline: AppColors.parchment300,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy800,
      foregroundColor: AppColors.parchment100,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.parchment300, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.parchment300,
      thickness: 1,
    ),
  );
}

// ── Dark Theme ───────────────────────────────────────────────────────────────
ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.navy900,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold400,
      onPrimary: AppColors.navy900,
      secondary: AppColors.gold300,
      onSecondary: AppColors.navy900,
      surface: AppColors.navy800,
      onSurface: AppColors.parchment100,
      surfaceContainerHighest: AppColors.navy700,
      outline: AppColors.navy700,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy900,
      foregroundColor: AppColors.parchment100,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardThemeData(
      color: AppColors.navy800,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.navy700, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.navy700,
      thickness: 1,
    ),
  );
}

// ── Theme Extensions ─────────────────────────────────────────────────────────
extension AppThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get textColor => isDark ? AppColors.parchment100 : AppColors.navy900;
  Color get subtleTextColor =>
      isDark ? AppColors.parchment300 : AppColors.navy700;
  Color get goldColor => AppColors.gold400;
  Color get surfaceColor => isDark ? AppColors.navy800 : Colors.white;
}

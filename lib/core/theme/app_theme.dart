// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // ─── Light Mode ──────────────────────────────────────────────────────────────
  static const background = Color(0xFFF5F0E8);   // Sand/Cream
  static const foreground = Color(0xFF1A2332);   // Deep Indigo
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFD9CCB5);
  static const primary = Color(0xFF0D6B45);      // Emerald green
  static const primaryFg = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFE8DFC8);
  static const secondaryFg = Color(0xFF1A2332);
  static const muted = Color(0xFFE8DFC8);
  static const mutedFg = Color(0xFF5A6A7A);
  static const accent = Color(0xFFB8932A);       // Muted Gold
  static const accentFg = Color(0xFFFFFFFF);
  static const destructive = Color(0xFFCC3333);
  static const destructiveFg = Color(0xFFFFFFFF);

  // ─── Heatmap gradient ────────────────────────────────────────────────────────
  static const heatmap0 = Color(0xFFE8DFC8);
  static const heatmap1 = Color(0xFFB3D9C4);
  static const heatmap2 = Color(0xFF6DB89A);
  static const heatmap3 = Color(0xFF3D9970);
  static const heatmap4 = Color(0xFF0D6B45);

  // ─── Dark Mode ───────────────────────────────────────────────────────────────
  static const darkBackground = Color(0xFF0F1621);
  static const darkCard = Color(0xFF1A2535);
  static const darkBorder = Color(0xFF2A3545);
  static const darkPrimary = Color(0xFFB8932A);  // Gold in dark mode
  static const darkPrimaryFg = Color(0xFF0F1621);
  static const darkMutedFg = Color(0xFF7A8A9A);
}

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          onPrimary: AppColors.primaryFg,
          secondary: AppColors.accent,
          onSecondary: AppColors.accentFg,
          surface: AppColors.card,
          onSurface: AppColors.foreground,
          error: AppColors.destructive,
          onError: AppColors.destructiveFg,
          outline: AppColors.border,
        ),
        textTheme: _buildTextTheme(Brightness.light),
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.foreground,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryFg,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 0.5,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: Color(0xFFCDE8DA),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.mutedFg,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkPrimary,
          onPrimary: AppColors.darkPrimaryFg,
          secondary: AppColors.primary,
          onSecondary: AppColors.primaryFg,
          surface: AppColors.darkCard,
          onSurface: Color(0xFFF5F0E8),
          error: Color(0xFFE05050),
          outline: AppColors.darkBorder,
        ),
        textTheme: _buildTextTheme(Brightness.dark),
        cardTheme: CardThemeData(
          color: AppColors.darkCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBorder, width: 0.5),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          foregroundColor: Color(0xFFF5F0E8),
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.darkCard,
          selectedItemColor: AppColors.darkPrimary,
          unselectedItemColor: AppColors.darkMutedFg,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
        ),
      );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? AppColors.foreground : const Color(0xFFF5F0E8);
    return TextTheme(
      displayLarge: GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w700, color: color),
      displayMedium: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w700, color: color),
      displaySmall: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: color),
      headlineLarge: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: color),
      headlineMedium: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w600, color: color),
      headlineSmall: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: color),
      titleMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: color),
      titleSmall: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      bodyLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      bodySmall: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, color: color),
      labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: color),
      labelMedium: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      labelSmall: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w500, color: color),
    );
  }
}
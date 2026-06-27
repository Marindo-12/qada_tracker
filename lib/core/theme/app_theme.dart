// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─── Enum des thèmes disponibles ─────────────────────────────────────────────
enum AppColorTheme { green, blue, gold }

class AppColors {
  // ════════════════════════════════════════════════════════════════════════════
  // THÈME 1 — Vert Émeraude + Or (thème original)
  // ════════════════════════════════════════════════════════════════════════════
  static const background    = Color(0xFFF5F0E8);
  static const foreground    = Color(0xFF1A2332);
  static const card          = Color(0xFFFFFFFF);
  static const border        = Color(0xFFD9CCB5);
  static const primary       = Color(0xFF0D6B45); // Emerald green
  static const primaryFg     = Color(0xFFFFFFFF);
  static const secondary     = Color(0xFFE8DFC8);
  static const secondaryFg   = Color(0xFF1A2332);
  static const muted         = Color(0xFFE8DFC8);
  static const mutedFg       = Color(0xFF5A6A7A);
  static const accent        = Color(0xFFB8932A); // Muted Gold
  static const accentFg      = Color(0xFFFFFFFF);
  static const destructive   = Color(0xFFCC3333);
  static const destructiveFg = Color(0xFFFFFFFF);

  // Heatmap gradient (vert)
  static const heatmap0 = Color(0xFFE8DFC8);
  static const heatmap1 = Color(0xFFB3D9C4);
  static const heatmap2 = Color(0xFF6DB89A);
  static const heatmap3 = Color(0xFF3D9970);
  static const heatmap4 = Color(0xFF0D6B45);

  // Dark — Vert
  static const darkBackground = Color(0xFF0F1621);
  static const darkCard       = Color(0xFF1A2535);
  static const darkBorder     = Color(0xFF2A3545);
  static const darkPrimary    = Color(0xFFB8932A); // Gold in dark mode
  static const darkPrimaryFg  = Color(0xFF0F1621);
  static const darkMutedFg    = Color(0xFFC7BFAE);
  static const darkMuted      = Color(0xFF263447);
  static const darkGreen      = Color(0xFF0D6B45);

  // ════════════════════════════════════════════════════════════════════════════
  // THÈME 2 — Bleu + Neutres (iOS/Material style)
  // ════════════════════════════════════════════════════════════════════════════
  // Light
  static const blueBackground   = Color(0xFFF8F9FA);
  static const blueSurface      = Color(0xFFFFFFFF);
  static const blueSurfaceAlt   = Color(0xFFF1EFF8);
  static const bluePrimary      = Color(0xFF378ADD);
  static const bluePrimaryHover = Color(0xFF185FA5);
  static const bluePrimaryLight = Color(0xFFE6F1FB);
  static const bluePrimaryMid   = Color(0xFFB5D4F4);
  static const bluePrimaryDark  = Color(0xFF0C447C);
  static const blueDeep         = Color(0xFF042C53);
  static const blueBorder       = Color(0xFFD3D1C7);
  static const blueBorderStrong = Color(0xFFB4B2A9);
  static const blueTextPrimary  = Color(0xFF2C2C2A);
  static const blueTextSecond   = Color(0xFF5F5E5A);
  static const blueTextMuted    = Color(0xFF888780);
  static const blueMuted        = Color(0xFFE8E6F0);

  // Dark — Bleu
  static const blueDarkBg      = Color(0xFF0F1117);
  static const blueDarkSurface = Color(0xFF1A1D27);
  static const blueDarkAlt     = Color(0xFF22252F);
  static const blueDarkBorder  = Color(0xFF2E3140);
  static const blueDarkBorder2 = Color(0xFF3D4155);
  static const blueDarkText    = Color(0xFFF0F0EE);
  static const blueDarkTextSec = Color(0xFFA8A7A3);
  static const blueDarkMuted   = Color(0xFF1C2235);
  static const blueDarkPrimary = Color(0xFF5BA3EE); // bleu plus lumineux en dark

  // Heatmap bleu
  static const blueHeatmap0 = Color(0xFFE6F1FB);
  static const blueHeatmap1 = Color(0xFFB5D4F4);
  static const blueHeatmap2 = Color(0xFF85B7EB);
  static const blueHeatmap3 = Color(0xFF378ADD);
  static const blueHeatmap4 = Color(0xFF185FA5);

  // ════════════════════════════════════════════════════════════════════════════
  // COULEURS SÉMANTIQUES (partagées entre tous les thèmes)
  // ════════════════════════════════════════════════════════════════════════════
  static const success      = Color(0xFF3D9970);
  static const successLight = Color(0xFFEAF3DE);
  static const error        = Color(0xFFCC3333);
  static const errorLight   = Color(0xFFFCEBEB);
  static const warning      = Color(0xFFEF9F27);
  static const warningLight = Color(0xFFFAEEDA);

  // ════════════════════════════════════════════════════════════════════════════
  // HELPERS CONTEXTUELS — utilisent l'enum AppColorTheme
  // ════════════════════════════════════════════════════════════════════════════
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Couleur primaire selon thème + mode
  static Color primaryOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) {
      return Theme.of(context).colorScheme.primary;
    }

    final dark = isDark(context);
    switch (colorTheme) {
      case AppColorTheme.blue:
        return dark ? blueDarkPrimary : bluePrimary;
      case AppColorTheme.gold:
        return dark ? darkPrimary : accent;
      case AppColorTheme.green:
        return dark ? darkPrimary : primary;
    }
  }

  static Color greenOf(BuildContext context) =>
      isDark(context) ? darkGreen : primary;

  static Color foregroundOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color mutedFgOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68);

  static Color mutedOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) {
      final scheme = Theme.of(context).colorScheme;
      return Color.lerp(scheme.surface, scheme.primary, 0.08) ??
          scheme.surface;
    }

    final dark = isDark(context);
    if (colorTheme == AppColorTheme.blue) {
      return dark ? blueDarkMuted : blueMuted;
    }
    return dark ? darkMuted : muted;
  }

  static Color borderOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) {
      return Theme.of(context).colorScheme.outline;
    }

    final dark = isDark(context);
    if (colorTheme == AppColorTheme.blue) {
      return dark ? blueDarkBorder : blueBorder;
    }
    return dark ? darkBorder : border;
  }

  static Color surfaceOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) {
      return Theme.of(context).colorScheme.surface;
    }

    final dark = isDark(context);
    if (colorTheme == AppColorTheme.blue) {
      return dark ? blueDarkSurface : blueSurface;
    }
    return dark ? darkCard : card;
  }

  static Color backgroundOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) {
      return Theme.of(context).scaffoldBackgroundColor;
    }

    final dark = isDark(context);
    if (colorTheme == AppColorTheme.blue) {
      return dark ? blueDarkBg : blueBackground;
    }
    return dark ? darkBackground : background;
  }

  static Color progressTrackOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) {
      return Theme.of(context).progressIndicatorTheme.linearTrackColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.18);
    }

    final dark = isDark(context);
    if (colorTheme == AppColorTheme.blue) {
      return dark ? blueDarkMuted : bluePrimaryLight;
    }
    return dark ? darkMuted : const Color(0xFFCDE8DA);
  }

  /// Heatmap selon thème
  static List<Color> heatmapColors(AppColorTheme colorTheme) {
    if (colorTheme == AppColorTheme.blue) {
      return [blueHeatmap0, blueHeatmap1, blueHeatmap2, blueHeatmap3, blueHeatmap4];
    }
    return [heatmap0, heatmap1, heatmap2, heatmap3, heatmap4];
  }
}

// ─── Builder de thème ─────────────────────────────────────────────────────────
class AppTheme {
  /// Retourne le ThemeData selon mode + couleur choisie
  static ThemeData buildTheme({
    required Brightness brightness,
    AppColorTheme colorTheme = AppColorTheme.green,
  }) {
    final isDark = brightness == Brightness.dark;

    // ── Résolution des couleurs selon le thème choisi ──────────────────────
    final Color scaffoldBg;
    final Color primaryColor;
    final Color primaryFg;
    final Color surfaceColor;
    final Color borderColor;
    final Color progressTrack;

    switch (colorTheme) {
      case AppColorTheme.blue:
        scaffoldBg    = isDark ? AppColors.blueDarkBg      : AppColors.blueBackground;
        primaryColor  = isDark ? AppColors.blueDarkPrimary : AppColors.bluePrimary;
        primaryFg     = isDark ? AppColors.blueDarkText    : AppColors.blueSurface;
        surfaceColor  = isDark ? AppColors.blueDarkSurface : AppColors.blueSurface;
        borderColor   = isDark ? AppColors.blueDarkBorder  : AppColors.blueBorder;
        progressTrack = isDark ? AppColors.blueDarkMuted   : AppColors.bluePrimaryLight;

      case AppColorTheme.gold:
        scaffoldBg    = isDark ? AppColors.darkBackground  : AppColors.background;
        primaryColor  = AppColors.accent;
        primaryFg     = AppColors.accentFg;
        surfaceColor  = isDark ? AppColors.darkCard        : AppColors.card;
        borderColor   = isDark ? AppColors.darkBorder      : AppColors.border;
        progressTrack = isDark ? AppColors.darkMuted       : const Color(0xFFFAEEDA);

      case AppColorTheme.green:
        scaffoldBg    = isDark ? AppColors.darkBackground  : AppColors.background;
        primaryColor  = isDark ? AppColors.darkPrimary     : AppColors.primary;
        primaryFg     = isDark ? AppColors.darkPrimaryFg   : AppColors.primaryFg;
        surfaceColor  = isDark ? AppColors.darkCard        : AppColors.card;
        borderColor   = isDark ? AppColors.darkBorder      : AppColors.border;
        progressTrack = isDark ? AppColors.darkMuted       : const Color(0xFFCDE8DA);
    }

    final textColor = isDark
        ? (colorTheme == AppColorTheme.blue ? AppColors.blueDarkText : const Color(0xFFF5F0E8))
        : (colorTheme == AppColorTheme.blue ? AppColors.blueTextPrimary : AppColors.foreground);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: primaryFg,
        secondary: colorTheme == AppColorTheme.blue
            ? (isDark ? AppColors.blueDarkPrimary : AppColors.bluePrimaryMid)
            : AppColors.accent,
        onSecondary: colorTheme == AppColorTheme.blue
            ? AppColors.blueSurface
            : AppColors.accentFg,
        surface: surfaceColor,
        onSurface: textColor,
        error: AppColors.error,
        onError: AppColors.destructiveFg,
        outline: borderColor,
      ),
      textTheme: _buildTextTheme(brightness, textColor),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBg,
        foregroundColor: textColor,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: primaryFg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(color: borderColor, thickness: 0.5),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: progressTrack,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark ? AppColors.darkMutedFg : AppColors.mutedFg,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Raccourcis pour compatibilité avec le code existant
  static ThemeData get light => buildTheme(brightness: Brightness.light);
  static ThemeData get dark  => buildTheme(brightness: Brightness.dark);

  static TextTheme _buildTextTheme(Brightness brightness, Color color) {
    return TextTheme(
      displayLarge:   GoogleFonts.cairo(fontSize: 32, fontWeight: FontWeight.w700, color: color),
      displayMedium:  GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.w700, color: color),
      displaySmall:   GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w700, color: color),
      headlineLarge:  GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w700, color: color),
      headlineMedium: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w600, color: color),
      headlineSmall:  GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w600, color: color),
      titleLarge:     GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w600, color: color),
      titleMedium:    GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: color),
      titleSmall:     GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      bodyLarge:      GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium:     GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      bodySmall:      GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, color: color),
      labelLarge:     GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600, color: color),
      labelMedium:    GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      labelSmall:     GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w500, color: color),
    );
  }
}

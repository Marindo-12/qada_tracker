// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

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
  static const primary       = Color(0xFF0D6B45);
  static const primaryFg     = Color(0xFFFFFFFF);
  static const secondary     = Color(0xFFE8DFC8);
  static const secondaryFg   = Color(0xFF1A2332);
  static const muted         = Color(0xFFE8DFC8);
  static const mutedFg       = Color(0xFF5A6A7A);
  static const accent        = Color(0xFF9B6E1A);
  static const accentFg      = Color(0xFFFFFFFF);
  static const destructive   = Color(0xFFCC3333);
  static const destructiveFg = Color(0xFFFFFFFF);

  // Heatmap gradient (vert)
  static const heatmap0 = Color(0xFFE8DFC8);
  static const heatmap1 = Color(0xFFB3D9C4);
  static const heatmap2 = Color(0xFF6DB89A);
  static const heatmap3 = Color(0xFF3D9970);
  static const heatmap4 = Color(0xFF0D6B45);

  // Dark — Vert / Gold partagés
  static const darkBackground = Color(0xFF0F1621);
  static const darkCard       = Color(0xFF1A2535);
  static const darkBorder     = Color(0xFF2A3545);
  static const darkPrimary    = Color(0xFF785A1E);
  static const darkPrimaryFg  = Color(0xFFFFF4D6);
  static const darkMutedFg    = Color(0xFFE9D8A6);
  static const darkMuted      = Color(0xFF2F363F);
  static const darkGreen      = Color(0xFF166534);
  static const darkGreenAlt   = Color(0xFF1F7A4C);

  // ════════════════════════════════════════════════════════════════════════════
  // THÈME 2 — Bleu + Neutres
  // ════════════════════════════════════════════════════════════════════════════
  static const blueBackground   = Color(0xFFF5F9FF);
  static const blueSurface      = Color(0xFFFFFFFF);
  static const blueSurfaceAlt   = Color(0xFFEFF6FF);
  static const bluePrimary      = Color(0xFF2563EB);
  static const bluePrimaryHover = Color(0xFF1D4ED8);
  static const bluePrimaryLight = Color(0xFFE8F0FF);
  static const bluePrimaryMid   = Color(0xFFBFDBFE);
  static const bluePrimaryDark  = Color(0xFF1E3A8A);
  static const blueDeep         = Color(0xFF172554);
  static const blueBorder       = Color(0xFFC7D2FE);
  static const blueBorderStrong = Color(0xFF93C5FD);
  static const blueTextPrimary  = Color(0xFF0F172A);
  static const blueTextSecond   = Color(0xFF334155);
  static const blueTextMuted    = Color(0xFF64748B);
  static const blueMuted        = Color(0xFFEEF2FF);

  // Dark — Bleu
  static const blueDarkBg      = Color(0xFF0B1220);
  static const blueDarkSurface = Color(0xFF111827);
  static const blueDarkAlt     = Color(0xFF172033);
  static const blueDarkBorder  = Color(0xFF2C3A58);
  static const blueDarkBorder2 = Color(0xFF3B4A6B);
  static const blueDarkText    = Color(0xFFF8FAFC);
  static const blueDarkTextSec = Color(0xFFCBD5E1);
  static const blueDarkMuted   = Color(0xFF1E2A42);
  static const blueDarkPrimary = Color(0xFF60A5FA);

  // Heatmap bleu
  static const blueHeatmap0 = Color(0xFFEFF6FF);
  static const blueHeatmap1 = Color(0xFFBFDBFE);
  static const blueHeatmap2 = Color(0xFF60A5FA);
  static const blueHeatmap3 = Color(0xFF2563EB);
  static const blueHeatmap4 = Color(0xFF1D4ED8);

  // ════════════════════════════════════════════════════════════════════════════
  // COULEURS SÉMANTIQUES
  // ════════════════════════════════════════════════════════════════════════════
  static const success      = Color(0xFF3D9970);
  static const successLight = Color(0xFFEAF3DE);
  static const error        = Color(0xFFCC3333);
  static const errorLight   = Color(0xFFFCEBEB);
  static const warning      = Color(0xFFEF9F27);
  static const warningLight = Color(0xFFFAEEDA);

  // ════════════════════════════════════════════════════════════════════════════
  // HELPERS CONTEXTUELS
  // ════════════════════════════════════════════════════════════════════════════
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color primaryOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) return Theme.of(context).colorScheme.primary;
    final dark = isDark(context);
    switch (colorTheme) {
      case AppColorTheme.blue:
        return dark ? blueDarkPrimary : bluePrimary;
      case AppColorTheme.gold:
        return dark ? const Color(0xFFD4A853) : accent;
      case AppColorTheme.green:
        return dark ? const Color(0xFF22C55E) : primary;
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
      return Color.lerp(scheme.surface, scheme.primary, 0.08) ?? scheme.surface;
    }
    final dark = isDark(context);
    if (colorTheme == AppColorTheme.blue) return dark ? blueDarkMuted : blueMuted;
    return dark ? darkMuted : muted;
  }

  static Color borderOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) return Theme.of(context).colorScheme.outline;
    final dark = isDark(context);
    if (colorTheme == AppColorTheme.blue) return dark ? blueDarkBorder : blueBorder;
    return dark ? darkBorder : border;
  }

  static Color surfaceOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) return Theme.of(context).colorScheme.surface;
    final dark = isDark(context);
    if (colorTheme == AppColorTheme.blue) return dark ? blueDarkSurface : blueSurface;
    return dark ? darkCard : card;
  }

  static Color backgroundOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) return Theme.of(context).scaffoldBackgroundColor;
    final dark = isDark(context);
    if (colorTheme == AppColorTheme.blue) return dark ? blueDarkBg : blueBackground;
    return dark ? darkBackground : background;
  }

  static Color progressTrackOf(BuildContext context, [AppColorTheme? colorTheme]) {
    if (colorTheme == null) {
      return Theme.of(context).progressIndicatorTheme.linearTrackColor ??
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.18);
    }
    final dark = isDark(context);
    if (colorTheme == AppColorTheme.blue) return dark ? blueDarkMuted : bluePrimaryLight;
    return dark ? darkMuted : const Color(0xFFCDE8DA);
  }

  /// Couleur de fond des cards hero (ex: _TotalCountHero).
  /// En dark mode, les primaires sont lumineux → on utilise une version foncée.
  static Color heroBackgroundOf(BuildContext context) {
    if (!isDark(context)) return Theme.of(context).colorScheme.primary;
    final primary = Theme.of(context).colorScheme.primary;
    if (primary == blueDarkPrimary)           return bluePrimaryDark;
    // FIXED: Much richer dark green — no longer near-black
    if (primary == const Color(0xFF22C55E))   return const Color(0xFF14522D);
    // FIXED: Deep dark gold that still reads as gold, not muddy brown
    if (primary == const Color(0xFFD4A853))   return const Color(0xFF6B4E1C);
    return HSLColor.fromColor(primary)
        .withLightness(0.18)
        .withSaturation(0.55)
        .toColor();
  }

  static List<Color> heatmapColors(AppColorTheme colorTheme, {bool isDark = false}) {
    if (colorTheme == AppColorTheme.blue) {
      if (isDark) {
        return [
          blueDarkMuted,
          blueDarkPrimary.withValues(alpha: 0.45),
          blueDarkPrimary.withValues(alpha: 0.65),
          blueDarkPrimary.withValues(alpha: 0.82),
          blueDarkPrimary,
        ];
      }
      // Blue light
      return [blueHeatmap0, blueHeatmap1, blueHeatmap2, blueHeatmap3, blueHeatmap4];
    }

    if (colorTheme == AppColorTheme.gold) {
      if (isDark) {
        return [
          darkMuted,
          const Color(0xFFD4A853).withValues(alpha: 0.25),
          const Color(0xFFD4A853).withValues(alpha: 0.50),
          const Color(0xFFD4A853).withValues(alpha: 0.75),
          const Color(0xFFD4A853),
        ];
      }
      // Gold light — dégradé sable → or foncé
      return [
        const Color(0xFFF5EDD6), // sable très clair
        const Color(0xFFE8C97A), // or pâle
        const Color(0xFFD4A853), // or moyen
        const Color(0xFFB8892A), // or soutenu
        const Color(0xFF9B6E1A), // or foncé (accent)
      ];
    }

    // Green
    if (isDark) {
      return [
        darkMuted,
        const Color(0xFF22C55E).withValues(alpha: 0.25),
        const Color(0xFF22C55E).withValues(alpha: 0.50),
        const Color(0xFF22C55E).withValues(alpha: 0.75),
        const Color(0xFF22C55E),
      ];
    }
    // Green light
    return [heatmap0, heatmap1, heatmap2, heatmap3, heatmap4];
  }
}

// ─── Builder de thème ─────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData buildTheme({
    required Brightness brightness,
    AppColorTheme colorTheme = AppColorTheme.green,
  }) {
    final isDark = brightness == Brightness.dark;

    // ── Couleur de texte : toujours lisible en dark mode ──────────────────
    // Problème original : green utilisait Color(0xFFF0FFF5) (trop vert/foncé)
    // et gold utilisait Color(0xFFFFF8E8) (trop chaud/foncé sur fond sombre).
    // Solution : un blanc neutre unique pour tous les thèmes dark,
    // identique à ce que fait le thème bleu (blueDarkText = 0xFFF8FAFC).
    final Color textColor;
    if (isDark) {
      textColor = const Color(0xFFF1F5F9); // blanc neutre, excellent contraste sur tous les fonds dark
    } else {
      textColor = colorTheme == AppColorTheme.blue
          ? AppColors.blueTextPrimary
          : AppColors.foreground;
    }

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
        // Gold dark : or lumineux bien visible sur fond sombre
        primaryColor  = isDark ? const Color(0xFFD4A853)   : AppColors.accent;
        primaryFg     = isDark ? const Color(0xFF1A1206)   : AppColors.accentFg;
        surfaceColor  = isDark ? AppColors.darkCard        : AppColors.card;
        borderColor   = isDark ? AppColors.darkBorder      : AppColors.border;
        progressTrack = isDark ? AppColors.darkMuted       : const Color(0xFFFAEEDA);

      case AppColorTheme.green:
        scaffoldBg    = isDark ? AppColors.darkBackground  : AppColors.background;
        // Green dark : vert lumineux bien visible sur fond sombre
        primaryColor  = isDark ? const Color(0xFF22C55E)   : AppColors.primary;
        primaryFg     = isDark ? const Color(0xFF052E16)   : AppColors.primaryFg;
        surfaceColor  = isDark ? AppColors.darkCard        : AppColors.card;
        borderColor   = isDark ? AppColors.darkBorder      : AppColors.border;
        progressTrack = isDark ? AppColors.darkMuted       : const Color(0xFFCDE8DA);
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary:    primaryColor,
        onPrimary:  primaryFg,
        secondary:  colorTheme == AppColorTheme.blue
            ? (isDark ? AppColors.blueDarkPrimary : AppColors.bluePrimaryMid)
            : AppColors.accent,
        onSecondary: colorTheme == AppColorTheme.blue
            ? AppColors.blueSurface
            : AppColors.accentFg,
        surface:   surfaceColor,
        onSurface: textColor,
        error:     AppColors.error,
        onError:   AppColors.destructiveFg,
        outline:   borderColor,
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
          textStyle: _arabicTextStyle(
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            color: primaryFg,
          ),
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
      dividerTheme:     DividerThemeData(color: borderColor, thickness: 0.5),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: progressTrack,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor:     surfaceColor,
        selectedItemColor:   primaryColor,
        unselectedItemColor: isDark
            ? textColor.withValues(alpha: 0.50)
            : AppColors.mutedFg,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get light => buildTheme(brightness: Brightness.light);
  static ThemeData get dark  => buildTheme(brightness: Brightness.dark);

  static TextTheme _buildTextTheme(Brightness brightness, Color color) {
    return TextTheme(
      displayLarge:   _arabicTextStyle(const TextStyle(fontSize: 32, fontWeight: FontWeight.w700), color: color),
      displayMedium:  _arabicTextStyle(const TextStyle(fontSize: 28, fontWeight: FontWeight.w700), color: color),
      displaySmall:   _arabicTextStyle(const TextStyle(fontSize: 24, fontWeight: FontWeight.w700), color: color),
      headlineLarge:  _arabicTextStyle(const TextStyle(fontSize: 22, fontWeight: FontWeight.w700), color: color),
      headlineMedium: _arabicTextStyle(const TextStyle(fontSize: 20, fontWeight: FontWeight.w600), color: color),
      headlineSmall:  _arabicTextStyle(const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), color: color),
      titleLarge:     _arabicTextStyle(const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), color: color),
      titleMedium:    _arabicTextStyle(const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), color: color),
      titleSmall:     _arabicTextStyle(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), color: color),
      bodyLarge:      _arabicTextStyle(const TextStyle(fontSize: 16, fontWeight: FontWeight.w400), color: color),
      bodyMedium:     _arabicTextStyle(const TextStyle(fontSize: 14, fontWeight: FontWeight.w400), color: color),
      bodySmall:      _arabicTextStyle(const TextStyle(fontSize: 12, fontWeight: FontWeight.w400), color: color),
      labelLarge:     _arabicTextStyle(const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), color: color),
      labelMedium:    _arabicTextStyle(const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), color: color),
      labelSmall:     _arabicTextStyle(const TextStyle(fontSize: 10, fontWeight: FontWeight.w500), color: color),
    );
  }

  static TextStyle _arabicTextStyle(TextStyle style, {required Color color}) {
    return style.copyWith(
      color: color,
      fontFamily: 'Amiri',
      fontFamilyFallback: const ['ScheherazadeNew', 'Cairo', 'Noto Naskh Arabic'],
    );
  }
}
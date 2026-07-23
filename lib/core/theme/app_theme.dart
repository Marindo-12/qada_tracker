import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFFF9F9F8);
  static const foreground = Color(0xFF1A1C1C);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFBFC9C3);
  static const primary = Color(0xFF003527);
  static const primaryFg = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFD3E3DC);
  static const secondaryFg = Color(0xFF566660);
  static const muted = Color(0xFFE2E2E2);
  static const mutedFg = Color(0xFF404944);
  static const accent = Color(0xFF6A3700);
  static const accentFg = Color(0xFFFFFFFF);
  static const destructive = Color(0xFFBA1A1A);
  static const destructiveFg = Color(0xFFFFFFFF);

  static const surfaceDim = Color(0xFFDADAD9);
  static const surfaceContainerLow = Color(0xFFF3F4F3);
  static const surfaceContainer = Color(0xFFEEEEED);
  static const surfaceContainerHigh = Color(0xFFE8E8E7);
  static const surfaceContainerHighest = Color(0xFFE2E2E2);
  static const outline = Color(0xFF707974);
  static const outlineVariant = Color(0xFFBFC9C3);
  static const surfaceTint = Color(0xFF2B6954);
  static const primaryContainer = Color(0xFF064E3B);
  static const onPrimaryContainer = Color(0xFF80BEA6);
  static const inversePrimary = Color(0xFF95D3BA);
  static const tertiary = Color(0xFF4A2400);
  static const tertiaryContainer = Color(0xFF6A3700);
  static const onTertiaryContainer = Color(0xFFFF9939);
  static const success = Color(0xFF059669);
  static const successLight = Color(0xFFECFDF5);
  static const error = Color(0xFFBA1A1A);
  static const errorLight = Color(0xFFFFDAD6);
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFFF7ED);

  static const darkBackground = Color(0xFF101412);
  static const darkCard = Color(0xFF1A1F1D);
  static const darkBorder = Color(0xFF3B4540);
  static const darkMuted = Color(0xFF26302B);
  static const darkMutedFg = Color(0xFFBACAC3);
  static const darkPrimary = Color(0xFF95D3BA);
  static const darkPrimaryFg = Color(0xFF002117);
  static const darkSecondary = Color(0xFF3B4A44);
  static const darkAccent = Color(0xFFFFB77D);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color primaryOf(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color greenOf(BuildContext context) => primaryOf(context);

  static Color foregroundOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color mutedFgOf(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.68);

  static Color mutedOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Color.lerp(scheme.surface, scheme.primary, isDark(context) ? 0.10 : 0.07) ??
        scheme.surface;
  }

  static Color borderOf(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  static Color surfaceOf(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color backgroundOf(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color progressTrackOf(BuildContext context) =>
      Theme.of(context).progressIndicatorTheme.linearTrackColor ??
      Theme.of(context).colorScheme.primary.withValues(alpha: 0.18);

  static Color heroBackgroundOf(BuildContext context) {
    return isDark(context) ? primaryContainer : Theme.of(context).colorScheme.primary;
  }

  static List<Color> heatmapColors({bool isDark = false}) {
    if (isDark) {
      return [
        darkMuted,
        darkPrimary.withValues(alpha: 0.25),
        darkPrimary.withValues(alpha: 0.50),
        darkPrimary.withValues(alpha: 0.75),
        darkPrimary,
      ];
    }

    return const [
      Color(0xFFE2E2E2),
      Color(0xFFD3E3DC),
      Color(0xFF95D3BA),
      Color(0xFF2B6954),
      Color(0xFF064E3B),
    ];
  }
}

class AppTheme {
  static ThemeData buildTheme({
    required Brightness brightness,
  }) {
    final isDark = brightness == Brightness.dark;
    final textColor = isDark ? const Color(0xFFF1F1F0) : AppColors.foreground;
    final scaffoldBg = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkCard : AppColors.card;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.primary;
    final primaryFg = isDark ? AppColors.darkPrimaryFg : AppColors.primaryFg;
    final secondaryColor = isDark ? AppColors.darkSecondary : AppColors.secondary;
    final secondaryFg = isDark ? const Color(0xFFD5E6DF) : AppColors.secondaryFg;
    final accentColor = isDark ? AppColors.darkAccent : AppColors.accent;
    final progressTrack = isDark ? AppColors.darkMuted : AppColors.secondary;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: primaryFg,
        secondary: secondaryColor,
        onSecondary: secondaryFg,
        tertiary: accentColor,
        onTertiary: AppColors.accentFg,
        surface: surfaceColor,
        onSurface: textColor,
        error: AppColors.error,
        onError: AppColors.destructiveFg,
        outline: borderColor,
      ),
      textTheme: _buildTextTheme(brightness, textColor),
      cardTheme: CardThemeData(
        color: surfaceColor.withValues(alpha: isDark ? 0.92 : 0.96),
        elevation: 0,
        shadowColor: primaryColor.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: borderColor.withValues(alpha: 0.8), width: 0.8),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          textStyle: _arabicTextStyle(
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            color: primaryFg,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor.withValues(alpha: 0.7)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.darkMuted : const Color(0xFFECFDF5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      dividerTheme: DividerThemeData(
        color: borderColor.withValues(alpha: 0.65),
        thickness: 0.5,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: progressTrack,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor.withValues(alpha: 0.86),
        selectedItemColor: primaryColor,
        unselectedItemColor: textColor.withValues(alpha: 0.52),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static ThemeData get light => buildTheme(brightness: Brightness.light);
  static ThemeData get dark => buildTheme(brightness: Brightness.dark);

  static TextTheme _buildTextTheme(Brightness brightness, Color color) {
    return TextTheme(
      displayLarge: _arabicTextStyle(const TextStyle(fontSize: 32, fontWeight: FontWeight.w700), color: color),
      displayMedium: _arabicTextStyle(const TextStyle(fontSize: 28, fontWeight: FontWeight.w700), color: color),
      displaySmall: _arabicTextStyle(const TextStyle(fontSize: 24, fontWeight: FontWeight.w700), color: color),
      headlineLarge: _arabicTextStyle(const TextStyle(fontSize: 22, fontWeight: FontWeight.w700), color: color),
      headlineMedium: _arabicTextStyle(const TextStyle(fontSize: 20, fontWeight: FontWeight.w600), color: color),
      headlineSmall: _arabicTextStyle(const TextStyle(fontSize: 18, fontWeight: FontWeight.w600), color: color),
      titleLarge: _arabicTextStyle(const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), color: color),
      titleMedium: _arabicTextStyle(const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), color: color),
      titleSmall: _arabicTextStyle(const TextStyle(fontSize: 12, fontWeight: FontWeight.w600), color: color),
      bodyLarge: _arabicTextStyle(const TextStyle(fontSize: 16, fontWeight: FontWeight.w400), color: color),
      bodyMedium: _arabicTextStyle(const TextStyle(fontSize: 14, fontWeight: FontWeight.w400), color: color),
      bodySmall: _arabicTextStyle(const TextStyle(fontSize: 12, fontWeight: FontWeight.w400), color: color),
      labelLarge: _arabicTextStyle(const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), color: color),
      labelMedium: _arabicTextStyle(const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), color: color),
      labelSmall: _arabicTextStyle(const TextStyle(fontSize: 10, fontWeight: FontWeight.w500), color: color),
    );
  }

  static TextStyle _arabicTextStyle(TextStyle style, {required Color color}) {
    return style.copyWith(
      color: color,
      fontFamily: 'Amiri',
      fontFamilyFallback: const [
        'Amiri',
        'ScheherazadeNew',
        'Cairo',
        'Noto Naskh Arabic',
      ],
    );
  }
}

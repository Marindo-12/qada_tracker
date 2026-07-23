import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qada_tracker/core/theme/app_theme.dart';

// ─── Provider pour l'état du thème de couleur ─────────────────────────────────
final themeColorProvider =
    StateNotifierProvider<ThemeColorNotifier, AppColorTheme>((ref) {
  return ThemeColorNotifier();
});

// ─── Notifier pour gérer le changement de thème ────────────────────────────────
class ThemeColorNotifier extends StateNotifier<AppColorTheme> {
  static const String _themeKey = 'app_color_theme';

  ThemeColorNotifier() : super(AppColorTheme.blue) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(_themeKey) ?? 'blue';
      state = AppColorTheme.values.firstWhere(
        (theme) => theme.name == themeName,
        orElse: () => AppColorTheme.blue,
      );
    } catch (e) {
      state = AppColorTheme.blue;
    }
  }

  Future<void> setTheme(AppColorTheme theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, theme.name);
      state = theme;
    } catch (e) {
      print('Error saving theme: $e');
    }
  }
}

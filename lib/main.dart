import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/navigation/app_router.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/app_start_splash_screen.dart';
import 'shared/providers/providers.dart';
import 'shared/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar', null);
  await QadaNotificationService.initialize();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  // NOTE: the actual status/navigation bar styling now lives in QadaApp's
  // build() via AnnotatedRegion, because it needs to react to theme
  // changes (light/dark) at runtime. A one-time call here would freeze
  // the system UI colors at whatever the theme was on cold start — which
  // was the cause of the Android system navigation bar staying black even
  // in light mode (Android defaults systemNavigationBarColor to black
  // when it's never explicitly set).
  runApp(const ProviderScope(child: QadaApp()));
}

class QadaApp extends ConsumerWidget {
  const QadaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(digitStyleProvider);
    final themeMode = ref.watch(themeModeProvider);
    final colorTheme = ref.watch(themeColorProvider);

    // Resolve whether we're actually in dark mode right now. themeMode can
    // be ThemeMode.system, in which case we fall back to the platform
    // brightness reported by the current MediaQuery/PlatformDispatcher.
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    final navBarColor = AppColors.solidBackgroundFor(
      colorTheme,
      isDark: isDark,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Re-applied automatically whenever isDark changes (theme toggle,
      // or system theme change if themeMode is ThemeMode.system) since
      // this whole build() re-runs on those changes.
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        // This is the actual fix: previously unset, so Android defaulted
        // it to black regardless of theme. Now it always matches the
        // active theme's real background color.
        systemNavigationBarColor: navBarColor,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: MaterialApp(
        title: 'قضاء الصلوات',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.buildTheme(
          brightness: Brightness.light,
          colorTheme: colorTheme,
        ),
        darkTheme: AppTheme.buildTheme(
          brightness: Brightness.dark,
          colorTheme: colorTheme,
        ),
        themeMode: themeMode,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: const AppStartSplashScreen(child: AppShell()),
      ),
    );
  }
}

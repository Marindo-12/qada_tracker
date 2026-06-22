// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'features/splash/app_start_splash_screen.dart';
import 'shared/providers/providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Arabic locale for date formatting
  await initializeDateFormatting('ar', null);

  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: QadaApp(),
    ),
  );
}

class QadaApp extends ConsumerWidget {
  const QadaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pre-load preferences
    ref.watch(digitStyleProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'قضاء الصلوات',
      debugShowCheckedModeBanner: false,

      // RTL + Arabic locale
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

      // Theme
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Text direction RTL
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      home: const AppStartSplashScreen(
        child: AppShell(),
      ),
    );
  }
}

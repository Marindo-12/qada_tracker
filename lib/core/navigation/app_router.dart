// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/home_screen.dart';
import '../../features/calendar/calendar_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/setup/setup_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/providers.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    final currentTab = ref.watch(currentTabProvider);

    return planAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
      data: (plan) {
        // No plan yet → show setup
        if (plan == null && currentTab != 3) {
          return const SetupScreen();
        }

        final screens = [
          const HomeScreen(),
          const CalendarScreen(),
          const SettingsScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: currentTab.clamp(0, 2),
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: currentTab.clamp(0, 2),
              onTap: (i) => ref.read(currentTabProvider.notifier).state = i,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'الرئيسية',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_outlined),
                  activeIcon: Icon(Icons.calendar_month),
                  label: 'التقويم',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings_outlined),
                  activeIcon: Icon(Icons.settings),
                  label: 'الإعدادات',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
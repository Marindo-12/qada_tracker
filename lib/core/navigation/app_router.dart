// lib/core/navigation/app_router.dart
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/home_screan.dart';
import '../../features/calendar/calendar_screan.dart';
import '../../features/guide/guide_screen.dart';
import '../../features/settings/settings_screan.dart';
import '../../features/setup/setup_intro_screen.dart' hide AppColors;
import '../../features/setup/username_setup_screen.dart';
import '../../shared/providers/providers.dart';
import '../../core/theme/app_theme.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

// ─── Layout : 2 tabs | FAB (home) | 2 tabs ───────────────────────────────────
// index 0 = الرئيسية  → FAB (centre, toujours visible)
// index 1 = التقويم   → slot gauche 0
// index 2 = الدليل    → slot gauche 1
// index 3 = الإعدادات → slot droite 0  (1 seul à droite)
//
// animated_bottom_navigation_bar attend 4 items répartis 2|2 autour du notch.
// On mappe : left=[التقويم, الدليل]  right=[الإعدادات, placeholder]
// Mais comme on a 3 tabs + 1 FAB, on utilise itemCount=4 avec GapLocation.center
// Left slots  : index 0 = التقويم,  index 1 = الدليل
// Right slots : index 2 = الإعدادات, index 3 = (hidden / same as home)
// Le FAB représente الرئيسية
// ─────────────────────────────────────────────────────────────────────────────

// Mapping bar-index → screen-index
//   bar 0 (left-0)  → screen 1 (التقويم)
//   bar 1 (left-1)  → screen 2 (الدليل)
//   bar 2 (right-0) → screen 3 (الإعدادات)
//   bar 3 (right-1) → screen 3 (same, hidden tab)
// FAB                → screen 0 (الرئيسية)

const _barToScreen = [1, 2, 3, 3];

const _barIcons = [
  Icons.calendar_month_rounded,
  Icons.menu_book_rounded,
  Icons.tune_rounded,
  Icons.tune_rounded, // hidden duplicate
];

const _barLabels = ['التقويم', 'الدليل', 'الإعدادات', ''];

// ─── Shell ────────────────────────────────────────────────────────────────────
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync  = ref.watch(planProvider);
    final currentTab = ref.watch(currentTabProvider);

    return planAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
      data: (plan) {
        if (plan == null && currentTab != 2 && currentTab != 3) {
          final userNameAsync = ref.watch(userNameProvider);
          return userNameAsync.when(
            loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator())),
            error: (e, _) =>
                Scaffold(body: Center(child: Text('خطأ: $e'))),
            data: (userName) {
              if (userName == null) return const UsernameSetupScreen();
              return const SetupIntroScreen();
            },
          );
        }

        return const _MainShell();
      },
    );
  }
}

// ─── Main shell with animated nav bar ────────────────────────────────────────
class _MainShell extends ConsumerStatefulWidget {
  const _MainShell();

  @override
  ConsumerState<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<_MainShell>
    with SingleTickerProviderStateMixin {
  // bar index (0-3) — NOT the screen index
  int _barIndex = 0;

  late final AnimationController _fabCtl;
  late final Animation<double>   _fabAnim;

  @override
  void initState() {
    super.initState();
    _fabCtl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fabAnim = CurvedAnimation(parent: _fabCtl, curve: Curves.easeOutBack);
    // Animate FAB in after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _fabCtl.forward();
    });
  }

  @override
  void dispose() {
    _fabCtl.dispose();
    super.dispose();
  }

  void _onBarTap(int barIdx) {
    setState(() => _barIndex = barIdx);
    ref.read(currentTabProvider.notifier).state = _barToScreen[barIdx];
  }

  void _onFabTap() {
    setState(() => _barIndex = -1); // no bar item active
    ref.read(currentTabProvider.notifier).state = 0; // الرئيسية
  }

  @override
  Widget build(BuildContext context) {
    final currentTab = ref.watch(currentTabProvider);
    final isDark     = AppColors.isDark(context);
    final primary    = AppColors.primaryOf(context);
    final surface    = AppColors.surfaceOf(context);
    final mutedFg    = AppColors.mutedFgOf(context);

    // Sync bar index when screen changes externally
    final barIdx = currentTab == 0
        ? -1
        : _barToScreen.indexOf(currentTab).clamp(0, 2);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentTab.clamp(0, 3),
        children: const [
          HomeScreen(),
          CalendarScreen(),
          GuidePage(),
          SettingsScreen(),
        ],
      ),

      // ── FAB : represents الرئيسية ─────────────────────────────────────
      floatingActionButton: ScaleTransition(
        scale: _fabAnim,
        child: FloatingActionButton(
          onPressed: _onFabTap,
          backgroundColor: primary,
          elevation:        6,
          shape: const CircleBorder(),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Icon(
              currentTab == 0 ? Icons.home_rounded : Icons.home_outlined,
              key: ValueKey(currentTab == 0),
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ── Bottom nav bar ────────────────────────────────────────────────
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        itemCount:   4,
        activeIndex: barIdx < 0 ? 0 : barIdx, // required, but FAB is active
        gapLocation:       GapLocation.center,
        notchSmoothness:   NotchSmoothness.verySmoothEdge,
        leftCornerRadius:  28,
        rightCornerRadius: 28,
        backgroundColor: surface,
        splashColor:     primary,
        splashSpeedInMilliseconds: 250,
        shadow: BoxShadow(
          color:      isDark
              ? Colors.black.withValues(alpha: 0.40)
              : Colors.black.withValues(alpha: 0.10),
          blurRadius:   20,
          offset:       const Offset(0, -4),
          spreadRadius: 0,
        ),
        onTap: _onBarTap,
        tabBuilder: (int index, bool isActive) {
          // Hide the 4th slot (right duplicate)
          if (index == 3) return const SizedBox.shrink();

          // When FAB (home) is active, nothing in bar is "active"
          final realActive = currentTab != 0 && isActive;
          final color      = realActive ? primary : mutedFg;

          return Column(
            mainAxisSize:      MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  realActive
                      ? _activeIcon(_barIcons[index])
                      : _barIcons[index],
                  key:   ValueKey(realActive),
                  size:  22,
                  color: color,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize:   10,
                  fontWeight: realActive
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: color,
                ),
                child: Text(
                  _barLabels[index],
                  textDirection: TextDirection.rtl,
                  maxLines: 1,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Returns a slightly "filled" version of the icon for active state
  IconData _activeIcon(IconData icon) {
    if (icon == Icons.calendar_month_rounded) return Icons.calendar_month;
    if (icon == Icons.menu_book_rounded)      return Icons.menu_book;
    if (icon == Icons.tune_rounded)           return Icons.tune;
    return icon;
  }
}
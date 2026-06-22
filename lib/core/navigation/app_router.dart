// lib/core/navigation/app_router.dart
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

// ─── Tab definitions ──────────────────────────────────────────────────────────
const _tabItems = [
  _TabItem(icon: Icons.home_outlined,     activeIcon: Icons.home,             label: 'الرئيسية'),
  _TabItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'التقويم'),
  _TabItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book,       label: 'الدليل'),
  _TabItem(icon: Icons.settings_outlined,  activeIcon: Icons.settings,        label: 'الإعدادات'),
];

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({required this.icon, required this.activeIcon, required this.label});
}

// ─── Shell ────────────────────────────────────────────────────────────────────
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    final currentTab = ref.watch(currentTabProvider);

    return planAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
      data: (plan) {
        if (plan == null && currentTab != 2 && currentTab != 3) {
          final userNameAsync = ref.watch(userNameProvider);
          return userNameAsync.when(
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
            data: (userName) {
              if (userName == null) return const UsernameSetupScreen();
              return const SetupIntroScreen();
            },
          );
        }

        final screens = [
          const HomeScreen(),
          const CalendarScreen(),
          const GuidePage(),
          const SettingsScreen(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: currentTab.clamp(0, 3),
            children: screens,
          ),
          bottomNavigationBar: _FloatingNavBar(
            currentIndex: currentTab.clamp(0, 3),
            onTap: (i) => ref.read(currentTabProvider.notifier).state = i,
          ),
        );
      },
    );
  }
}

// ─── Floating animated nav bar ────────────────────────────────────────────────
class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Surface blanche en light, darkCard en dark
    final barColor = AppColors.surfaceOf(context);
    final shadow = AppColors.isDark(context)
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.10);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(color: shadow, blurRadius: 24, offset: const Offset(0, 8)),
              BoxShadow(color: shadow.withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Row(
            children: List.generate(_tabItems.length, (i) {
              return Expanded(
                child: _NavItem(
                  item: _tabItems[i],
                  active: currentIndex == i,
                  onTap: () => onTap(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Individual nav item ──────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final _TabItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.item, required this.active, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _lift;   // icône qui monte
  late final Animation<double> _scale;  // cercle qui apparaît
  late final Animation<double> _fade;   // label qui apparaît

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _lift  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack),
    );
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctl, curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack)),
    );
    _fade  = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)),
    );

    if (widget.active) _ctl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _NavItem old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _ctl.forward();
    if (!widget.active && old.active) _ctl.reverse();
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctl,
        builder: (context, _) {
          final liftOffset = _lift.value * -10.0; // monte de 10 px

          return SizedBox(
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ── Icône inactive centrée dans la barre ─────────────────
                if (_ctl.value < 1.0)
                  Opacity(
                    opacity: (1 - _lift.value).clamp(0.0, 1.0),
                    child: Icon(widget.item.icon, color: mutedFg, size: 22),
                  ),

                // ── Icône active qui se soulève + cercle primaire ─────────
                Positioned(
                  top: 64 / 2 + liftOffset - 24, // centre vertical + lift
                  child: Opacity(
                    opacity: _lift.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: _scale.value,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(widget.item.activeIcon, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
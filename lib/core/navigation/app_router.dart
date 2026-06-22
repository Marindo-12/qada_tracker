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

const _tabItems = [
  _TabItem(icon: Icons.home_outlined,           activeIcon: Icons.home,           label: 'الرئيسية'),
  _TabItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month, label: 'التقويم'),
  _TabItem(icon: Icons.menu_book_outlined,      activeIcon: Icons.menu_book,      label: 'الدليل'),
  _TabItem(icon: Icons.settings_outlined,       activeIcon: Icons.settings,       label: 'الإعدادات'),
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
    final planAsync  = ref.watch(planProvider);
    final currentTab = ref.watch(currentTabProvider);

    return planAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:   (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
      data: (plan) {
        if (plan == null && currentTab != 2 && currentTab != 3) {
          final userNameAsync = ref.watch(userNameProvider);
          return userNameAsync.when(
            loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
            error:   (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
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
          extendBody: true,
          body: IndexedStack(
            index: currentTab.clamp(0, 3),
            children: screens,
          ),
          bottomNavigationBar: _NavBar(
            currentIndex: currentTab.clamp(0, 3),
            onTap: (i) => ref.read(currentTabProvider.notifier).state = i,
          ),
        );
      },
    );
  }
}

// ─── Nav bar ──────────────────────────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavBar({required this.currentIndex, required this.onTap});

  static const double _barHeight    = 64;
  static const double _cornerRadius = 24;

  @override
  Widget build(BuildContext context) {
    final isDark    = AppColors.isDark(context);
    final barColor  = AppColors.surfaceOf(context);
    final shadow    = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.12);

    return SafeArea(
      top: false,
      child: Container(
        height: _barHeight,
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(_cornerRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(_tabItems.length, (i) {
            return Expanded(
              child: _NavItem(
                item:    _tabItems[i],
                active:  currentIndex == i,
                onTap:   () => onTap(i),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─── Single nav item ──────────────────────────────────────────────────────────
// Active  → badge pill (app background color) + primary icon
// Inactive→ no badge, muted icon, no movement
class _NavItem extends StatefulWidget {
  final _TabItem item;
  final bool     active;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double>   _badge; // 0 → 1 : badge scale + opacity

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _badge = CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack);
    if (widget.active) _ctl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _NavItem old) {
    super.didUpdateWidget(old);
    if (widget.active  && !old.active) _ctl.forward();
    if (!widget.active &&  old.active) _ctl.reverse();
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
    // Badge color = same as app page background → creates the "cut-out" effect
    final badgeColor = AppColors.isDark(context)
        ? AppColors.darkBackground
        : AppColors.background;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 64,
        child: AnimatedBuilder(
          animation: _badge,
          builder: (context, _) {
            final t        = _badge.value;
            final isActive = t > 0.4;

            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Badge circulaire (app bg color) scales in on active ─
                  Transform.scale(
                    scale: t,
                    child: Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: Container(
                        width:  46,
                        height: 46,
                        decoration: BoxDecoration(
                          color:  badgeColor,
                          shape:  BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  // ── Icon — grossit quand actif ─────────────────────────
                  Transform.scale(
                    scale: 1.0 + t * 0.28, // 1.0 → 1.28
                    child: Icon(
                      isActive ? widget.item.activeIcon : widget.item.icon,
                      size:  22,
                      color: isActive ? primary : mutedFg,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
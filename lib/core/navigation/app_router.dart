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
          // extendBody so the page content goes under the nav bar
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

// ─── Nav bar : full-width, top corners rounded, icons lift on tap ─────────────
//
// Layout (heights):
//   liftAmount = 18 px  → how far the active icon lifts above the bar top edge
//   barHeight  = 64 px  → visible bar
//   total SizedBox height = barHeight + liftAmount so the lifted icon isn't clipped
//
class _NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavBar({required this.currentIndex, required this.onTap});

  static const double _barHeight   = 64;
  static const double _liftAmount  = 20; // px the active icon rises above the bar
  static const double _cornerRadius = 24;

  @override
  Widget build(BuildContext context) {
    final barColor = AppColors.surfaceOf(context);
    final isDark   = AppColors.isDark(context);
    final shadow   = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.black.withValues(alpha: 0.12);

    return SafeArea(
      top: false,
      child: SizedBox(
        // Extra space above bar so lifted icons are visible and not clipped
        height: _barHeight + _liftAmount,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Bar sits at the bottom of the SizedBox ──────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
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
              ),
            ),

            // ── Items row spans the full SizedBox height ─────────────────
            // Each item knows its own bar bottom offset and lifts itself
            Row(
              children: List.generate(_tabItems.length, (i) {
                return Expanded(
                  child: _NavItem(
                    item: _tabItems[i],
                    active: currentIndex == i,
                    barHeight: _barHeight,
                    liftAmount: _liftAmount,
                    totalHeight: _barHeight + _liftAmount,
                    onTap: () => onTap(i),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Single nav item ──────────────────────────────────────────────────────────
//
// When INACTIVE : icon sits vertically centered inside the bar area.
// When ACTIVE   : icon + circle lift `liftAmount` px above the bar top edge.
//
class _NavItem extends StatefulWidget {
  final _TabItem item;
  final bool active;
  final double barHeight;
  final double liftAmount;
  final double totalHeight;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.item,
    required this.active,
    required this.barHeight,
    required this.liftAmount,
    required this.totalHeight,
    required this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  // 0 = resting inside bar  →  1 = lifted above bar
  late final Animation<double> _lift;
  late final Animation<double> _circleScale;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _lift = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic),
    );
    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack),
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
      child: SizedBox(
        height: widget.totalHeight,
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (context, _) {
            // Inactive icon center: middle of bar = liftAmount + barHeight/2
            // Active icon center: liftAmount/2 above bar top = liftAmount/2
            // So vertical center goes from (liftAmount + barHeight/2) → (liftAmount/2 + circleR)
            const circleR = 23.0;
            final inactiveCenter = widget.liftAmount + widget.barHeight / 2;
            final activeCenter   = widget.liftAmount / 2 + circleR / 2;
            final centerY = inactiveCenter + (activeCenter - inactiveCenter) * _lift.value;

            final isActive = _lift.value > 0.5;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                // ── Circle behind icon (only when lifting) ──────────────
                Positioned(
                  left: 0,
                  right: 0,
                  top: centerY - circleR,
                  child: Center(
                    child: Transform.scale(
                      scale: _circleScale.value,
                      child: Container(
                        width:  circleR * 2,
                        height: circleR * 2,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.40),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Icon (moves with centerY) ───────────────────────────
                Positioned(
                  left: 0,
                  right: 0,
                  top: centerY - 11, // 11 ≈ icon half-size (22/2)
                  child: Center(
                    child: Icon(
                      isActive ? widget.item.activeIcon : widget.item.icon,
                      size: 22,
                      color: isActive ? Colors.white : mutedFg,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
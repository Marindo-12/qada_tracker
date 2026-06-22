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

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final barColor = AppColors.surfaceOf(context);
    final shadow = isDark
        ? Colors.black.withValues(alpha: 0.30)
        : Colors.black.withValues(alpha: 0.10);

    return Container(
      decoration: BoxDecoration(
        color: barColor,
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
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

// ─── Individual item ──────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final _TabItem item;
  final bool active;
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
  late final Animation<double> _circleScale;
  late final Animation<double> _iconSwap;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    // Cercle : scale 0 → 1
    _circleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack),
    );
    // Swap icône : 0→1 (active) ou 1→0 (inactive)
    _iconSwap = CurvedAnimation(parent: _ctl, curve: Curves.easeOut);

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
          return SizedBox(
            height: 64,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // ── Cercle primaire animé derrière l'icône ─────────────
                  Transform.scale(
                    scale: _circleScale.value,
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Icône (swap entre inactive et active) ──────────────
                  Icon(
                    _iconSwap.value > 0.5
                        ? widget.item.activeIcon
                        : widget.item.icon,
                    size: 22,
                    color: _iconSwap.value > 0.5 ? Colors.white : mutedFg,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
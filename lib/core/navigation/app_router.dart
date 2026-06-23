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

const _tabs = [
  _Tab(icon: Icons.home_outlined,           activeIcon: Icons.home_rounded,           label: 'الرئيسية'),
  _Tab(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'التقويم'),
  _Tab(icon: Icons.menu_book_outlined,      activeIcon: Icons.menu_book_rounded,      label: 'الدليل'),
  _Tab(icon: Icons.tune_outlined,           activeIcon: Icons.tune_rounded,           label: 'الإعدادات'),
];

class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String   label;
  const _Tab({required this.icon, required this.activeIcon, required this.label});
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
          bottomNavigationBar: _NavBar(
            currentIndex: currentTab.clamp(0, 3),
            onTap: (i) => ref.read(currentTabProvider.notifier).state = i,
          ),
        );
      },
    );
  }
}

// ─── Nav Bar ─────────────────────────────────────────────────────────────────
// Design : cercle primary qui glisse de tab en tab (comme l'image)
// Barre : fond surface, coins arrondis en haut, ombre douce
// Cercle : se déplace via TweenAnimation sur la position X
// Icône  : scale up + couleur white sur le cercle, muted sinon
// ─────────────────────────────────────────────────────────────────────────────
class _NavBar extends StatefulWidget {
  final int              currentIndex;
  final ValueChanged<int> onTap;

  const _NavBar({required this.currentIndex, required this.onTap});

  @override
  State<_NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<_NavBar> with SingleTickerProviderStateMixin {
  late AnimationController _ctl;
  late Animation<double>   _pos; // tab index interpolated (e.g. 0.0 → 2.0)

  double _from = 0;
  double _to   = 0;

  static const double _barH    = 70;
  static const double _circleD = 52; // diameter of sliding circle

  @override
  void initState() {
    super.initState();
    _from = widget.currentIndex.toDouble();
    _to   = _from;
    _ctl  = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _pos = AlwaysStoppedAnimation(_from);
  }

  @override
  void didUpdateWidget(covariant _NavBar old) {
    super.didUpdateWidget(old);
    if (widget.currentIndex != old.currentIndex) {
      _from = _to;
      _to   = widget.currentIndex.toDouble();
      _pos  = Tween<double>(begin: _from, end: _to).animate(
        CurvedAnimation(parent: _ctl, curve: Curves.easeOutExpo),
      );
      _ctl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark  = AppColors.isDark(context);
    final surface = AppColors.surfaceOf(context);
    final primary = AppColors.primaryOf(context);
    final shadow  = isDark
        ? Colors.black.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.10);

    return SafeArea(
      top: false,
      child: Container(
        height: _barH,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        decoration: BoxDecoration(
          color:        surface,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color:      shadow,
              blurRadius: 24,
              offset:     const Offset(0, 6),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, bc) {
            final totalW = bc.maxWidth;
            final tabW   = totalW / _tabs.length;

            return AnimatedBuilder(
              animation: _pos,
              builder: (context, _) {
                // RTL fix: tab 0 is on the RIGHT in Arabic layout
                // Mirror: index 0 → rightmost slot, index 3 → leftmost slot
                final mirroredPos = (_tabs.length - 1) - _pos.value;
                final cx = tabW * (mirroredPos + 0.5);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ── Sliding green circle ──────────────────────────
                    Positioned(
                      left:   cx - _circleD / 2,
                      top:    (_barH - _circleD) / 2,
                      width:  _circleD,
                      height: _circleD,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:      primary.withValues(alpha: 0.40),
                              blurRadius: 16,
                              offset:     const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Icons row (RTL: tab 0 on the right) ──────────
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: List.generate(_tabs.length, (i) {
                          return Expanded(
                            child: _NavItem(
                              tab:    _tabs[i],
                              active: widget.currentIndex == i,
                              onTap:  () => widget.onTap(i),
                              barH:   _barH,
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── Single item ──────────────────────────────────────────────────────────────
class _NavItem extends StatefulWidget {
  final _Tab         tab;
  final bool         active;
  final VoidCallback onTap;
  final double       barH;

  const _NavItem({
    super.key,
    required this.tab,
    required this.active,
    required this.onTap,
    required this.barH,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctl;
  late Animation<double>   _scale;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack),
    );
    if (widget.active) _ctl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _NavItem old) {
    super.didUpdateWidget(old);
    if ( widget.active && !old.active) _ctl.forward();
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

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: widget.barH,
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (context, _) {
            final isActive = _ctl.value > 0.5;
            return Center(
              child: Transform.scale(
                scale: _scale.value,
                child: Icon(
                  isActive ? widget.tab.activeIcon : widget.tab.icon,
                  size:  24,
                  color: isActive ? Colors.white : mutedFg,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
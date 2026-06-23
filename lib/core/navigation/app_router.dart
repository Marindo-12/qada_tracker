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
  final String   label;
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
// Layout :
//   • Barre pleine largeur, coins arrondis en haut
//   • Bulle (bubble) qui glisse horizontalement sous l'icône active
//     → traduit du CSS : .bubble { transition: transform 300ms cubic-bezier }
//   • Icône active : scale 1.15 + couleur primary (comme .icon--expanded)
//   • Icône inactive : scale 0.85 + mutedFg (comme .icon normal)
// ─────────────────────────────────────────────────────────────────────────────
class _NavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavBar({required this.currentIndex, required this.onTap});

  @override
  State<StatefulWidget> createState() => _NavBarState();
}

class _NavBarState extends State<_NavBar> with SingleTickerProviderStateMixin {
  // Bubble slides from tab to tab
  late final AnimationController _bubbleCtl;
  late Animation<double> _bubblePos; // 0.0 → 1.0 across the tab width

  double _prevPos    = 0;
  double _targetPos  = 0;

  static const double _barHeight    = 72;
  static const double _cornerRadius = 24;
  static const double _bubbleSize   = 48; // diameter of the bubble circle

  @override
  void initState() {
    super.initState();
    _bubbleCtl = AnimationController(
      vsync: this,
      // cubic-bezier(.87,-.91,.66,1.42) → easeOutBack is the closest Flutter curve
      duration: const Duration(milliseconds: 300),
    );
    _prevPos   = widget.currentIndex.toDouble();
    _targetPos = _prevPos;
    _bubblePos = AlwaysStoppedAnimation(_prevPos);
  }

  @override
  void didUpdateWidget(covariant _NavBar old) {
    super.didUpdateWidget(old);
    if (widget.currentIndex != old.currentIndex) {
      _prevPos   = _targetPos;
      _targetPos = widget.currentIndex.toDouble();
      _bubblePos = Tween<double>(begin: _prevPos, end: _targetPos).animate(
        CurvedAnimation(parent: _bubbleCtl, curve: Curves.easeOutBack),
      );
      _bubbleCtl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _bubbleCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark     = AppColors.isDark(context);
    final barColor   = AppColors.surfaceOf(context);
    final primary    = AppColors.primaryOf(context);
    final shadow     = isDark
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
            BoxShadow(color: shadow, blurRadius: 20, offset: const Offset(0, -4)),
          ],
        ),
        child: AnimatedBuilder(
          animation: _bubblePos,
          builder: (context, _) {
            return Stack(
              children: [
                // ── Sliding bubble ──────────────────────────────────────
                // Positions itself under the active tab, slides with easeOutBack
                LayoutBuilder(
                  builder: (context, constraints) {
                    final tabW  = constraints.maxWidth / _tabItems.length;
                    // Center of the active tab slot
                    final cx    = tabW * (_bubblePos.value + 0.5);
                    return Positioned(
                      left: cx - _bubbleSize / 2,
                      top:  (_barHeight - _bubbleSize) / 2 - 6, // slightly up
                      child: Container(
                        width:  _bubbleSize,
                        height: _bubbleSize,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color:      primary.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset:     const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // ── Tab items row ───────────────────────────────────────
                Row(
                  children: List.generate(_tabItems.length, (i) {
                    return Expanded(
                      child: _NavItem(
                        item:    _tabItems[i],
                        active:  widget.currentIndex == i,
                        barHeight: _barHeight,
                        onTap:   () => widget.onTap(i),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Single nav item ──────────────────────────────────────────────────────────
// Mirrors .icon / .icon--expanded CSS behaviour :
//   inactive → scale(0.85), mutedFg
//   active   → scale(1.15), white (over bubble)
class _NavItem extends StatefulWidget {
  final _TabItem item;
  final bool     active;
  final double   barHeight;
  final VoidCallback onTap;

  const _NavItem({
    super.key,
    required this.item,
    required this.active,
    required this.barHeight,
    required this.onTap,
  });

  @override
  State<StatefulWidget> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double>   _scale;
  late final Animation<double>   _lift; // léger lift vers le haut

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // scale : 0.85 → 1.15  (same ratio as CSS .icon → .icon--expanded)
    _scale = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack),
    );
    // lift : 0 → -6 px (léger mouvement vers le haut)
    _lift = Tween<double>(begin: 0, end: -6).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeOutCubic),
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
        height: widget.barHeight,
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (context, _) {
            final isActive = _ctl.value > 0.5;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Icon : scale + lift ───────────────────────────────
                Transform.translate(
                  offset: Offset(0, _lift.value),
                  child: Transform.scale(
                    scale: _scale.value,
                    child: Icon(
                      isActive ? widget.item.activeIcon : widget.item.icon,
                      size:  24,
                      // White on bubble, mutedFg otherwise
                      color: isActive ? Colors.white : mutedFg,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                // ── Label ─────────────────────────────────────────────
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize:   10,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    color:      isActive ? primary : mutedFg,
                    fontFamily: 'Cairo',
                  ),
                  child: Text(
                    widget.item.label,
                    textAlign:     TextAlign.center,
                    textDirection: TextDirection.rtl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
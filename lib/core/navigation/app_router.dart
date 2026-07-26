// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/home_screan.dart';
import '../../features/calendar/calendar_screan.dart';
import '../../features/guide/guide_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/setup/setup_intro_screen.dart';
import '../../features/setup/username_setup_screen.dart';
import '../../shared/providers/providers.dart';
import '../../shared/providers/theme_provider.dart';
import '../../shared/widgets/starfield_background.dart';
import '../../core/theme/app_theme.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

const _tabs = [
  _Tab(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'الرئيسية'),
  _Tab(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'التقويم'),
  _Tab(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'الدليل'),
  _Tab(
      icon: Icons.tune_outlined,
      activeIcon: Icons.tune_rounded,
      label: 'الإعدادات'),
];

class _Tab {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _Tab(
      {required this.icon, required this.activeIcon, required this.label});
}

// ─── Shell ────────────────────────────────────────────────────────────────────
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);
    final currentTab = ref.watch(currentTabProvider);
    final colorTheme = ref.watch(themeColorProvider);

    return planAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
      data: (plan) {
        if (plan == null && currentTab != 2 && currentTab != 3) {
          final userNameAsync = ref.watch(userNameProvider);
          return userNameAsync.when(
            loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator())),
            error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
            data: (userName) {
              if (userName == null) return const UsernameSetupScreen();
              return const SetupIntroScreen();
            },
          );
        }

        final isDark = AppColors.isDark(context);

        return Stack(
          children: [
            // ── Solid base layer ──────────────────────────────────────
            // Paints the real app background behind the transparent Scaffold
            // and behind the rounded nav bar corners.
            Positioned.fill(
              child: ColoredBox(
                color: AppColors.solidBackgroundOf(
                  context,
                  colorTheme: colorTheme,
                ),
              ),
            ),

            // ── Animated starfield (dark mode only) ───────────────────
            if (isDark) const Positioned.fill(child: StarfieldBackground()),

            // ── App content ────────────────────────────────────────────
            Scaffold(
              backgroundColor: Colors.transparent,
              body: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: MediaQuery.of(context).padding.copyWith(
                        bottom: 80 + 10 + MediaQuery.of(context).padding.bottom,
                      ),
                ),
                child: IndexedStack(
                  index: currentTab.clamp(0, 3),
                  children: const [
                    HomeScreen(),
                    CalendarScreen(),
                    GuidePage(),
                    SettingsScreen(),
                  ],
                ),
              ),
              bottomNavigationBar: _NavBar(
                currentIndex: currentTab.clamp(0, 3),
                onTap: (i) => ref.read(currentTabProvider.notifier).state = i,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Nav Bar ─────────────────────────────────────────────────────────────────
// Design : thin pill indicator (h:1.3) at top of active tab
//          icon scales up on active, label below always visible
//          bar is flush with bottom/left/right edges, only top corners rounded
//
// Keeps its own opaque background in both modes: the bar has rounded top
// corners, so if its background were transparent, the starfield behind it
// (dark mode) would show through the small corner areas outside the
// radius — same problem the rest of the app avoids by painting a solid
// layer under the Scaffold. The bar itself isn't part of that transparent
// layer, so it paints its own solid color.
// ─────────────────────────────────────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavBar({required this.currentIndex, required this.onTap});

  static const double _barH = 72;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final surface = AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);
    final shadow = isDark
        ? Colors.black.withValues(alpha: 0.40)
        : Colors.black.withValues(alpha: 0.08);

    return SafeArea(
      top: false,
      child: Container(
        height: _barH,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          border: Border.all(color: border.withValues(alpha: 0.5), width: 0.6),
          boxShadow: [
            BoxShadow(
                color: shadow, blurRadius: 20, offset: const Offset(0, 4)),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              return Expanded(
                child: _NavItem(
                  tab: _tabs[i],
                  active: currentIndex == i,
                  onTap: () => onTap(i),
                  barH: _barH,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─── Single nav item ──────────────────────────────────────────────────────────
// Active  :  thin pill indicator at top  +  icon scale up  +  label primary bold
// Inactive:  no indicator                +  icon normal     +  label muted
class _NavItem extends StatefulWidget {
  final _Tab tab;
  final bool active;
  final VoidCallback onTap;
  final double barH;

  const _NavItem({
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
  late Animation<double> _scale; // icon scale 1.0 → 1.22

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.22).animate(
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
        height: widget.barH,
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (context, _) {
            final isActive = _ctl.value > 0.4;

            return Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // ── Thin pill indicator at top ─────────────────────────
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      width: isActive ? 24.0 : 0.0,
                      height: 1.3,
                      decoration: BoxDecoration(
                        color: isActive ? primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(0.65),
                      ),
                    ),
                  ),
                ),

                // ── Icon + label centered in remaining space ───────────
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Transform.scale(
                        scale: _scale.value,
                        child: Icon(
                          isActive ? widget.tab.activeIcon : widget.tab.icon,
                          size: 22,
                          color: isActive ? primary : mutedFg,
                        ),
                      ),

                      const SizedBox(height: 3),

                      // Label
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? primary : mutedFg,
                          height: 1.0,
                        ),
                        child: Text(
                          widget.tab.label,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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

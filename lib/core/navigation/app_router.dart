// lib/core/navigation/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/home_screan.dart';
import '../../features/calendar/calendar_screan.dart';
import '../../features/daily_challenge/daily_challenge_screen.dart';
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
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      label: 'التحدي'),
  _Tab(
      icon: Icons.tune_outlined,
      activeIcon: Icons.tune_rounded,
      label: 'الإعدادات'),
];

// Index of the tab shown as the elevated, circular "featured" button
// (the one styled like the reference design — center item, no label,
// floating above the bar).
const int _featuredTabIndex = 0;

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
        if (plan == null && currentTab != 2 && currentTab != 3 && currentTab != 4) {
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
        final appBackground = AppColors.solidBackgroundOf(
          context,
          colorTheme: colorTheme,
        );

        return Stack(
          children: [
            // ── Solid base layer ──────────────────────────────────────
            // Paints the real app background behind the transparent Scaffold
            // and behind the rounded nav bar corners.
            Positioned.fill(
              child: ColoredBox(color: appBackground),
            ),

            // ── Animated starfield (dark mode only) ───────────────────
            if (isDark) const Positioned.fill(child: StarfieldBackground()),

            // ── App content ────────────────────────────────────────────
            Scaffold(
              backgroundColor: Colors.transparent,
              // Lets the body extend behind the bottomNavigationBar instead
              // of Scaffold reserving/painting an opaque strip beneath it —
              // that opaque strip was the extra background showing up
              // around the floating featured button.
              extendBody: true,
              body: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  padding: MediaQuery.of(context).padding.copyWith(
                        bottom: _NavBar.totalHeight +
                            MediaQuery.of(context).padding.bottom,
                      ),
                ),
                child: IndexedStack(
                  index: currentTab.clamp(0, 4),
                  children: const [
                    HomeScreen(),
                    CalendarScreen(),
                    GuidePage(),
                    DailyChallengeScreen(),
                    SettingsScreen(),
                  ],
                ),
              ),
              bottomNavigationBar: _NavBar(
                currentIndex: currentTab.clamp(0, 4),
                onTap: (i) => ref.read(currentTabProvider.notifier).state = i,
                backgroundColor: appBackground,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Nav Bar ─────────────────────────────────────────────────────────────────
// Design : dark pill bar, rounded top corners only, flush with bottom/left/
//          right edges — regular tabs are icon + label (muted → primary on
//          active) — the featured tab (_featuredTabIndex) is rendered as a
//          separate circular button that floats above the bar (gradient
//          fill + soft glow), matching the reference screenshot.
// ─────────────────────────────────────────────────────────────────────────────
class _NavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color? backgroundColor;

  const _NavBar({
    required this.currentIndex,
    required this.onTap,
    this.backgroundColor,
  });

  static const double _barH = 72;
  static const double _fabSize = 60;
  static const double _fabOverflow = 24; // extra space reserved above the bar
  static const double _fabTop = 12; // push the fab down (lower = closer to the bar)

  /// The real total visual height of the nav bar (bar + the part of the
  /// floating button that pokes above it). AppShell uses this as the
  /// single source of truth for how much bottom clearance page content
  /// needs, instead of a hard-coded number that can drift out of sync.
  static const double totalHeight = _barH + _fabOverflow;

  // Physical slot (0..4) in the row that stays empty for the floating
  // button — always the middle one, regardless of which tab is featured,
  // so the button stays visually centered.
  static const int _centerSlot = 2;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final surface = backgroundColor ?? AppColors.surfaceOf(context);
    final border = AppColors.borderOf(context);
    final primary = AppColors.primaryOf(context);
    final shadow = isDark
        ? Colors.black.withValues(alpha: 0.40)
        : Colors.black.withValues(alpha: 0.08);

    // Remaining tabs (all except the featured one), in their original
    // order, to fill the 4 regular slots around the center.
    final regularTabIndices = List<int>.generate(_tabs.length, (i) => i)
        .where((i) => i != _featuredTabIndex)
        .toList();

    // Material(type: transparency) kills the implicit opaque background
    // that Scaffold paints behind any custom bottomNavigationBar widget —
    // otherwise it shows through the empty space above the bar (around
    // the floating button) as an unwanted solid block.
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _barH + _fabOverflow,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Bar ──────────────────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: _barH,
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(28),
                      topRight: Radius.circular(28),
                    ),
                    border: Border.all(
                        color: border.withValues(alpha: 0.5), width: 0.6),
                    boxShadow: [
                      BoxShadow(
                          color: shadow,
                          blurRadius: 20,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: List.generate(_tabs.length, (slot) {
                        if (slot == _centerSlot) {
                          // Empty slot: the floating button sits visually
                          // above this spot, but still reserves equal width
                          // so the other tabs stay evenly spaced.
                          return const Expanded(child: SizedBox.shrink());
                        }
                        final orderPos = slot < _centerSlot ? slot : slot - 1;
                        final tabIndex = regularTabIndices[orderPos];
                        return Expanded(
                          child: _NavItem(
                            tab: _tabs[tabIndex],
                            active: currentIndex == tabIndex,
                            onTap: () => onTap(tabIndex),
                            barH: _barH,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              // ── Floating featured button ────────────────────────────
              Positioned(
                top: _fabTop,
                left: 0,
                right: 0,
                child: Center(
                  child: _NavFab(
                    tab: _tabs[_featuredTabIndex],
                    active: currentIndex == _featuredTabIndex,
                    onTap: () => onTap(_featuredTabIndex),
                    size: _fabSize,
                    primary: primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Featured floating button (center circular tab) ──────────────────────────
class _NavFab extends StatelessWidget {
  final _Tab tab;
  final bool active;
  final VoidCallback onTap;
  final double size;
  final Color primary;

  const _NavFab({
    required this.tab,
    required this.active,
    required this.onTap,
    required this.size,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final darkShade = Color.lerp(primary, Colors.black, 0.25) ?? primary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primary, darkShade],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 2,
          ),
          boxShadow: [
            // Soft halo/glow around the button
            BoxShadow(
              color: primary.withValues(alpha: active ? 0.45 : 0.28),
              blurRadius: active ? 22 : 14,
              spreadRadius: active ? 3 : 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          active ? tab.activeIcon : tab.icon,
          color: Colors.white,
          size: size * 0.42,
        ),
      ),
    );
  }
}

// ─── Single nav item (regular icon + label tabs) ─────────────────────────────
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
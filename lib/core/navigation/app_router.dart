// lib/core/navigation/app_router.dart
import 'dart:math' as math;

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
  _TabItem(icon: Icons.home_outlined,           activeIcon: Icons.home,             label: 'الرئيسية'),
  _TabItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month,   label: 'التقويم'),
  _TabItem(icon: Icons.menu_book_outlined,      activeIcon: Icons.menu_book,        label: 'الدليل'),
  _TabItem(icon: Icons.settings_outlined,       activeIcon: Icons.settings,         label: 'الإعدادات'),
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
          // Transparent so the page content shows behind the floating bar
          backgroundColor: Colors.transparent,
          extendBody: true, // body goes under the nav bar area
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

// ─── Floating nav bar with notch dip ─────────────────────────────────────────
class _FloatingNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({required this.currentIndex, required this.onTap});

  @override
  State<_FloatingNavBar> createState() => _FloatingNavBarState();
}

class _FloatingNavBarState extends State<_FloatingNavBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late Animation<double> _notchPos; // 0.0 → 1.0 across tabs
  double _prevPos = 0;
  double _targetPos = 0;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _prevPos   = widget.currentIndex / (_tabItems.length - 1);
    _targetPos = _prevPos;
    _notchPos  = AlwaysStoppedAnimation(_prevPos);
  }

  @override
  void didUpdateWidget(covariant _FloatingNavBar old) {
    super.didUpdateWidget(old);
    if (widget.currentIndex != old.currentIndex) {
      _prevPos   = _targetPos;
      _targetPos = widget.currentIndex / (_tabItems.length - 1);
      _notchPos  = Tween<double>(begin: _prevPos, end: _targetPos).animate(
        CurvedAnimation(parent: _ctl, curve: Curves.easeInOut),
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
    final barColor = AppColors.surfaceOf(context); // white / darkCard
    final primary  = AppColors.primaryOf(context);
    final shadow   = AppColors.isDark(context)
        ? Colors.black.withValues(alpha: 0.30)
        : Colors.black.withValues(alpha: 0.10);

    const barHeight  = 64.0;
    const notchR     = 28.0; // rayon du creux
    const iconR      = 24.0; // rayon du cercle icône (48/2)
    const liftHeight = 22.0; // à quelle hauteur l'icône sort de la barre

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: SizedBox(
          // Extra height for the icon that lifts above the bar
          height: barHeight + liftHeight,
          child: AnimatedBuilder(
            animation: _notchPos,
            builder: (context, _) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Bar with notch ──────────────────────────────────────
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: CustomPaint(
                      painter: _NotchBarPainter(
                        notchProgress: _notchPos.value,
                        color: barColor,
                        shadow: shadow,
                        notchRadius: notchR,
                        barHeight: barHeight,
                      ),
                      child: SizedBox(
                        height: barHeight,
                        child: Row(
                          children: List.generate(_tabItems.length, (i) {
                            return Expanded(
                              child: _NavItem(
                                item: _tabItems[i],
                                active: widget.currentIndex == i,
                                onTap: () => widget.onTap(i),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ),

                  // ── Floating active icon ────────────────────────────────
                  AnimatedBuilder(
                    animation: _notchPos,
                    builder: (context, _) {
                      // Position X du centre de l'icône active
                      final barWidth = MediaQuery.of(context).size.width - 40;
                      final tabW     = barWidth / _tabItems.length;
                      final cx       = tabW * (widget.currentIndex + 0.5);

                      return Positioned(
                        bottom: barHeight - iconR + liftHeight,
                        left: cx - iconR,
                        child: _ActiveBubble(
                          icon: _tabItems[widget.currentIndex].activeIcon,
                          color: primary,
                          radius: iconR,
                          active: true,
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── The circular active icon bubble ─────────────────────────────────────────
class _ActiveBubble extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double radius;
  final bool active;

  const _ActiveBubble({
    required this.icon,
    required this.color,
    required this.radius,
    required this.active,
  });

  @override
  State<_ActiveBubble> createState() => _ActiveBubbleState();
}

class _ActiveBubbleState extends State<_ActiveBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack),
    );
    if (widget.active) _ctl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _ActiveBubble old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _ctl.reset();
      _ctl.forward();
    }
  }

  @override
  void dispose() { _ctl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final d = widget.radius * 2;
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.40),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(widget.icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ─── Bar with animated notch painted under the active icon ───────────────────
class _NotchBarPainter extends CustomPainter {
  final double notchProgress; // 0.0 → 1.0 position across width
  final Color color;
  final Color shadow;
  final double notchRadius;
  final double barHeight;

  const _NotchBarPainter({
    required this.notchProgress,
    required this.color,
    required this.shadow,
    required this.notchRadius,
    required this.barHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * notchProgress * ((_tabItems.length - 1) / _tabItems.length)
             + size.width / _tabItems.length / 2
             + size.width * notchProgress / _tabItems.length * 0;

    // Recalculate: cx is the center of the active tab slot
    final tabW      = size.width / _tabItems.length;
    // notchProgress goes 0→1 mapping tab 0→3
    final activeTab = notchProgress * (_tabItems.length - 1);
    final cxFinal   = tabW * (activeTab + 0.5);

    final r     = notchRadius;
    final nr    = r + 6; // extra clearance around the circle
    final paint = Paint()..color = color;

    // Shadow
    final shadowPaint = Paint()
      ..color       = shadow
      ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 12);

    final path = _buildPath(size, cxFinal, nr);
    canvas.drawShadow(path, shadow, 8, false);
    canvas.drawPath(path, paint);
  }

  Path _buildPath(Size size, double cx, double nr) {
    const cornerR = 32.0;
    final h       = barHeight;
    final w       = size.width;

    // Notch dip curve control points
    final notchLeft  = cx - nr;
    final notchRight = cx + nr;

    final path = Path();
    path.moveTo(cornerR, 0);

    if (notchLeft > cornerR) {
      path.lineTo(notchLeft - nr * 0.4, 0);
      // Smooth dip into the notch
      path.cubicTo(
        notchLeft,       0,
        cx - nr * 0.5,  nr * 0.85,
        cx,              nr * 0.85,
      );
      path.cubicTo(
        cx + nr * 0.5,  nr * 0.85,
        notchRight,      0,
        notchRight + nr * 0.4, 0,
      );
    }

    path.lineTo(w - cornerR, 0);
    // Top-right corner
    path.quadraticBezierTo(w, 0, w, cornerR);
    path.lineTo(w, h - cornerR);
    // Bottom-right corner
    path.quadraticBezierTo(w, h, w - cornerR, h);
    path.lineTo(cornerR, h);
    // Bottom-left corner
    path.quadraticBezierTo(0, h, 0, h - cornerR);
    path.lineTo(0, cornerR);
    // Top-left corner
    path.quadraticBezierTo(0, 0, cornerR, 0);
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _NotchBarPainter old) =>
      old.notchProgress != notchProgress || old.color != color;
}

// ─── Individual nav item (inactive only — active is the floating bubble) ──────
class _NavItem extends StatelessWidget {
  final _TabItem item;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.item, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final mutedFg = AppColors.mutedFgOf(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: active ? 0.0 : 1.0,
          child: Icon(item.icon, color: mutedFg, size: 22),
        ),
      ),
    );
  }
}
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Splash screen — timeline 2.3 s :
///   0 → 35 %  : fade-in + scale du badge (0.88 → 1.0)
///  20 → 70 %  : soft orbiting glow around the icon (NO border)
///  80 → 100 % : fade-out with smooth cross-fade to the app
class AppStartSplashScreen extends StatefulWidget {
  final Widget child;

  const AppStartSplashScreen({
    super.key,
    required this.child,
  });

  @override
  State<AppStartSplashScreen> createState() => _AppStartSplashScreenState();
}

class _AppStartSplashScreenState extends State<AppStartSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctl;

  // ── apparition ──────────────────────────────────────────────────────────────
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  // ── lumière orbitante ───────────────────────────────────────────────────────
  late final Animation<double> _shine;

  // ── disparition ─────────────────────────────────────────────────────────────
  late final Animation<double> _fadeOut;

  bool _showChild = false;

  @override
  void initState() {
    super.initState();

    // FIXED: Set this ONCE in initState, not on every build frame.
    // Force light-mode status bar so icons stay dark on the light splash.
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2300),
    );

    _fadeIn = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.00, 0.35, curve: Curves.easeOut),
    );

    _scale = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctl,
        curve: const Interval(0.00, 0.35, curve: Curves.easeOutCubic),
      ),
    );

    // Glow animation: starts at 20%, ends at 70%
    _shine = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.20, 0.70, curve: Curves.easeInOut),
    );

    _fadeOut = CurvedAnimation(
      parent: _ctl,
      curve: const Interval(0.80, 1.00, curve: Curves.easeIn),
    );

    unawaited(_run());
  }

  Future<void> _run() async {
    await _ctl.forward();
    if (!mounted) return;
    setState(() => _showChild = true);
  }

  @override
  void dispose() {
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Always use light background — ignore the app's dark mode toggle.
    // If your AppColors.background is theme-dependent, replace with a fixed
    // light color, e.g. const Color(0xFFFFFFFF).
    final bg = AppColors.background;
    final primary = AppColors.primaryOf(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: _showChild
          ? widget.child
          : Scaffold(
              key: const ValueKey('splash'),
              backgroundColor: bg,
              body: Center(
                child: AnimatedBuilder(
                  animation: _ctl,
                  builder: (context, child) {
                    final opacity = (_fadeIn.value * (1.0 - _fadeOut.value))
                        .clamp(0.0, 1.0);
                    return Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: _scale.value,
                        child: child,
                      ),
                    );
                  },
                  child: _IconBadge(
                    shineAnimation: _shine,
                    primary: primary,
                  ),
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge : icône centrée avec ombres + lueur orbitante SANS bordure visible
// ─────────────────────────────────────────────────────────────────────────────

class _IconBadge extends StatelessWidget {
  final Animation<double> shineAnimation;
  final Color primary;

  const _IconBadge({
    required this.shineAnimation,
    required this.primary,
  });

  static const double _size = 124.0;
  static const double _radius = 28.0;

  @override
  Widget build(BuildContext context) {
    // FIXED: No more isDark checks — splash always behaves like light mode.
    return AnimatedBuilder(
      animation: shineAnimation,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _ShineArcPainter(
            progress: shineAnimation.value,
            radius: _radius,
            shineColor: Colors.white,
          ),
          child: child,
        );
      },
      child: Container(
        width: _size,
        height: _size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_radius),
          // NO border here — only soft shadows for depth
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.16),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: Image.asset(
            'assets/icon/icon.png',
            width: _size,
            height: _size,
            fit: BoxFit.cover,
            // FIXED: Added fallback so the app doesn't break if asset is missing
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: primary,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.apps,
                  size: 56,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter : lueur orbitante douce — AUCUNE bordure visible
// ─────────────────────────────────────────────────────────────────────────────

class _ShineArcPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final double radius;
  final Color shineColor;

  const _ShineArcPainter({
    required this.progress,
    required this.radius,
    required this.shineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    final metric = path.computeMetrics().first;
    final total = metric.length;

    // Arc length: ~25% of the perimeter for a soft glow
    const arcFraction = 0.25;
    final arcLen = total * arcFraction;

    // Head travels the full perimeter
    final head = (progress * total).clamp(0.0, total);
    final tail = (head - arcLen).clamp(0.0, total);

    if (head <= tail) return;

    final arcPath = metric.extractPath(tail, head);

    // OUTER HALO — very wide, very soft, no hard line
    canvas.drawPath(
      arcPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18.0
        ..strokeCap = StrokeCap.round
        ..color = shineColor.withValues(alpha: 0.10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // MIDDLE GLOW
    canvas.drawPath(
      arcPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..strokeCap = StrokeCap.round
        ..color = shineColor.withValues(alpha: 0.22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // INNER CORE — still soft, absolutely no sharp border
    canvas.drawPath(
      arcPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..color = shineColor.withValues(alpha: 0.50)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(covariant _ShineArcPainter old) =>
      old.progress != progress || old.shineColor != shineColor;
}
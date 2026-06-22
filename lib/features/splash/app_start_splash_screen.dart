import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

/// Splash screen — timeline 2.3 s :
///   0 → 35 %  : fade-in + scale du badge (0.88 → 1.0)
///  20 → 70 %  : arc lumineux qui tourne autour du cadre de l'icône seulement
///  80 → 100 % : fade-out vers l'app
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

  // ── lumière sur le cadre ────────────────────────────────────────────────────
  late final Animation<double> _shine;

  // ── disparition ─────────────────────────────────────────────────────────────
  late final Animation<double> _fadeOut;

  bool _showChild = false;

  @override
  void initState() {
    super.initState();

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

    // arc lumineux : démarre à 20 %, finit à 70 %
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
    if (_showChild) return widget.child;

    final isDark = AppColors.isDark(context);
    final bg = isDark ? AppColors.darkBackground : AppColors.background;
    final primary = AppColors.primaryOf(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctl,
          builder: (context, child) {
            final opacity =
                (_fadeIn.value * (1.0 - _fadeOut.value)).clamp(0.0, 1.0);
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Badge : icône centrée dans un cadre avec shadow + arc lumineux sur le contour
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
  static const double _padding = 18.0;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final surface = AppColors.surfaceOf(context);

    // Couleur de l'arc lumineux : blanc en light, or en dark
    final shineColor = isDark ? AppColors.darkPrimary : Colors.white;

    return AnimatedBuilder(
      animation: shineAnimation,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _ShineArcPainter(
            progress: shineAnimation.value,
            radius: _radius,
            borderColor: primary.withValues(alpha: 0.22),
            shineColor: shineColor,
          ),
          child: child,
        );
      },
      child: Container(
        width: _size,
        height: _size,
        padding: const EdgeInsets.all(_padding),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(_radius),
          boxShadow: [
            // Ombre principale colorée
            BoxShadow(
              color: primary.withValues(alpha: isDark ? 0.30 : 0.18),
              blurRadius: 32,
              spreadRadius: 0,
              offset: const Offset(0, 14),
            ),
            // Ombre de profondeur neutre
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius - _padding * 0.6),
          child: Image.asset(
            'assets/icon/icon.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painter : trait de base fin + arc lumineux qui tourne sur le contour du cadre
// ─────────────────────────────────────────────────────────────────────────────

class _ShineArcPainter extends CustomPainter {
  final double progress;   // 0.0 → 1.0
  final double radius;
  final Color borderColor;
  final Color shineColor;

  const _ShineArcPainter({
    required this.progress,
    required this.radius,
    required this.borderColor,
    required this.shineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);

    // ── trait de base : contour discret toujours visible ─────────────────────
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = borderColor,
    );

    if (progress <= 0.0) return;

    // ── arc lumineux ─────────────────────────────────────────────────────────
    final metric = path.computeMetrics().first;
    final total = metric.length;

    // L'arc fait 22 % du périmètre
    const arcFraction = 0.22;
    final arcLen = total * arcFraction;

    // La tête de l'arc parcourt tout le périmètre
    final head = (progress * total).clamp(0.0, total);
    final tail = (head - arcLen).clamp(0.0, total);

    if (head <= tail) return;

    final arcPath = metric.extractPath(tail, head);

    // Lueur douce derrière l'arc
    canvas.drawPath(
      arcPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round
        ..color = shineColor.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Arc principal net
    canvas.drawPath(
      arcPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [
            shineColor.withValues(alpha: 0.0),
            shineColor.withValues(alpha: 0.95),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _ShineArcPainter old) =>
      old.progress != progress ||
      old.borderColor != borderColor ||
      old.shineColor != shineColor;
}
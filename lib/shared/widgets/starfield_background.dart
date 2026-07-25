// lib/shared/widgets/starfield_background.dart
//
// Ambient animated night sky for dark mode. Pure CustomPainter driven by a
// single AnimationController — no extra packages. Meant to sit as the
// bottom-most layer of a Stack behind the app content (see AppShell in
// app_router.dart), painted over a solid dark background color.
//
// Behavior:
//   - N small stars, each twinkling (opacity pulses on its own phase/speed
//     so they don't blink in sync) and drifting slowly in a random
//     direction, wrapping around the edges of the screen.
//   - Occasional shooting stars: spawn at random intervals, streak across
//     on a random diagonal once, then disappear.
//
// Usage:
//   Stack(
//     children: [
//       Positioned.fill(child: ColoredBox(color: AppColors.darkBackground)),
//       if (isDark) const Positioned.fill(child: StarfieldBackground()),
//       yourContent,
//     ],
//   )

import 'dart:math' as math;
import 'package:flutter/material.dart';

class StarfieldBackground extends StatefulWidget {
  /// Number of ambient twinkling stars.
  final int starCount;

  /// Roughly how many seconds between shooting stars (average; actual
  /// gaps are randomized around this).
  final double shootingStarIntervalSeconds;

  const StarfieldBackground({
    super.key,
    this.starCount = 90,
    this.shootingStarIntervalSeconds = 6,
  });

  @override
  State<StarfieldBackground> createState() => _StarfieldBackgroundState();
}

class _StarfieldBackgroundState extends State<StarfieldBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final math.Random _rng;

  List<_Star> _stars = [];
  final List<_ShootingStar> _shootingStars = [];
  Size _lastSize = Size.zero;
  double _nextShootAt = 0;

  @override
  void initState() {
    super.initState();
    _rng = math.Random(7); // seeded so the field feels stable across hot reloads
    _nextShootAt = _randomShootGap();

    // A long repeating controller acts as our animation clock. We derive
    // per-star motion from elapsed seconds rather than the 0..1 controller
    // value, so stars can drift/twinkle continuously without a visible loop
    // seam.
    _ctrl = AnimationController(vsync: this, duration: const Duration(days: 1))
      ..addListener(_onTick)
      ..repeat();
  }

  double _randomShootGap() {
    // Randomize around the requested average so shooting stars don't fire
    // on a metronome.
    final base = widget.shootingStarIntervalSeconds;
    return base * (0.6 + _rng.nextDouble() * 1.2);
  }

  void _ensureStars(Size size) {
    if (size == _lastSize && _stars.isNotEmpty) return;
    _lastSize = size;
    _stars = List.generate(widget.starCount, (_) => _Star.random(_rng, size));
  }

  void _onTick() {
    if (_lastSize == Size.zero) {
      setState(() {}); // trigger a build so LayoutBuilder can give us a size
      return;
    }

    // Spawn shooting stars on their own timer, independent of frame rate.
    final tSeconds = (_ctrl.lastElapsedDuration?.inMilliseconds ?? 0) / 1000.0;
    if (tSeconds >= _nextShootAt) {
      _shootingStars.add(_ShootingStar.random(_rng, _lastSize, tSeconds));
      _nextShootAt = tSeconds + _randomShootGap();
    }
    _shootingStars.removeWhere((s) => tSeconds - s.startTime > s.lifetime);

    setState(() {});
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Purely decorative — never intercepts taps meant for real content.
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          _ensureStars(size);
          final tSeconds =
              (_ctrl.lastElapsedDuration?.inMilliseconds ?? 0) / 1000.0;

          return CustomPaint(
            size: size,
            painter: _StarfieldPainter(
              stars: _stars,
              shootingStars: _shootingStars,
              time: tSeconds,
            ),
          );
        },
      ),
    );
  }
}

// ─── Star model ─────────────────────────────────────────────────────────────
class _Star {
  final Offset position; // normalized 0..1 within the canvas
  final double radius;
  final double baseOpacity;
  final double twinkleSpeed; // radians/sec
  final double twinklePhase;
  final Offset driftPerSecond; // normalized units/sec, very small

  _Star({
    required this.position,
    required this.radius,
    required this.baseOpacity,
    required this.twinkleSpeed,
    required this.twinklePhase,
    required this.driftPerSecond,
  });

  factory _Star.random(math.Random rng, Size size) {
    final angle = rng.nextDouble() * 2 * math.pi;
    // Very slow drift: a star crosses the screen roughly once every
    // 3–7 minutes, which reads as "ambient" rather than "moving".
    final speed = 0.0009 + rng.nextDouble() * 0.0014;
    return _Star(
      position: Offset(rng.nextDouble(), rng.nextDouble()),
      radius: 0.6 + rng.nextDouble() * 1.6,
      baseOpacity: 0.35 + rng.nextDouble() * 0.55,
      twinkleSpeed: 0.6 + rng.nextDouble() * 1.8,
      twinklePhase: rng.nextDouble() * 2 * math.pi,
      driftPerSecond: Offset(math.cos(angle), math.sin(angle)) * speed,
    );
  }
}

// ─── Shooting star model ────────────────────────────────────────────────────
class _ShootingStar {
  final Offset start; // normalized
  final Offset end; // normalized
  final double startTime; // seconds, matches controller clock
  final double lifetime; // seconds

  _ShootingStar({
    required this.start,
    required this.end,
    required this.startTime,
    required this.lifetime,
  });

  factory _ShootingStar.random(math.Random rng, Size size, double now) {
    // Start somewhere in the upper 2/3 of the screen, travel diagonally
    // down-and-across, like a real meteor streak.
    final startX = rng.nextDouble() * 0.7;
    final startY = rng.nextDouble() * 0.4;
    final travel = 0.35 + rng.nextDouble() * 0.25;
    final angle = (math.pi / 5) + rng.nextDouble() * (math.pi / 10); // ~36-54°
    final end = Offset(
      startX + math.cos(angle) * travel,
      startY + math.sin(angle) * travel,
    );
    return _ShootingStar(
      start: Offset(startX, startY),
      end: end,
      startTime: now,
      lifetime: 0.7 + rng.nextDouble() * 0.4,
    );
  }

  /// 0..1 progress through its streak-and-fade lifetime.
  double progress(double now) =>
      ((now - startTime) / lifetime).clamp(0.0, 1.0);
}

// ─── Painter ─────────────────────────────────────────────────────────────────
class _StarfieldPainter extends CustomPainter {
  final List<_Star> stars;
  final List<_ShootingStar> shootingStars;
  final double time;

  _StarfieldPainter({
    required this.stars,
    required this.shootingStars,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()..style = PaintingStyle.fill;

    for (final star in stars) {
      // Wrap-around drift: position + drift*time, modulo 1.0.
      final dx = (star.position.dx + star.driftPerSecond.dx * time) % 1.0;
      final dy = (star.position.dy + star.driftPerSecond.dy * time) % 1.0;
      final nx = dx < 0 ? dx + 1.0 : dx;
      final ny = dy < 0 ? dy + 1.0 : dy;

      final twinkle =
          (math.sin(time * star.twinkleSpeed + star.twinklePhase) + 1) / 2;
      final opacity =
          (star.baseOpacity * (0.45 + twinkle * 0.55)).clamp(0.0, 1.0);

      final center = Offset(nx * size.width, ny * size.height);

      // Soft glow behind the core dot for larger stars only, kept subtle.
      if (star.radius > 1.4) {
        starPaint.color = Colors.white.withValues(alpha: opacity * 0.18);
        canvas.drawCircle(center, star.radius * 2.6, starPaint);
      }

      starPaint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(center, star.radius, starPaint);
    }

    final streakPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final s in shootingStars) {
      final t = s.progress(time);
      // Head races ahead of the tail so we get a comet-like streak that
      // fades in, travels, then fades out.
      final headT = t;
      final tailT = math.max(0.0, t - 0.22);

      final head = Offset.lerp(s.start, s.end, headT)!;
      final tail = Offset.lerp(s.start, s.end, tailT)!;

      final fade = t < 0.15
          ? t / 0.15
          : t > 0.75
              ? (1 - t) / 0.25
              : 1.0;

      streakPaint
        ..color = Colors.white.withValues(alpha: (0.85 * fade).clamp(0.0, 1.0))
        ..strokeWidth = 1.6;

      canvas.drawLine(
        Offset(tail.dx * size.width, tail.dy * size.height),
        Offset(head.dx * size.width, head.dy * size.height),
        streakPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarfieldPainter oldDelegate) => true;
}
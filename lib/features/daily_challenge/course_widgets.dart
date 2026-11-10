import 'package:flutter/material.dart';

import 'data/course_models.dart';

/// Warm gold used for notes and examples.
const Color kGold = Color(0xFFB7791F);

const List<double> _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];

/// Full-bleed course cover: image (or gradient fallback) + dark scrim so
/// white text on top is always readable. Put inside a sized, clipped parent.
class CourseCoverBackground extends StatelessWidget {
  final Course course;

  /// Grayscale + heavier scrim (used for locked / coming-soon courses).
  final bool muted;

  const CourseCoverBackground({
    super.key,
    required this.course,
    this.muted = false,
  });

  Widget _fallback() {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                course.accent,
                Color.lerp(course.accent, Colors.black, 0.5)!,
              ],
            ),
          ),
        ),
        PositionedDirectional(
          end: -18,
          top: -12,
          child: Icon(
            course.icon,
            size: 150,
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget image = course.coverAsset == null
        ? _fallback()
        : Image.asset(
            course.coverAsset!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => _fallback(),
          );

    if (muted) {
      image = ColorFiltered(
        colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
        child: image,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: muted ? 0.35 : 0.10),
                Colors.black.withValues(alpha: muted ? 0.85 : 0.78),
              ],
              stops: const [0.2, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

/// Thin rounded progress bar.
class SlimProgress extends StatelessWidget {
  final double value;
  final Color color;
  final Color? trackColor;
  final double height;

  const SlimProgress({
    super.key,
    required this.value,
    required this.color,
    this.trackColor,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        minHeight: height,
        value: value.clamp(0.0, 1.0).toDouble(),
        backgroundColor: trackColor ?? color.withValues(alpha: 0.12),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}

/// Small translucent label meant to sit on top of an image.
class GlassPill extends StatelessWidget {
  final String text;
  final IconData? icon;

  const GlassPill({super.key, required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
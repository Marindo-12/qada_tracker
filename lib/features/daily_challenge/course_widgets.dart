import 'package:flutter/material.dart';

import 'data/fiqh_questions.dart';

/// Rough study time: ~2 minutes per lesson.
int lessonMinutes(int lessons) => lessons * 2;

/// Rounded tinted square that shows a course icon (or its custom PNG asset).
class CourseIcon extends StatelessWidget {
  final FiqhSubject subject;
  final Color color;
  final double boxSize;
  final double iconSize;

  const CourseIcon({
    super.key,
    required this.subject,
    required this.color,
    this.boxSize = 52,
    this.iconSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boxSize,
      height: boxSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(boxSize * 0.32),
      ),
      child: subject.iconAsset != null
          ? Image.asset(
              subject.iconAsset!,
              width: iconSize,
              height: iconSize,
              color: color,
              colorBlendMode: BlendMode.srcIn,
            )
          : Icon(subject.icon, color: color, size: iconSize),
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
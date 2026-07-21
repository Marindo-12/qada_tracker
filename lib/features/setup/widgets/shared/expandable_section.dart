import 'package:flutter/material.dart';

/// Expand/collapse a [child] by driving height factor + opacity off an
/// externally-owned [AnimationController] (call .forward()/.reverse() on it).
class ExpandableSection extends StatelessWidget {
  final AnimationController controller;
  final Widget child;

  const ExpandableSection({super.key, required this.controller, required this.child});

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: curved.value,
            child: Opacity(
              opacity: curved.value,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
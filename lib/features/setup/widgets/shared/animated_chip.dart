import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../design/design_tokens.dart';

/// A pill-shaped choice chip with press + hover scale feedback, driven by
/// an [AnimationController] (no flutter_animate).
class AnimatedChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AnimatedChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  State<AnimatedChip> createState() => _AnimatedChipState();
}

class _AnimatedChipState extends State<AnimatedChip> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: SetupDS.fast);
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final border = AppColors.borderOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _controller.animateTo(0.4),
      onExit: (_) => _controller.animateTo(0),
      child: GestureDetector(
        onTapDown: (_) => _controller.animateTo(1),
        onTapUp: (_) => _controller.animateTo(0),
        onTapCancel: () => _controller.animateTo(0),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _scale,
          builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
          child: AnimatedContainer(
            duration: SetupDS.fast,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: widget.selected ? primary.withValues(alpha: 0.08) : Colors.transparent,
              border: Border.all(color: widget.selected ? primary : border),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                color: widget.selected ? primary : mutedFg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
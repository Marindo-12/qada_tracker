import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../design/design_tokens.dart';

/// Custom animated toggle switch — thumb + track color interpolated with
/// [AnimationController] + [Color.lerp]/[Alignment.lerp] via [AnimatedBuilder].
class AnimatedToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const AnimatedToggle({super.key, required this.value, required this.onChanged});

  @override
  State<AnimatedToggle> createState() => _AnimatedToggleState();
}

class _AnimatedToggleState extends State<AnimatedToggle> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SetupDS.fast,
      value: widget.value ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedToggle old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primaryOf(context);
    final track = AppColors.mutedOf(context);
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: curved,
        builder: (context, _) {
          final t = curved.value;
          return Container(
            width: 44,
            height: 26,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Color.lerp(track.withValues(alpha: 0.6), primary, t),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Align(
              alignment: Alignment.lerp(Alignment.centerRight, Alignment.centerLeft, t)!,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
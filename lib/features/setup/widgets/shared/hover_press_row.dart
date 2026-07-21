import 'package:flutter/material.dart';

import '../../design/design_tokens.dart';

/// Wraps a row (e.g. a toggle + label) with a hover/press "lift" value
/// (0..1) passed to [builder], so the row can subtly react — e.g. tinting
/// its label color — without a full custom hit-test widget per use site.
class HoverPressRow extends StatefulWidget {
  final VoidCallback onTap;
  final Widget Function(BuildContext context, double lift) builder;

  const HoverPressRow({super.key, required this.onTap, required this.builder});

  @override
  State<HoverPressRow> createState() => _HoverPressRowState();
}

class _HoverPressRowState extends State<HoverPressRow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _lift;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: SetupDS.fast);
    _lift = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setTarget(double target) => _controller.animateTo(target, curve: Curves.easeOut);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setTarget(0.5),
      onExit: (_) => _setTarget(0),
      child: GestureDetector(
        onTapDown: (_) => _setTarget(1),
        onTapUp: (_) => _setTarget(0.5),
        onTapCancel: () => _setTarget(0),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _lift,
          builder: (context, _) => widget.builder(context, _lift.value),
        ),
      ),
    );
  }
}
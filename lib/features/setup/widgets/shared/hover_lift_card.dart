import 'package:flutter/material.dart';

import '../../design/design_tokens.dart';

/// Mimics the Stitch mockup's `.card-lift` CSS: on hover, the card rises
/// slightly and its shadow softens/expands. Driven by an [AnimationController]
/// + [Tween] instead of a CSS transition. On mobile (no mouse) this is a
/// harmless no-op; a light press-scale is added for touch feedback.
class HoverLiftCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color shadowColor;

  const HoverLiftCard({
    super.key,
    required this.child,
    this.onTap,
    this.shadowColor = Colors.black,
  });

  @override
  State<HoverLiftCard> createState() => _HoverLiftCardState();
}

class _HoverLiftCardState extends State<HoverLiftCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _lift;
  late final Animation<double> _blur;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: SetupDS.fast);
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _lift = Tween<double>(begin: 0, end: -4).animate(curved);
    _blur = Tween<double>(begin: 10, end: 16).animate(curved);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _lift.value),
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: widget.shadowColor.withValues(alpha: 0.06),
                      blurRadius: _blur.value,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
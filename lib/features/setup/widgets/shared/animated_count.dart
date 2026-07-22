import 'package:flutter/material.dart';

import '../../../../core/utils/app_utils.dart';

/// Animates a number counting up/down to [value] whenever it changes,
/// using an [AnimationController] + [Tween] (no implicit/package animation
/// helpers). Renders through the app's [formatNumber] so Arabic-Indic
/// digits still work.
class AnimatedCount extends StatefulWidget {
  final int value;
  final bool useArabic;
  final TextStyle? style;
  final TextAlign textAlign;

  const AnimatedCount({
    super.key,
    required this.value,
    required this.useArabic,
    this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  State<AnimatedCount> createState() => _AnimatedCountState();
}

class _AnimatedCountState extends State<AnimatedCount> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  late int _from;

  @override
  void initState() {
    super.initState();
    _from = widget.value;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _animation = AlwaysStoppedAnimation<double>(widget.value.toDouble());
  }

  @override
  void didUpdateWidget(covariant AnimatedCount old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value) {
      _from = old.value;
      _animation = Tween<double>(begin: _from.toDouble(), end: widget.value.toDouble()).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        return Text(
          formatNumber(_animation.value.round(), useArabic: widget.useArabic),
          style: widget.style,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}
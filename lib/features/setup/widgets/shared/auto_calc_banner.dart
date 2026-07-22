import 'package:flutter/material.dart';

import '../../../../core/utils/app_utils.dart';
import '../../design/design_tokens.dart';

/// Card offering to auto-fill years/months/days from the bulugh →
/// commitment date gap. Same public API as before (autoCalcDays, useArabic,
/// primary, onAccept) — only the trailing action changed: a small
/// magic-wand button that spins into a reload icon while the numbers
/// count up in the fields below, instead of a static chevron.
class AutoCalcBanner extends StatefulWidget {
  final int autoCalcDays;
  final bool useArabic;
  final Color primary;
  final VoidCallback onAccept;

  const AutoCalcBanner({
    super.key,
    required this.autoCalcDays,
    required this.useArabic,
    required this.primary,
    required this.onAccept,
  });

  @override
  State<AutoCalcBanner> createState() => _AutoCalcBannerState();
}

class _AutoCalcBannerState extends State<AutoCalcBanner> with TickerProviderStateMixin {
  late final AnimationController _hoverCtrl;
  late final AnimationController _spinCtrl;
  bool _calculating = false;

  // Matches the count-up duration used by AnimatedCount / the number
  // fields, so the spinner and the climbing digits finish together.
  static const _calcDuration = Duration(milliseconds: 650);

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: SetupDS.fast);
    _spinCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_calculating) return;
    setState(() => _calculating = true);
    _spinCtrl.repeat();
    // Fire the actual value update right away — the number fields and
    // stat cards animate their own count-up as soon as they receive it.
    widget.onAccept();
    await Future.delayed(_calcDuration);
    if (!mounted) return;
    _spinCtrl.stop();
    setState(() => _calculating = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = widget.primary;

    return MouseRegion(
      onEnter: (_) => _hoverCtrl.forward(),
      onExit: (_) => _hoverCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _hoverCtrl,
        builder: (context, child) {
          final t = _hoverCtrl.value;
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Color.lerp(primary.withValues(alpha: 0.05), primary.withValues(alpha: 0.08), t),
              borderRadius: BorderRadius.circular(SetupDS.radiusMd),
              border: Border.all(color: primary.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(color: primary.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 4)),
              ],
            ),
            child: child,
          );
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Icon(Icons.calculate_outlined, color: primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('الحساب التلقائي من التواريخ',
                      style: theme.textTheme.labelLarge?.copyWith(color: primary, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                    '${formatNumber(widget.autoCalcDays, useArabic: widget.useArabic)} يوم',
                    style: theme.textTheme.bodySmall?.copyWith(color: primary.withValues(alpha: 0.75)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _WandButton(
              primary: primary,
              spinCtrl: _spinCtrl,
              calculating: _calculating,
              onTap: _handleTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _WandButton extends StatelessWidget {
  final Color primary;
  final AnimationController spinCtrl;
  final bool calculating;
  final VoidCallback onTap;

  const _WandButton({
    required this.primary,
    required this.spinCtrl,
    required this.calculating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
        child: RotationTransition(
          turns: spinCtrl,
          child: Center(
            child: AnimatedSwitcher(
              duration: SetupDS.fast,
              child: Icon(
                calculating ? Icons.refresh_rounded : Icons.auto_fix_high_rounded,
                key: ValueKey(calculating),
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
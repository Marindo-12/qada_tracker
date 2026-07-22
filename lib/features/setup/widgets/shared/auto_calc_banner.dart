import 'package:flutter/material.dart';

import '../../../../core/utils/app_utils.dart';
import '../../design/design_tokens.dart';

/// Whole-card clickable banner offering to auto-fill years/months/days from
/// the bulugh → commitment date gap. Same public API as before
/// (autoCalcDays, useArabic, primary, onAccept) — only the visuals changed,
/// per the Stitch mockup: no separate "apply" button, the whole card taps.
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

class _AutoCalcBannerState extends State<AutoCalcBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _hoverCtrl;

  @override
  void initState() {
    super.initState();
    _hoverCtrl = AnimationController(vsync: this, duration: SetupDS.fast);
  }

  @override
  void dispose() {
    _hoverCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = widget.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _hoverCtrl.forward(),
      onExit: (_) => _hoverCtrl.reverse(),
      child: GestureDetector(
        onTap: widget.onAccept,
        child: AnimatedBuilder(
          animation: _hoverCtrl,
          builder: (context, child) {
            final t = _hoverCtrl.value;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color.lerp(primary.withValues(alpha: 0.05), primary.withValues(alpha: 0.10), t),
                borderRadius: BorderRadius.circular(SetupDS.radiusMd),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
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
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: primary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      '${formatNumber(widget.autoCalcDays, useArabic: widget.useArabic)} يوم — انقر للتطبيق',
                      style: theme.textTheme.bodySmall?.copyWith(color: primary.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_left_rounded, color: primary),
            ],
          ),
        ),
      ),
    );
  }
}
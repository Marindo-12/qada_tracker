import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/utils/app_utils.dart';
import '../../design/design_tokens.dart';

class AutoCalcBanner extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withValues(alpha: 0.12), primary.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SetupDS.radiusMd),
        border: Border.all(color: primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(color: primary.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: Icon(Icons.auto_fix_high, color: primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('حساب تلقائي من التواريخ',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: primary, fontWeight: FontWeight.w700)),
                Text(
                  '${formatNumber(autoCalcDays, useArabic: useArabic)} يوم — ${formatNumber(autoCalcDays * 5, useArabic: useArabic)} صلاة',
                  style: theme.textTheme.bodySmall?.copyWith(color: primary.withValues(alpha: 0.75)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onAccept,
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SetupDS.radiusSm)),
              textStyle: const TextStyle(fontSize: 13),
            ),
            child: const Text('تطبيق'),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.08);
  }
}

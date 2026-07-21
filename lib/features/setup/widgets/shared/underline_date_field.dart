import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../design/design_tokens.dart';

/// Underline-style date field (matches the Stitch mockups).
/// [highlight] (0..1) drives a transient pulse on the border — used to draw
/// the eye back to the field right after a quick-pick fills it in.
class UnderlineDateField extends StatelessWidget {
  final String label;
  final String? hint;
  final IconData icon;
  final DateTime? value;
  final DateTime firstDate, lastDate;
  final double highlight;
  final ValueChanged<DateTime?> onChanged;

  const UnderlineDateField({
    super.key,
    required this.label,
    this.hint,
    required this.icon,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.highlight = 0,
  });

  DateTime _clamp(DateTime d, DateTime mn, DateTime mx) {
    if (d.isBefore(mn)) return mn;
    if (d.isAfter(mx)) return mx;
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);
    final initial = _clamp(value ?? DateTime.now(), firstDate, lastDate);

    final borderColor = Color.lerp(
      value != null ? primary.withValues(alpha: 0.5) : border,
      primary,
      highlight,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: mutedFg,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: firstDate,
              lastDate: lastDate,
              locale: const Locale('ar'),
            );
            if (picked != null) onChanged(picked);
          },
          child: AnimatedContainer(
            duration: SetupDS.fast,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: borderColor!, width: highlight > 0 ? 2 : 1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value != null ? formatArabicDate(dateToIso(value!)) : (hint ?? 'اختر تاريخاً'),
                    style: theme.textTheme.bodyLarge?.copyWith(color: value != null ? null : mutedFg),
                  ),
                ),
                Icon(icon, size: 20, color: value != null ? primary : mutedFg),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
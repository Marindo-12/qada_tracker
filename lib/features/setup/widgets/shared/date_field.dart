import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../design/design_tokens.dart';

class SetupDateField extends StatelessWidget {
  final String? hint;
  final DateTime? value;
  final DateTime firstDate, lastDate;
  final ValueChanged<DateTime?> onChanged;

  const SetupDateField({
    super.key,
    this.hint,
    required this.value,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  DateTime _clamp(DateTime d, DateTime mn, DateTime mx) {
    if (d.isBefore(mn)) return mn;
    if (d.isAfter(mx)) return mx;
    return d;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = _clamp(value ?? DateTime.now(), firstDate, lastDate);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: firstDate,
          lastDate: lastDate,
          locale: const Locale('ar'),
        );
        onChanged(picked);
      },
      borderRadius: BorderRadius.circular(SetupDS.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: value != null ? primary.withValues(alpha: 0.45) : border,
          ),
          borderRadius: BorderRadius.circular(SetupDS.radiusMd),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 18, color: value != null ? primary : mutedFg),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value != null ? formatArabicDate(dateToIso(value!)) : (hint ?? 'اختر تاريخاً'),
                style: theme.textTheme.bodyMedium?.copyWith(color: value != null ? null : mutedFg),
              ),
            ),
            Icon(Icons.expand_more_rounded, color: mutedFg, size: 20),
          ],
        ),
      ),
    );
  }
}

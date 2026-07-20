import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../data/islamic_content.dart';
import '../../design/design_tokens.dart';
import '../shared/date_field.dart';
import '../shared/hadith_card.dart';
import '../shared/misc_widgets.dart';

class StepTarget extends StatelessWidget {
  final int dailyTarget, missedDays;
  final DateTime startDate;
  final String notes;
  final bool useArabic;
  final ValueChanged<int> onTargetChanged;
  final ValueChanged<DateTime> onStartChanged;
  final ValueChanged<String> onNotesChanged;

  const StepTarget({
    super.key,
    required this.dailyTarget,
    required this.missedDays,
    required this.startDate,
    required this.notes,
    required this.useArabic,
    required this.onTargetChanged,
    required this.onStartChanged,
    required this.onNotesChanged,
  });

  static const _presets = [
    (value: 1, label: 'خفيف', hint: 'يوم قضاء يومياً · ٥ صلوات', icon: Icons.spa_rounded),
    (value: 2, label: 'معتدل', hint: 'يومان يومياً · ١٠ صلوات', icon: Icons.directions_walk_rounded),
    (value: 3, label: 'نشط', hint: 'ثلاثة أيام يومياً · ١٥ صلاة', icon: Icons.directions_run_rounded),
    (value: 5, label: 'مكثف', hint: 'خمسة أيام يومياً · ٢٥ صلاة', icon: Icons.bolt_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final muted = AppColors.mutedOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);
    final daysNeeded = dailyTarget > 0 ? (missedDays / dailyTarget).ceil() : 0;

    return Column(
      children: [
        const SizedBox(height: 16),
        const HadithCard(main: IslamicContent.generalMain, sub: IslamicContent.generalSub),
        const SizedBox(height: 20),
        ..._presets.map((p) {
          final active = dailyTarget == p.value;
          return GestureDetector(
            onTap: () => onTargetChanged(p.value),
            child: AnimatedContainer(
              duration: SetupDS.fast,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: active ? primary.withValues(alpha: 0.07) : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(SetupDS.radiusMd),
                border: Border.all(
                    color: active ? primary.withValues(alpha: 0.4) : border, width: active ? 1.5 : 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: active ? primary.withValues(alpha: 0.13) : muted.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(p.icon, size: 18, color: active ? primary : mutedFg),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.label,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(color: active ? primary : null, fontWeight: FontWeight.w600)),
                        Text(p.hint, style: theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: active ? 1 : 0,
                    duration: SetupDS.fast,
                    child: Icon(Icons.check_circle_rounded, color: primary, size: 20),
                  ),
                ],
              ),
            ),
          );
        }),
        if (daysNeeded > 0) ...[
          const SizedBox(height: 4),
          InfoStrip(
            icon: Icons.flag_rounded,
            label: 'بهذا المعدل، ستنهي القضاء خلال ${formatNumber(daysNeeded, useArabic: useArabic)} يوماً',
            primary: primary,
          ),
        ],
        const SizedBox(height: 20),
        const FieldLabel('تاريخ البدء'),
        const SizedBox(height: 8),
        SetupDateField(
          value: startDate,
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 30)),
          onChanged: (d) => onStartChanged(d!),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'ملاحظات (اختياري)',
            hintText: 'أوقات الفراغ المناسبة للقضاء...',
          ),
          maxLines: 3,
          onChanged: onNotesChanged,
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

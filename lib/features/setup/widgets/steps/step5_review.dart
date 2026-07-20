import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../shared/misc_widgets.dart';
import '../shared/tip_tile.dart';

class StepReview extends StatelessWidget {
  final DateTime? birthDate, bulughDate, commitmentDate;
  final bool bulughApprox, commitmentApprox;
  final int missedDays, dailyTarget;
  final DateTime startDate;
  final bool confirmed;
  final bool useArabic;
  final ValueChanged<bool> onConfirmedChanged;

  const StepReview({
    super.key,
    required this.birthDate,
    required this.bulughDate,
    required this.bulughApprox,
    required this.commitmentDate,
    required this.commitmentApprox,
    required this.missedDays,
    required this.dailyTarget,
    required this.startDate,
    required this.confirmed,
    required this.useArabic,
    required this.onConfirmedChanged,
  });

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
        const SizedBox(height: 8),
        Text(
          'راجع البيانات أدناه قبل الاعتماد.',
          style: theme.textTheme.bodySmall?.copyWith(color: mutedFg),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              _ReviewRow(
                  label: 'تاريخ الميلاد',
                  value: birthDate != null ? formatArabicDate(dateToIso(birthDate!)) : '-'),
              _ReviewRow(
                  label: 'تاريخ البلوغ',
                  value: bulughDate != null ? formatArabicDate(dateToIso(bulughDate!)) : '-',
                  isApprox: bulughApprox),
              _ReviewRow(
                  label: 'تاريخ الالتزام',
                  value: commitmentDate != null ? formatArabicDate(dateToIso(commitmentDate!)) : '-',
                  isApprox: commitmentApprox),
              _ReviewRow(label: 'الأيام الفائتة', value: '${formatNumber(missedDays, useArabic: useArabic)} يوماً'),
              _ReviewRow(
                  label: 'إجمالي الصلوات',
                  value: '${formatNumber(missedDays * 5, useArabic: useArabic)} صلاة',
                  highlight: true),
              _ReviewRow(
                  label: 'الهدف اليومي',
                  value:
                      '${formatNumber(dailyTarget, useArabic: useArabic)} يوم · ${formatNumber(dailyTarget * 5, useArabic: useArabic)} صلاة'),
              _ReviewRow(label: 'تاريخ البدء', value: formatArabicDate(dateToIso(startDate))),
              if (daysNeeded > 0)
                _ReviewRow(label: 'مدة الإنجاز التقديرية', value: '${formatNumber(daysNeeded, useArabic: useArabic)} يوماً'),
            ],
          ),
        ),
        if (bulughApprox || commitmentApprox) ...[
          const SizedBox(height: 12),
          const TipTile(
            icon: Icons.info_outline_rounded,
            text: 'البيانات المحددة بعلامة "تقريبي" هي تقديرات مقبولة شرعاً عند عدم المعرفة بالضبط.',
          ),
        ],
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => onConfirmedChanged(!confirmed),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: confirmed ? primary.withValues(alpha: 0.07) : muted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: confirmed ? primary.withValues(alpha: 0.4) : border,
                width: confirmed ? 1.5 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: confirmed ? primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: confirmed ? primary : AppColors.mutedFgOf(context)),
                  ),
                  child: confirmed ? const Icon(Icons.check, color: Colors.white, size: 14) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'راجعت البيانات وأؤكد أنها صحيحة بقدر ما أعلم، وأرغب باعتماد الخطة.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label, value;
  final bool isApprox, highlight;

  const _ReviewRow({required this.label, required this.value, this.isApprox = false, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Text(label, style: theme.textTheme.bodySmall?.copyWith(color: mutedFg)),
              const Spacer(),
              if (isApprox) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text('تقريبي',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: Colors.orange.shade700, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 8),
              ],
              Text(value,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600, color: highlight ? primary : null)),
            ],
          ),
        ),
        const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

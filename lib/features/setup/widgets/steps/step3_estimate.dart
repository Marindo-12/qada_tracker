import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_utils.dart';
import '../../data/islamic_content.dart';
import '../../design/design_tokens.dart';
import '../shared/auto_calc_banner.dart';
import '../shared/hadith_card.dart';
import '../shared/misc_widgets.dart';
import '../shared/number_input.dart';
import '../shared/tip_tile.dart';

class StepEstimate extends StatelessWidget {
  final DateTime? bulughDate, commitmentDate;
  final bool granularMode;
  final int years, months, days, missedDays;
  final bool useArabic;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<int> onYearsChanged, onMonthsChanged, onDaysChanged, onMissedDaysChanged;

  const StepEstimate({
    super.key,
    required this.bulughDate,
    required this.commitmentDate,
    required this.granularMode,
    required this.years,
    required this.months,
    required this.days,
    required this.missedDays,
    required this.useArabic,
    required this.onModeChanged,
    required this.onYearsChanged,
    required this.onMonthsChanged,
    required this.onDaysChanged,
    required this.onMissedDaysChanged,
  });

  int get _total => granularMode ? (years * 365 + months * 30 + days).clamp(0, 999999) : missedDays;

  int? get _autoCalcDays {
    if (bulughDate == null || commitmentDate == null) return null;
    final diff = commitmentDate!.difference(bulughDate!).inDays;
    return diff > 0 ? diff : null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final muted = AppColors.mutedOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final surface = AppColors.surfaceOf(context);
    final autoCalc = _autoCalcDays;

    return Column(
      children: [
        const SizedBox(height: 16),
        const HadithCard(main: IslamicContent.estimateHelp, sub: IslamicContent.estimateSub),
        const SizedBox(height: 8),
        Text(
          'قدّر بصدق الفترة التي فاتتك فيها الصلاة فعلياً.',
          style: theme.textTheme.bodySmall?.copyWith(color: mutedFg, height: 1.6),
          textAlign: TextAlign.center,
        ),
        if (autoCalc != null) ...[
          const SizedBox(height: 16),
          AutoCalcBanner(
            autoCalcDays: autoCalc,
            useArabic: useArabic,
            primary: primary,
            onAccept: () {
              final y = autoCalc ~/ 365;
              final r = autoCalc % 365;
              final m = r ~/ 30;
              final d = r % 30;
              onModeChanged(true);
              onYearsChanged(y);
              onMonthsChanged(m);
              onDaysChanged(d);
            },
          ),
        ],
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: muted.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(SetupDS.radiusMd),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              ModeTab(
                label: 'سنوات / شهور / أيام',
                active: granularMode,
                primary: primary,
                mutedFg: mutedFg,
                surface: surface,
                onTap: () => onModeChanged(true),
              ),
              ModeTab(
                label: 'عدد الأيام مباشرة',
                active: !granularMode,
                primary: primary,
                mutedFg: mutedFg,
                surface: surface,
                onTap: () => onModeChanged(false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (granularMode)
          Row(
            children: [
              Expanded(child: SetupNumberInput(label: 'سنوات', value: years, onChanged: onYearsChanged)),
              const SizedBox(width: 8),
              Expanded(
                  child: SetupNumberInput(label: 'شهور', value: months, max: 11, onChanged: onMonthsChanged)),
              const SizedBox(width: 8),
              Expanded(child: SetupNumberInput(label: 'أيام', value: days, onChanged: onDaysChanged)),
            ],
          )
        else
          SetupNumberInput(
            label: 'الأيام الفائتة',
            hint: 'كل يوم يعادل ٥ صلوات',
            value: missedDays,
            onChanged: onMissedDaysChanged,
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: StatCard(label: 'إجمالي الأيام', value: formatNumber(_total, useArabic: useArabic)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                label: 'إجمالي الصلوات',
                value: formatNumber(_total * 5, useArabic: useArabic),
                accent: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const TipTile(icon: Icons.auto_awesome_rounded, text: IslamicContent.approxOk),
      ],
    );
  }
}

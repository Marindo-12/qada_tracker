import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../design/design_tokens.dart';

class SetupStepHeader extends StatelessWidget {
  final int step, totalSteps;
  final String title;
  final double progress;
  final bool useArabic;
  final Color primary;

  const SetupStepHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.title,
    required this.progress,
    required this.useArabic,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedFg = AppColors.mutedFgOf(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Row(
                children: List.generate(totalSteps, (i) {
                  final done = i < step;
                  final active = i == step;
                  return AnimatedContainer(
                    duration: SetupDS.fast,
                    margin: const EdgeInsets.only(left: 4),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: done || active
                          ? primary
                          : AppColors.mutedOf(context).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
              const Spacer(),
              Text(
                '${formatNumber(step + 1, useArabic: useArabic)} / ${formatNumber(totalSteps, useArabic: useArabic)}',
                style: theme.textTheme.labelSmall?.copyWith(color: mutedFg),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 3,
              backgroundColor: AppColors.progressTrackOf(context),
              valueColor: AlwaysStoppedAnimation<Color>(primary),
            ),
          ),
        ],
      ),
    );
  }
}

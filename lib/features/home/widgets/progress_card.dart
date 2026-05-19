// lib/features/home/widgets/progress_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/providers/providers.dart';

class ProgressCard extends ConsumerWidget {
  const ProgressCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(summaryProvider);
    final useArabic = ref.watch(digitStyleProvider);
    final theme = Theme.of(context);

    return summaryAsync.when(
      loading: () => _buildSkeleton(),
      error: (e, _) => const SizedBox.shrink(),
      data: (summary) {
        final pct = summary.percentComplete;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('التقدم الكلي', style: theme.textTheme.titleLarge),
                    Text(
                      '${formatNumber(pct.round(), useArabic: useArabic)}٪',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(color: AppColors.mutedFg),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 12,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ).animate().scaleX(
                      alignment: Alignment.centerRight,
                      duration: 800.ms,
                      curve: Curves.easeOut,
                    ),
                const SizedBox(height: 8),

                // Completed / remaining
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'أنجزت: ${formatNumber(summary.completedPrayers, useArabic: useArabic)} صلاة',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.mutedFg),
                    ),
                    Text(
                      'متبقي: ${formatNumber(summary.remainingPrayers, useArabic: useArabic)} صلاة',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: AppColors.mutedFg),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Stats grid
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'أيام مكافئة منجزة',
                        value: formatNumber(
                            summary.completedDays.floor(),
                            useArabic: useArabic),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        label: 'موعد الختم المتوقع',
                        value: summary.estimatedFinishDate != null
                            ? formatArabicDate(
                                summary.estimatedFinishDate!,
                                pattern: 'MMM yyyy',
                              )
                            : '-',
                        color: AppColors.accent,
                        smallText: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(height: 20, color: AppColors.muted),
            const SizedBox(height: 12),
            Container(height: 12, decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(8),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool smallText;

  const _StatBox({
    required this.label,
    required this.value,
    required this.color,
    this.smallText = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.mutedFg),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: smallText
                ? theme.textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  )
                : theme.textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
          ),
        ],
      ),
    );
  }
}
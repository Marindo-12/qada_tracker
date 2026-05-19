// lib/features/home/widgets/today_checklist.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/providers/providers.dart';
import '../../../core/database/tables/tables.dart';

class TodayChecklist extends ConsumerWidget {
  const TodayChecklist({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(todayLogsProvider);
    final planAsync = ref.watch(planProvider);
    final useArabic = ref.watch(digitStyleProvider);

    return planAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
      data: (plan) {
        final target = (plan?.dailyTarget ?? 1) * 5;
        return logsAsync.when(
          loading: () => _buildSkeleton(context),
          error: (e, _) => const SizedBox.shrink(),
          data: (logs) {
            final logMap = {for (final l in logs) l.prayer: l};
            final completedCount = logs.fold(0, (sum, l) => sum + l.count);
            return Card(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الصلوات المنجزة اليوم',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.primary,
                                )),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${formatNumber(completedCount, useArabic: useArabic)} / ${formatNumber(target, useArabic: useArabic)}',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Prayer rows
                  ...kPrayerNames.asMap().entries.map((entry) {
                    final i = entry.key;
                    final prayer = entry.value;
                    final log = logMap[prayer];
                    final count = log?.count ?? 0;
                    return _PrayerRow(
                      prayer: prayer,
                      count: count,
                      useArabic: useArabic,
                      isLast: i == kPrayerNames.length - 1,
                      onDecrement: count > 0
                          ? () => _setCount(ref, prayer, count - 1)
                          : null,
                      onIncrement: () => _setCount(ref, prayer, count + 1),
                    ).animate().fadeIn(delay: Duration(milliseconds: i * 80));
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _setCount(WidgetRef ref, String prayer, int count) async {
    final dao = ref.read(prayerLogDaoProvider);
    final today = todayIso();
    await dao.setCount(today, prayer, count);
    ref.invalidate(todayLogsProvider);
    ref.invalidate(summaryProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(recentActivityProvider);
  }

  Widget _buildSkeleton(BuildContext context) {
    return Card(
      child: Column(
        children: List.generate(
          5,
          (i) => Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrayerRow extends StatelessWidget {
  final String prayer;
  final int count;
  final bool useArabic;
  final bool isLast;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _PrayerRow({
    required this.prayer,
    required this.count,
    required this.useArabic,
    required this.isLast,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = count > 0;

    return Column(
      children: [
        Container(
          color: isCompleted ? AppColors.primary.withOpacity(0.04) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Status circle
              AnimatedContainer(
                duration: 300.ms,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : Colors.transparent,
                  border: isCompleted
                      ? null
                      : Border.all(color: AppColors.mutedFg.withOpacity(0.3), width: 2),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : Text('٠',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedFg.withOpacity(0.4))),
                ),
              ),
              const SizedBox(width: 12),
              // Prayer name + icon
              Expanded(
                child: Row(
                  children: [
                    Text(kPrayerIcons[prayer] ?? '', style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      kPrayerNamesAr[prayer] ?? prayer,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: isCompleted ? AppColors.primary : AppColors.foreground,
                        fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              // Counter
              Row(
                children: [
                  _CounterButton(
                    icon: Icons.remove,
                    onPressed: onDecrement,
                    color: AppColors.mutedFg,
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      formatNumber(count, useArabic: useArabic),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _CounterButton(
                    icon: Icons.add,
                    onPressed: onIncrement,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;

  const _CounterButton({
    required this.icon,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: onPressed == null
                  ? AppColors.mutedFg.withOpacity(0.2)
                  : color.withOpacity(0.4),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: onPressed == null ? AppColors.mutedFg.withOpacity(0.3) : color,
          ),
        ),
      ),
    );
  }
}
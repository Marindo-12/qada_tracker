import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/providers/providers.dart';

class PrayerProgressBreakdown extends ConsumerWidget {
  const PrayerProgressBreakdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(prayerProgressProvider);
    final useArabic = ref.watch(digitStyleProvider);
    final theme = Theme.of(context);

    return progressAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4, bottom: 12),
              child: Text(
                'تقدم كل صلاة على حدة',
                textAlign: TextAlign.right,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.foreground.withValues(alpha: 0.86),
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            Card(
              child: Column(
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    _PrayerProgressRow(
                      item: items[i],
                      useArabic: useArabic,
                    ),
                    if (i < items.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PrayerProgressRow extends StatelessWidget {
  final PrayerProgressData item;
  final bool useArabic;

  const _PrayerProgressRow({
    required this.item,
    required this.useArabic,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prayerName = kPrayerNamesAr[item.prayer] ?? item.prayer;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '${formatNumber(item.total, useArabic: useArabic)} / ${formatNumber(item.completed, useArabic: useArabic)}',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.mutedFg,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                prayerName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.foreground.withValues(alpha: 0.88),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: item.ratio,
              minHeight: 9,
              backgroundColor: const Color(0xFFCDE3DB),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Text(
                'متبقي: ${formatNumber(item.remaining, useArabic: useArabic)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.mutedFg,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
              const Spacer(),
              Text(
                'أنجزت: ${formatNumber(item.completed, useArabic: useArabic)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

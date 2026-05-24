// lib/features/home/widgets/recent_activity.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/providers/providers.dart';

class RecentActivityWidget extends ConsumerWidget {
  const RecentActivityWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentActivityProvider);
    final useArabic = ref.watch(digitStyleProvider);
    final theme = Theme.of(context);
    final primary = AppColors.primaryOf(context);
    final mutedFg = AppColors.mutedFgOf(context);
    final border = AppColors.borderOf(context);

    return recentAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (logs) {
        if (logs.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('آخر الصلوات المقضية', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            ...logs.map((log) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: border.withValues(alpha: 0.5), width: 0.5),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: primary, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        '${kPrayerIcons[log.prayer] ?? ''} ${kPrayerNamesAr[log.prayer] ?? log.prayer}',
                        style: theme.textTheme.titleSmall,
                      ),
                      if (log.count > 1) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '×${formatNumber(log.count, useArabic: useArabic)}',
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: primary),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        formatArabicDateShort(log.date),
                        style:
                            theme.textTheme.bodySmall?.copyWith(color: mutedFg),
                      ),
                    ],
                  ),
                )),
          ],
        );
      },
    );
  }
}

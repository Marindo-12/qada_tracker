// lib/features/home/widgets/streak_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/providers/providers.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);
    final useArabic = ref.watch(digitStyleProvider);
    final theme = Theme.of(context);

    return streakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (streak) {
        if (streak.current == 0) return const SizedBox.shrink();
        return Card(
          color: AppColors.accent.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.accent.withOpacity(0.3)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_fire_department,
                      color: AppColors.accent, size: 28),
                ).animate(onPlay: (c) => c.repeat()).shimmer(
                      duration: 2.seconds,
                      color: AppColors.accent.withOpacity(0.3),
                    ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('سلسلة المواظبة',
                          style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold)),
                      Text('أيام متتالية من الالتزام',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedFg)),
                    ],
                  ),
                ),
                Text(
                  formatNumber(streak.current, useArabic: useArabic),
                  style: theme.textTheme.displaySmall?.copyWith(
                      color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ).animate().fadeIn().slideX(begin: 0.2);
      },
    );
  }
}
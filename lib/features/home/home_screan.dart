// lib/features/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import '../../core/navigation/app_router.dart';
import 'widgets/today_checklist.dart';
import 'widgets/progress_card.dart';
import 'widgets/streak_card.dart';
import 'widgets/recent_activity.dart';
import 'widgets/previous_day_logger.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(planProvider);

    return planAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('خطأ: $e'))),
      data: (plan) {
        if (plan == null) return const _WelcomeScreen();
        return const _Dashboard();
      },
    );
  }
}

// ─── Welcome Screen ───────────────────────────────────────────────────────────
class _WelcomeScreen extends ConsumerWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 32),
              Text(
                'تطبيق قضاء الصلوات',
                style: theme.textTheme.displaySmall,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 16),
              Text(
                'رفيقك الهادئ في رحلة التوبة وقضاء ما فاتك من الصلوات.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedFg,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ref.read(currentTabProvider.notifier).state = 3;
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SetupScreenWrapper()),
                    );
                  },
                  child: const Text('ابدأ رحلة القضاء', style: TextStyle(fontSize: 18)),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
              const SizedBox(height: 32),
              Text(
                '"وَأَقِمِ الصَّلَاةَ طَرَفَيِ النَّهَارِ"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedFg,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }
}

// Import for setup navigation
import '../../features/setup/setup_screen.dart';

class SetupScreenWrapper extends StatelessWidget {
  const SetupScreenWrapper({super.key});
  @override
  Widget build(BuildContext context) => const SetupScreen();
}

// ─── Dashboard ────────────────────────────────────────────────────────────────
class _Dashboard extends ConsumerWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final useArabic = ref.watch(digitStyleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 8),
            Text('قضاء', style: theme.textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
          ],
        ),
        actions: [
          // Digit style toggle
          TextButton(
            onPressed: () => ref.read(digitStyleProvider.notifier).toggle(),
            child: Text(
              useArabic ? '123' : '١٢٣',
              style: theme.textTheme.titleMedium?.copyWith(color: AppColors.mutedFg),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayLogsProvider);
          ref.invalidate(summaryProvider);
          ref.invalidate(streakProvider);
          ref.invalidate(recentActivityProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ورد اليوم', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 4),
                  Text(
                    formatArabicDate(todayIso()),
                    style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.mutedFg),
                  ),
                ],
              ),
            ),

            // Today checklist
            const TodayChecklist(),
            const SizedBox(height: 16),

            // Previous day logger
            const PreviousDayLogger(),
            const SizedBox(height: 16),

            // Progress
            const ProgressCard(),
            const SizedBox(height: 16),

            // Streak
            const StreakCard(),
            const SizedBox(height: 16),

            // Recent activity
            const RecentActivityWidget(),
            const SizedBox(height: 32),

            // Quranic quote
            Center(
              child: Text(
                '"قليل دائم خير من كثير منقطع"',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.mutedFg,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
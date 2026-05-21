// lib/features/calendar/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_utils.dart';
import '../../shared/providers/providers.dart';
import 'widgets/day_edit_dialog.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedMonth = ref.watch(selectedMonthProvider);
    final useArabic = ref.watch(digitStyleProvider);

    final now = DateTime.now();
    final currentMonth = DateTime.parse('$selectedMonth-01');

    return Scaffold(
      appBar: AppBar(
        title: Text('التقويم', style: theme.textTheme.titleLarge),
      ),
      body: Column(
        children: [
          // Month navigator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    final prev = DateTime(currentMonth.year, currentMonth.month - 1);
                    ref.read(selectedMonthProvider.notifier).state = toYearMonth(prev);
                  },
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                ),
                Text(
                  formatMonthYear(selectedMonth),
                  style: theme.textTheme.headlineSmall,
                ).animate(key: ValueKey(selectedMonth)).fadeIn(duration: 300.ms),
                IconButton(
                  onPressed: currentMonth.month < now.month || currentMonth.year < now.year
                      ? () {
                          final next = DateTime(currentMonth.year, currentMonth.month + 1);
                          ref.read(selectedMonthProvider.notifier).state = toYearMonth(next);
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border, width: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Day of week headers
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: ['أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت']
                  .map((d) => Expanded(
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: AppColors.mutedFg),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const Divider(height: 1),

          // Calendar grid
          Expanded(
            child: ref.watch(calendarDataProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
              data: (calendarData) {
                final dates = allDatesInMonth(selectedMonth);
                final firstDay = DateTime.parse('$selectedMonth-01');
                // 0=Sun in dart, we want Sun=0
                final startPadding = firstDay.weekday % 7;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    childAspectRatio: 1,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemCount: startPadding + dates.length,
                  itemBuilder: (context, index) {
                    if (index < startPadding) return const SizedBox.shrink();
                    final date = dates[index - startPadding];
                    final data = calendarData[date];
                    final isFuture = date.compareTo(todayIso()) > 0;
                    final isToday = date == todayIso();
                    final day = int.parse(date.split('-').last);

                    return _CalendarCell(
                      day: day,
                      data: data,
                      isToday: isToday,
                      isFuture: isFuture,
                      useArabic: useArabic,
                      onTap: isFuture
                          ? null
                          : () => showDialog(
                                context: context,
                                builder: (_) => DayEditDialog(date: date),
                              ),
                    );
                  },
                ).animate().fadeIn(duration: 400.ms);
              },
            ),
          ),

          // Legend
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('مكتمل', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mutedFg)),
                const SizedBox(width: 8),
                ...[
                  AppColors.heatmap4,
                  AppColors.heatmap3,
                  AppColors.heatmap2,
                  AppColors.heatmap1,
                  AppColors.heatmap0,
                ].map((c) => Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                const SizedBox(width: 4),
                Text('فارغ', style: theme.textTheme.labelSmall?.copyWith(color: AppColors.mutedFg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final int day;
  final CalendarDayData? data;
  final bool isToday;
  final bool isFuture;
  final bool useArabic;
  final VoidCallback? onTap;

  const _CalendarCell({
    required this.day,
    required this.data,
    required this.isToday,
    required this.isFuture,
    required this.useArabic,
    required this.onTap,
  });

  Color _cellColor() {
    if (data == null || data!.completed == 0) return AppColors.heatmap0;
    final ratio = data!.ratio;
    if (ratio >= 1.0) return AppColors.heatmap4;
    if (ratio >= 0.75) return AppColors.heatmap3;
    if (ratio >= 0.5) return AppColors.heatmap2;
    if (ratio >= 0.25) return AppColors.heatmap1;
    return AppColors.heatmap0;
  }

  Color _textColor() {
    final bg = _cellColor();
    if (bg == AppColors.heatmap4 || bg == AppColors.heatmap3) return Colors.white;
    if (bg == AppColors.heatmap2) return Colors.white;
    return AppColors.foreground;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cellColor = _cellColor();
    final textColor = _textColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: isFuture ? AppColors.muted.withValues(alpha: 0.3) : cellColor,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Opacity(
          opacity: isFuture ? 0.3 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatNumber(day, useArabic: useArabic),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isFuture ? AppColors.mutedFg : textColor,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (data != null && data!.completed > 0)
                Text(
                  formatNumber(data!.completed, useArabic: useArabic),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.8),
                    fontSize: 9,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
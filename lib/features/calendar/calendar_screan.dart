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
    final selectedMonth      = ref.watch(selectedMonthProvider);
    final selectedHijriMonth = ref.watch(selectedHijriMonthProvider);
    final calendarType       = ref.watch(calendarTypeProvider);
    final useArabic          = ref.watch(digitStyleProvider);
    final mutedFg            = AppColors.mutedFgOf(context);
    final border             = AppColors.borderOf(context);
    final heatmapColors = Theme.of(context).brightness == Brightness.dark
        ? const [
            AppColors.darkPrimary,
            Color(0xFF8F7626),
            AppColors.darkGreen,
            Color(0xFF1C4F3D),
            AppColors.darkMuted,
          ]
        : const [
            AppColors.heatmap4,
            AppColors.heatmap3,
            AppColors.heatmap2,
            AppColors.heatmap1,
            AppColors.heatmap0,
          ];

    final now = DateTime.now();

    // ── Navigation helpers ────────────────────────────────────────────────────
    // FIX: navigation now updates the correct month provider depending on
    // which calendar mode is active.  Previously only selectedMonthProvider
    // was updated, so the Hijri month stayed frozen at "today" while the
    // user navigated forward/backward.

    void navigatePrev() {
      if (calendarType == CalendarType.hijri) {
        final parts = selectedHijriMonth.split('-');
        int y = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        m--;
        if (m < 1) { m = 12; y--; }
        ref.read(selectedHijriMonthProvider.notifier).state =
            '$y-${m.toString().padLeft(2, '0')}';
      } else {
        final current = DateTime.parse('$selectedMonth-01');
        final prev = DateTime(current.year, current.month - 1);
        ref.read(selectedMonthProvider.notifier).state = toYearMonth(prev);
      }
    }

    bool canNavigateNext() {
      if (calendarType == CalendarType.hijri) {
        // Disallow future: compare first day of next Hijri month with today
        final parts = selectedHijriMonth.split('-');
        int y = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        m++;
        if (m > 12) { m = 1; y++; }
        final nextFirstDay = HijriDate(y, m, 1).toGregorian();
        return nextFirstDay.isBefore(DateTime(now.year, now.month, now.day + 1));
      } else {
        final current = DateTime.parse('$selectedMonth-01');
        return current.month < now.month || current.year < now.year;
      }
    }

    void navigateNext() {
      if (!canNavigateNext()) return;
      if (calendarType == CalendarType.hijri) {
        final parts = selectedHijriMonth.split('-');
        int y = int.parse(parts[0]);
        int m = int.parse(parts[1]);
        m++;
        if (m > 12) { m = 1; y++; }
        ref.read(selectedHijriMonthProvider.notifier).state =
            '$y-${m.toString().padLeft(2, '0')}';
      } else {
        final current = DateTime.parse('$selectedMonth-01');
        final next = DateTime(current.year, current.month + 1);
        ref.read(selectedMonthProvider.notifier).state = toYearMonth(next);
      }
    }

    // ── Display month label ───────────────────────────────────────────────────
    final displayMonthLabel = calendarType == CalendarType.hijri
        ? formatHijriMonthYear(selectedHijriMonth)
        : formatMonthYear(selectedMonth);

    // Key used to animate the month title when it changes
    final displayMonthKey = calendarType == CalendarType.hijri
        ? selectedHijriMonth
        : selectedMonth;

    return Scaffold(
      appBar: AppBar(
        title: Text('التقويم', style: theme.textTheme.titleLarge),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                ref.read(calendarTypeProvider.notifier).toggle();
              },
              child: Text(
                calendarType == CalendarType.hijri ? 'ميلادي' : 'هجري',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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
                  onPressed: navigatePrev,
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: border, width: 0.5),
                    ),
                  ),
                ),
                Text(displayMonthLabel, style: theme.textTheme.headlineSmall)
                    .animate(key: ValueKey(displayMonthKey))
                    .fadeIn(duration: 300.ms),
                IconButton(
                  onPressed: canNavigateNext() ? navigateNext : null,
                  icon: const Icon(Icons.arrow_forward_ios, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: border, width: 0.5),
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
                          style: theme.textTheme.labelSmall?.copyWith(color: mutedFg),
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
                    late List<String> dates;
                    late int startPadding;

                    if (calendarType == CalendarType.hijri) {
                      // FIX: use the Hijri-specific month provider for dates
                      dates = allHijriDatesInMonth(selectedHijriMonth);
                      final parts = selectedHijriMonth.split('-');
                      final firstHijriDay = HijriDate(
                        int.parse(parts[0]),
                        int.parse(parts[1]),
                        1,
                      );
                      final firstGregorian = firstHijriDay.toGregorian();
                      startPadding = firstGregorian.weekday % 7;
                    } else {
                      dates = allDatesInMonth(selectedMonth);
                      final firstDay = DateTime.parse('$selectedMonth-01');
                      startPadding = firstDay.weekday % 7;
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        childAspectRatio: 1,
                        crossAxisSpacing: 6,
                        mainAxisSpacing: 6,
                      ),
                      itemCount: startPadding + dates.length,
                      itemBuilder: (context, index) {
                        if (index < startPadding) {
                          return const SizedBox.shrink();
                        }
                        final date = dates[index - startPadding];

                        // Resolve Gregorian date for data lookup & tap dialog
                        late String miladiDate;
                        late int dayToDisplay;

                        if (calendarType == CalendarType.hijri) {
                          final parts = date.split('-');
                          final hijri = HijriDate(
                            int.parse(parts[0]),
                            int.parse(parts[1]),
                            int.parse(parts[2]),
                          );
                          // FIX: toGregorian() now works correctly
                          final gregorian = hijri.toGregorian();
                          miladiDate   = dateToIso(gregorian);
                          dayToDisplay = int.parse(parts[2]);
                        } else {
                          miladiDate   = date;
                          dayToDisplay = int.parse(date.split('-').last);
                        }

                        final data     = calendarData[miladiDate];
                        final isFuture = miladiDate.compareTo(todayIso()) > 0;
                        final isToday  = miladiDate == todayIso();

                        return _CalendarCell(
                          day: dayToDisplay,
                          data: data,
                          isToday: isToday,
                          isFuture: isFuture,
                          useArabic: useArabic,
                          onTap: isFuture
                              ? null
                              : () => showDialog(
                                    context: context,
                                    builder: (_) => DayEditDialog(date: miladiDate),
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
                Text('مكتمل',
                    style: theme.textTheme.labelSmall?.copyWith(color: mutedFg)),
                const SizedBox(width: 8),
                ...heatmapColors.map((c) => Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )),
                const SizedBox(width: 4),
                Text('فارغ',
                    style: theme.textTheme.labelSmall?.copyWith(color: mutedFg)),
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

  Color _cellColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      if (data == null || data!.completed == 0) return AppColors.darkMuted;
      final ratio = data!.ratio;
      if (ratio >= 1.0) return AppColors.darkPrimary;
      if (ratio >= 0.75) return const Color(0xFF8F7626);
      if (ratio >= 0.5) return AppColors.darkGreen;
      if (ratio >= 0.25) return const Color(0xFF1C4F3D);
      return AppColors.darkMuted;
    }
    if (data == null || data!.completed == 0) return AppColors.heatmap0;
    final ratio = data!.ratio;
    if (ratio >= 1.0) return AppColors.heatmap4;
    if (ratio >= 0.75) return AppColors.heatmap3;
    if (ratio >= 0.5) return AppColors.heatmap2;
    if (ratio >= 0.25) return AppColors.heatmap1;
    return AppColors.heatmap0;
  }

  Color _textColor(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return AppColors.foregroundOf(context);
    }
    final bg = _cellColor(context);
    if (bg == AppColors.heatmap4 || bg == AppColors.heatmap3) return Colors.white;
    if (bg == AppColors.heatmap2) return Colors.white;
    return AppColors.foregroundOf(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final cellColor = _cellColor(context);
    final textColor = _textColor(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: isFuture
              ? AppColors.mutedOf(context).withValues(alpha: 0.3)
              : cellColor,
          borderRadius: BorderRadius.circular(10),
          border: isToday
              ? Border.all(color: AppColors.primaryOf(context), width: 2)
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
                  color: isFuture ? AppColors.mutedFgOf(context) : textColor,
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
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
    final theme              = Theme.of(context);
    final selectedMonth      = ref.watch(selectedMonthProvider);
    final selectedHijriMonth = ref.watch(selectedHijriMonthProvider);
    final calendarType       = ref.watch(calendarTypeProvider);
    final useArabic          = ref.watch(digitStyleProvider);
    final mutedFg            = AppColors.mutedFgOf(context);
    final border             = AppColors.borderOf(context);
    final isDark             = AppColors.isDark(context);

    final now = DateTime.now();

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

    final displayMonthLabel = calendarType == CalendarType.hijri
        ? formatHijriMonthYear(selectedHijriMonth)
        : formatMonthYear(selectedMonth);
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
              onPressed: () => ref.read(calendarTypeProvider.notifier).toggle(),
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
          // ── Month navigator ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: navigatePrev,
                  icon: const Icon(Icons.arrow_back_ios, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
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
                    backgroundColor: theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: border, width: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Day of week headers ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: ['أحد', 'إثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت']
                  .map((d) => Expanded(
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall
                              ?.copyWith(color: mutedFg),
                        ),
                      ))
                  .toList(),
            ),
          ),

          const Divider(height: 1),

          // ── Calendar grid ─────────────────────────────────────────────
          Expanded(
            child: ref.watch(calendarDataProvider).when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (e, _) => Center(child: Text('خطأ: $e')),
              data: (calendarData) {
                late List<String> dates;
                late int startPadding;

                if (calendarType == CalendarType.hijri) {
                  dates = allHijriDatesInMonth(selectedHijriMonth);
                  final parts = selectedHijriMonth.split('-');
                  final firstHijriDay = HijriDate(
                    int.parse(parts[0]),
                    int.parse(parts[1]),
                    1,
                  );
                  startPadding = firstHijriDay.toGregorian().weekday % 7;
                } else {
                  dates = allDatesInMonth(selectedMonth);
                  startPadding =
                      DateTime.parse('$selectedMonth-01').weekday % 7;
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
                    if (index < startPadding) return const SizedBox.shrink();

                    final date = dates[index - startPadding];
                    late String miladiDate;
                    late int    dayToDisplay;

                    if (calendarType == CalendarType.hijri) {
                      final parts = date.split('-');
                      final hijri = HijriDate(
                        int.parse(parts[0]),
                        int.parse(parts[1]),
                        int.parse(parts[2]),
                      );
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
                      day:       dayToDisplay,
                      date:      miladiDate,
                      data:      data,
                      isToday:   isToday,
                      isFuture:  isFuture,
                      useArabic: useArabic,
                      isDark:    isDark,
                    );
                  },
                ).animate().fadeIn(duration: 400.ms);
              },
            ),
          ),

          // ── Legend ───────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('مكتمل',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: mutedFg)),
                const SizedBox(width: 8),
                ...(isDark
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
                      ])
                    .map((c) => Container(
                          width:  16,
                          height: 16,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: c,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        )),
                const SizedBox(width: 4),
                Text('فارغ',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: mutedFg)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Calendar Cell ────────────────────────────────────────────────────────────
// On tap → shows a GitHub-style tooltip popup with prayer count details
// Uses OverlayEntry so it appears above everything, auto-dismissed on outside tap
class _CalendarCell extends ConsumerStatefulWidget {
  final int              day;
  final String           date;
  final CalendarDayData? data;
  final bool             isToday;
  final bool             isFuture;
  final bool             useArabic;
  final bool             isDark;

  const _CalendarCell({
    required this.day,
    required this.date,
    required this.data,
    required this.isToday,
    required this.isFuture,
    required this.useArabic,
    required this.isDark,
  });

  @override
  ConsumerState<_CalendarCell> createState() => _CalendarCellState();
}

class _CalendarCellState extends ConsumerState<_CalendarCell>
    with SingleTickerProviderStateMixin {
  OverlayEntry? _overlay;
  late AnimationController _ctl;
  late Animation<double>   _fadeScale;

  @override
  void initState() {
    super.initState();
    _ctl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeScale = CurvedAnimation(parent: _ctl, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _removeOverlay();
    _ctl.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
  }

  void _showTooltip(BuildContext context) {
    _removeOverlay();

    final box    = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    final size   = box.size;
    final screen = MediaQuery.of(context).size;

    // Tooltip width
    const tw = 140.0;
    const th = 90.0;

    // Position: prefer above, center horizontally
    double left = offset.dx + size.width / 2 - tw / 2;
    double top  = offset.dy - th - 8;

    // Clamp to screen
    if (left < 8) left = 8;
    if (left + tw > screen.width - 8) left = screen.width - tw - 8;
    if (top < 8) top = offset.dy + size.height + 8; // flip below

    final primary = AppColors.primaryOf(context);
    final isDark  = widget.isDark;
    final bg      = isDark ? const Color(0xFF1E2D42) : Colors.white;
    final fg      = isDark ? const Color(0xFFF5F0E8) : const Color(0xFF1A2332);
    final muted   = isDark ? const Color(0xFFC7BFAE) : const Color(0xFF5A6A7A);

    final data      = widget.data;
    final completed = data?.completed ?? 0;
    final total     = data?.total     ?? 0;
    final ratio     = total > 0 ? completed / total : 0.0;

    _overlay = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Transparent barrier to dismiss on outside tap
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),

          // Tooltip card
          Positioned(
            left: left,
            top:  top,
            child: Material(
              color:       Colors.transparent,
              child: ScaleTransition(
                scale: _fadeScale,
                alignment: Alignment.bottomCenter,
                child: FadeTransition(
                  opacity: _fadeScale,
                  child: Container(
                    width: tw,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color:        bg,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color:      Colors.black.withValues(
                              alpha: isDark ? 0.45 : 0.14),
                          blurRadius: 20,
                          offset:     const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date
                        Text(
                          _formatDisplayDate(widget.date),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize:   10,
                            color:      muted,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 6),

                        // Prayer count
                        Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Icon(Icons.check_circle_rounded,
                                size: 14, color: primary),
                            const SizedBox(width: 4),
                            Text(
                              '${formatNumber(completed, useArabic: widget.useArabic)} / ${formatNumber(total, useArabic: widget.useArabic)} صلاة',
                              style: TextStyle(
                                fontFamily:  'Cairo',
                                fontSize:    12,
                                fontWeight:  FontWeight.w700,
                                color:       fg,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value:           ratio.clamp(0.0, 1.0),
                            minHeight:       5,
                            backgroundColor: isDark
                                ? const Color(0xFF2A3545)
                                : const Color(0xFFE8DFC8),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(primary),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // Tap to edit hint
                        if (!widget.isFuture)
                          GestureDetector(
                            onTap: () {
                              _removeOverlay();
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    DayEditDialog(date: widget.date),
                              );
                            },
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Icon(Icons.edit_outlined,
                                    size: 11, color: primary),
                                const SizedBox(width: 3),
                                Text(
                                  'تعديل',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize:   10,
                                    color:      primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlay!);
    _ctl
      ..reset()
      ..forward();
  }

  String _formatDisplayDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return iso;
    }
  }

  // ── Heatmap color ──────────────────────────────────────────────────────────
  Color _cellColor() {
    if (widget.isDark) {
      if (widget.data == null || widget.data!.completed == 0)
        return AppColors.darkMuted;
      final r = widget.data!.ratio;
      if (r >= 1.0) return AppColors.darkPrimary;
      if (r >= 0.75) return const Color(0xFF8F7626);
      if (r >= 0.5) return AppColors.darkGreen;
      if (r >= 0.25) return const Color(0xFF1C4F3D);
      return AppColors.darkMuted;
    }
    if (widget.data == null || widget.data!.completed == 0)
      return AppColors.heatmap0;
    final r = widget.data!.ratio;
    if (r >= 1.0) return AppColors.heatmap4;
    if (r >= 0.75) return AppColors.heatmap3;
    if (r >= 0.5) return AppColors.heatmap2;
    if (r >= 0.25) return AppColors.heatmap1;
    return AppColors.heatmap0;
  }

  Color _textColor(Color bg) {
    if (widget.isDark) return AppColors.darkBackground;
    if (bg == AppColors.heatmap4 || bg == AppColors.heatmap3 ||
        bg == AppColors.heatmap2)
      return Colors.white;
    return const Color(0xFF1A2332);
  }

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final cellColor = _cellColor();
    final textColor = _textColor(cellColor);

    return GestureDetector(
      onTap: widget.isFuture ? null : () => _showTooltip(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isFuture
              ? AppColors.mutedOf(context).withValues(alpha: 0.3)
              : cellColor,
          borderRadius: BorderRadius.circular(10),
          border: widget.isToday
              ? Border.all(
                  color: AppColors.primaryOf(context), width: 2)
              : null,
        ),
        child: Opacity(
          opacity: widget.isFuture ? 0.3 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                formatNumber(widget.day, useArabic: widget.useArabic),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: widget.isFuture
                      ? AppColors.mutedFgOf(context)
                      : textColor,
                  fontWeight:
                      widget.isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (widget.data != null && widget.data!.completed > 0)
                Text(
                  formatNumber(widget.data!.completed,
                      useArabic: widget.useArabic),
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
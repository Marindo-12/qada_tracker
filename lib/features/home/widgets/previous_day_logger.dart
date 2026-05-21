// lib/features/home/widgets/previous_day_logger.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/providers/providers.dart';

class PreviousDayLogger extends ConsumerStatefulWidget {
  const PreviousDayLogger({super.key});

  @override
  ConsumerState<PreviousDayLogger> createState() => _PreviousDayLoggerState();
}

class _PreviousDayLoggerState extends ConsumerState<PreviousDayLogger> {
  bool _expanded = false;
  String _selectedDate = addDays(todayIso(), -1);
  Map<String, int> _counts = {};
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useArabic = ref.watch(digitStyleProvider);
    final today = todayIso();
    final yesterday = addDays(today, -1);

    if (!_expanded) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.muted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history, color: AppColors.mutedFg),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('أضف من يوم سابق',
                        style: theme.textTheme.titleSmall),
                    Text('نسيت تسجيل صلوات الأمس؟',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.mutedFg)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  setState(() => _expanded = true);
                  await _loadLogs();
                },
                child: const Text('فتح'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.muted.withValues(alpha: 0.4),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('سجل يوم سابق', style: theme.textTheme.titleSmall),
                TextButton(
                  onPressed: () => setState(() => _expanded = false),
                  child: const Text('إغلاق'),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Date picker
                InkWell(
                  onTap: () => _pickDate(context, yesterday),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 18, color: AppColors.mutedFg),
                        const SizedBox(width: 12),
                        Text(
                          formatArabicDate(_selectedDate),
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        const Icon(Icons.arrow_drop_down,
                            color: AppColors.mutedFg),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Prayer list
                if (_loading)
                  const Center(
                      child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ))
                else
                  ...kPrayerNames.asMap().entries.map((entry) {
                    final prayer = entry.value;
                    final count = _counts[prayer] ?? 0;
                    final isCompleted = count > 0;
                    return Column(
                      children: [
                        if (entry.key > 0) const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Icon(
                                isCompleted
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: isCompleted
                                    ? AppColors.primary
                                    : AppColors.mutedFg.withValues(alpha: 0.3),
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${kPrayerIcons[prayer] ?? ''} ${kPrayerNamesAr[prayer] ?? prayer}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: isCompleted
                                      ? AppColors.primary
                                      : AppColors.foreground,
                                ),
                              ),
                              const Spacer(),
                              _SmallCounter(
                                count: count,
                                useArabic: useArabic,
                                onDecrement: count > 0
                                    ? () => _updateCount(prayer, count - 1)
                                    : null,
                                onIncrement: () =>
                                    _updateCount(prayer, count + 1),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, String maxDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_selectedDate),
      firstDate: DateTime(2000),
      lastDate: DateTime.parse(maxDate),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _selectedDate = dateToIso(picked));
      await _loadLogs();
    }
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    final dao = ref.read(prayerLogDaoProvider);
    final logs = await dao.getLogsForRange(_selectedDate, _selectedDate);
    final map = {for (final l in logs) l.prayer: l.count};
    setState(() {
      _counts = map;
      _loading = false;
    });
  }

  Future<void> _updateCount(String prayer, int count) async {
    final dao = ref.read(prayerLogDaoProvider);
    await dao.setCount(_selectedDate, prayer, count);
    setState(() => _counts[prayer] = count < 0 ? 0 : count);
    ref.invalidate(summaryProvider);
    ref.invalidate(prayerProgressProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(recentActivityProvider);
  }
}

class _SmallCounter extends StatelessWidget {
  final int count;
  final bool useArabic;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  const _SmallCounter({
    required this.count,
    required this.useArabic,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _btn(Icons.remove, onDecrement, AppColors.mutedFg),
        SizedBox(
          width: 36,
          child: Text(
            formatNumber(count, useArabic: useArabic),
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        _btn(Icons.add, onIncrement, AppColors.primary),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback? onPressed, Color color) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: onPressed == null
                ? color.withValues(alpha: 0.2)
                : color.withValues(alpha: 0.5),
          ),
        ),
        child: Icon(icon,
            size: 14,
            color:
                onPressed == null ? color.withValues(alpha: 0.3) : color),
      ),
    );
  }
}

// lib/features/calendar/widgets/day_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_utils.dart';
import '../../../shared/providers/providers.dart';

class DayEditDialog extends ConsumerStatefulWidget {
  final String date;
  const DayEditDialog({super.key, required this.date});

  @override
  ConsumerState<DayEditDialog> createState() => _DayEditDialogState();
}

class _DayEditDialogState extends ConsumerState<DayEditDialog> {
  Map<String, int> _counts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final dao = ref.read(prayerLogDaoProvider);
    final logs = await dao.getLogsForRange(widget.date, widget.date);
    setState(() {
      _counts = {for (final l in logs) l.prayer: l.count};
      _loading = false;
    });
  }

  Future<void> _setCount(String prayer, int count) async {
    final dao = ref.read(prayerLogDaoProvider);
    await dao.setCount(widget.date, prayer, count);
    setState(() => _counts[prayer] = count < 0 ? 0 : count);
    ref.invalidate(summaryProvider);
    ref.invalidate(streakProvider);
    ref.invalidate(recentActivityProvider);
    ref.invalidate(calendarDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useArabic = ref.watch(digitStyleProvider);
    final total = _counts.values.fold(0, (sum, c) => sum + c);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Text(
              formatArabicDate(widget.date),
              style: theme.textTheme.headlineSmall
                  ?.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'عدّل عدد كل صلاة قضاء صليتها في هذا اليوم',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.mutedFg),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Total badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'مجموع اليوم: ${formatNumber(total, useArabic: useArabic)}',
                    style: theme.textTheme.labelLarge
                        ?.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Prayer list
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              ...kPrayerNames.asMap().entries.map((entry) {
                final i = entry.key;
                final prayer = entry.value;
                final count = _counts[prayer] ?? 0;
                final isCompleted = count > 0;

                return Column(
                  children: [
                    if (i > 0) const Divider(height: 1),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: isCompleted
                          ? AppColors.primary.withOpacity(0.04)
                          : Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 4),
                      child: Row(
                        children: [
                          Text(
                            '${kPrayerIcons[prayer] ?? ''} ${kPrayerNamesAr[prayer] ?? prayer}',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: isCompleted
                                  ? AppColors.primary
                                  : AppColors.foreground,
                              fontWeight: isCompleted
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          // Decrement
                          _RoundButton(
                            icon: Icons.remove,
                            color: AppColors.mutedFg,
                            enabled: count > 0,
                            onTap: count > 0
                                ? () => _setCount(prayer, count - 1)
                                : null,
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
                          // Increment
                          _RoundButton(
                            icon: Icons.add,
                            color: AppColors.primary,
                            enabled: true,
                            onTap: () => _setCount(prayer, count + 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),

            const SizedBox(height: 16),
            Text(
              'إذا صليت أكثر من صلاة من نفس النوع، اضغط + عدة مرات',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.mutedFg, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback? onTap;

  const _RoundButton({
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled
                ? color.withOpacity(0.5)
                : color.withOpacity(0.15),
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: enabled ? color : color.withOpacity(0.25),
        ),
      ),
    );
  }
}
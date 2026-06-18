// lib/shared/providers/providers.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/app_database.dart';
import '../../core/database/daos/plan_dao.dart';
import '../../core/database/daos/prayer_log_dao.dart';
import '../../core/utils/app_utils.dart';

// ─── Database ─────────────────────────────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final planDaoProvider = Provider<PlanDao>((ref) {
  return ref.watch(databaseProvider).planDao;
});

final prayerLogDaoProvider = Provider<PrayerLogDao>((ref) {
  return ref.watch(databaseProvider).prayerLogDao;
});

// ─── Preferences ──────────────────────────────────────────────────────────────
final sharedPrefsProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

const userNamePrefsKey = 'qada.userName';

final userNameProvider = FutureProvider<String?>((ref) async {
  final prefs = await ref.watch(sharedPrefsProvider.future);
  final value = prefs.getString(userNamePrefsKey)?.trim();
  return value == null || value.isEmpty ? null : value;
});

final digitStyleProvider = StateNotifierProvider<DigitStyleNotifier, bool>((ref) {
  return DigitStyleNotifier(ref);
});

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier(ref);
});

class DigitStyleNotifier extends StateNotifier<bool> {
  final Ref _ref;
  static const _key = 'qada.useArabicDigits';

  DigitStyleNotifier(this._ref) : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await _ref.read(sharedPrefsProvider.future);
    state = prefs.getBool(_key) ?? true;
  }

  Future<void> toggle() async {
    final prefs = await _ref.read(sharedPrefsProvider.future);
    state = !state;
    await prefs.setBool(_key, state);
  }

  Future<void> set(bool useArabic) async {
    final prefs = await _ref.read(sharedPrefsProvider.future);
    state = useArabic;
    await prefs.setBool(_key, useArabic);
  }
}

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;
  static const _key = 'qada.themeMode';

  ThemeModeNotifier(this._ref) : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await _ref.read(sharedPrefsProvider.future);
    state = _fromStorage(prefs.getString(_key));
  }

  Future<void> set(ThemeMode mode) async {
    final prefs = await _ref.read(sharedPrefsProvider.future);
    state = mode;
    await prefs.setString(_key, mode.name);
  }

  ThemeMode _fromStorage(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}

// ─── Plan ─────────────────────────────────────────────────────────────────────
final planProvider = StreamProvider<PlanTableData?>((ref) {
  return ref.watch(planDaoProvider).watchPlan();
});

// ─── Today's logs ─────────────────────────────────────────────────────────────
final todayLogsProvider = StreamProvider<List<PrayerLogTableData>>((ref) {
  final dao = ref.watch(prayerLogDaoProvider);
  final today = todayIso();
  return dao.watchLogsForDate(today);
});

// ─── Summary stats ────────────────────────────────────────────────────────────
final summaryProvider = FutureProvider<SummaryStats>((ref) async {
  final plan = await ref.watch(planProvider.future);
  final dao = ref.watch(prayerLogDaoProvider);

  if (plan == null) return SummaryStats.empty();

  final total = await dao.getTotalCompleted();
  final breakdown = await dao.getBreakdown();

  final missedPrayers = plan.missedDays * 5;
  final remaining = (missedPrayers - total).clamp(0, missedPrayers);
  final pct = missedPrayers > 0 ? (total / missedPrayers * 100).clamp(0.0, 100.0) : 0.0;
  final dailyRate = plan.dailyTarget * 5;

  String? estimatedFinish;
  if (remaining > 0 && dailyRate > 0) {
    final daysNeeded = (remaining / dailyRate).ceil();
    estimatedFinish = addDays(todayIso(), daysNeeded);
  } else if (remaining == 0) {
    estimatedFinish = todayIso();
  }

  final startDate = plan.startDate;
  final daysSinceStart = diffDays(startDate, todayIso()).clamp(0, 99999);

  return SummaryStats(
    missedDays: plan.missedDays,
    missedPrayers: missedPrayers,
    completedPrayers: total,
    completedDays: total / 5,
    remainingPrayers: remaining,
    remainingDays: (remaining / 5).ceil(),
    percentComplete: pct,
    dailyTarget: plan.dailyTarget,
    estimatedFinishDate: estimatedFinish,
    daysSinceStart: daysSinceStart,
    breakdown: breakdown,
  );
});

final prayerProgressProvider = FutureProvider<List<PrayerProgressData>>((ref) async {
  final plan = await ref.watch(planProvider.future);
  final dao = ref.watch(prayerLogDaoProvider);

  if (plan == null) return const [];

  final totalPerPrayer = plan.missedDays;
  final breakdown = await dao.getBreakdown();

  return [
    for (final prayer in kPrayerNames)
      PrayerProgressData(
        prayer: prayer,
        completed: breakdown[prayer] ?? 0,
        total: totalPerPrayer,
      )
  ];
});

// ─── Streak ───────────────────────────────────────────────────────────────────
final streakProvider = FutureProvider<StreakResult>((ref) async {
  final plan = await ref.watch(planProvider.future);
  if (plan == null) return const StreakResult(current: 0, longest: 0);

  final dao = ref.watch(prayerLogDaoProvider);
  final fullDayTarget = plan.dailyTarget * 5;

  final monthlyData = <String, int>{};
  final rows = await dao.getLogsForRange('2000-01-01', '2099-12-31');
  for (final row in rows) {
    monthlyData[row.date] = (monthlyData[row.date] ?? 0) + row.count;
  }

  final fullDays = monthlyData.entries
      .where((e) => e.value >= fullDayTarget)
      .map((e) => e.key)
      .toList()
    ..sort();

  return computeStreak(fullDays, plan.dailyTarget);
});

// ─── Recent activity ──────────────────────────────────────────────────────────
final recentActivityProvider = FutureProvider<List<PrayerLogTableData>>((ref) async {
  final dao = ref.watch(prayerLogDaoProvider);
  return dao.getRecentLogs(limit: 8);
});

// ─── Calendar month ───────────────────────────────────────────────────────────
final selectedMonthProvider = StateProvider<String>((ref) => toYearMonth(DateTime.now()));

// FIX: selectedHijriMonthProvider is now a plain StateProvider that the
// calendar screen controls directly (like selectedMonthProvider).
// Previously it was a computed Provider that derived from selectedMonthProvider,
// which meant navigating in Hijri mode only updated the miladi month.
//
// ALSO FIXED: initialise from fromGregorian(today) — not fromGregorian(1st of
// the miladi month). When today is e.g. 24 May 2026 (Dhul Hijja 1447) but the
// 1st of May is still in Dhul Qada 1447, the old init was 1 month behind.
final selectedHijriMonthProvider = StateProvider<String>((ref) {
  return HijriDate.fromGregorian(DateTime.now()).toYearMonth();
});

// ─── Calendar data ────────────────────────────────────────────────────────────
// FIX: A Hijri month can span parts of TWO Gregorian months (e.g. Ramadan
// 1446 covers parts of March 2025 and April 2025).  The original provider
// loaded only the single miladi month stored in selectedMonthProvider, so
// any day whose Gregorian date fell in the adjacent month returned null.
//
// The fix: when in Hijri mode, determine which Gregorian months the Hijri
// month overlaps and load totals for all of them, then merge into one map.
final calendarDataProvider = FutureProvider<Map<String, CalendarDayData>>((ref) async {
  final miladiMonth = ref.watch(selectedMonthProvider);
  final hijriMonth  = ref.watch(selectedHijriMonthProvider);
  final calType     = ref.watch(calendarTypeProvider);
  final plan        = await ref.watch(planProvider.future);
  final dao         = ref.watch(prayerLogDaoProvider);

  final target = (plan?.dailyTarget ?? 1) * 5;

  if (calType == CalendarType.miladi) {
    // Original behaviour — fast, no change.
    final totals = await dao.getMonthlyTotals(miladiMonth);
    final dates  = allDatesInMonth(miladiMonth);
    return {
      for (final d in dates)
        d: CalendarDayData(date: d, completed: totals[d] ?? 0, target: target)
    };
  }

  // ── Hijri mode ──────────────────────────────────────────────────────────────
  // Find which Gregorian months this Hijri month touches.
  final hijriDates     = allHijriDatesInMonth(hijriMonth);
  final hijriParts     = hijriMonth.split('-');
  final hy             = int.parse(hijriParts[0]);
  final hm             = int.parse(hijriParts[1]);

  // First and last Gregorian dates in this Hijri month
  final firstGregorian = HijriDate(hy, hm, 1).toGregorian();
  final lastGregorian  = HijriDate(hy, hm, hijriDates.length).toGregorian();

  final firstMiladi = toYearMonth(firstGregorian);
  final lastMiladi  = toYearMonth(lastGregorian);

  // Load totals for all involved Gregorian months (1 or 2)
  final Map<String, int> allTotals = {};
  for (final month in {firstMiladi, lastMiladi}) {
    final t = await dao.getMonthlyTotals(month);
    allTotals.addAll(t);
  }

  // Build CalendarDayData keyed by Gregorian ISO date (for data lookup)
  // but the calendar grid uses Hijri dates for display.
  final result = <String, CalendarDayData>{};
  for (final hijriDate in hijriDates) {
    final parts    = hijriDate.split('-');
    final gregorian = HijriDate(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    ).toGregorian();
    final miladiDate = dateToIso(gregorian);
    result[miladiDate] = CalendarDayData(
      date: miladiDate,
      completed: allTotals[miladiDate] ?? 0,
      target: target,
    );
  }
  return result;
});

// ─── Data Models ──────────────────────────────────────────────────────────────
class SummaryStats {
  final int missedDays;
  final int missedPrayers;
  final int completedPrayers;
  final double completedDays;
  final int remainingPrayers;
  final int remainingDays;
  final double percentComplete;
  final int dailyTarget;
  final String? estimatedFinishDate;
  final int daysSinceStart;
  final Map<String, int> breakdown;

  const SummaryStats({
    required this.missedDays,
    required this.missedPrayers,
    required this.completedPrayers,
    required this.completedDays,
    required this.remainingPrayers,
    required this.remainingDays,
    required this.percentComplete,
    required this.dailyTarget,
    this.estimatedFinishDate,
    required this.daysSinceStart,
    required this.breakdown,
  });

  factory SummaryStats.empty() => const SummaryStats(
        missedDays: 0,
        missedPrayers: 0,
        completedPrayers: 0,
        completedDays: 0,
        remainingPrayers: 0,
        remainingDays: 0,
        percentComplete: 0,
        dailyTarget: 1,
        daysSinceStart: 0,
        breakdown: {},
      );
}

class CalendarDayData {
  final String date;
  final int completed;
  final int target;
  const CalendarDayData({
    required this.date,
    required this.completed,
    required this.target,
  });
  double get ratio => target > 0 ? (completed / target).clamp(0.0, 1.0) : 0;
}

class PrayerProgressData {
  final String prayer;
  final int completed;
  final int total;

  const PrayerProgressData({
    required this.prayer,
    required this.completed,
    required this.total,
  });

  int get remaining => (total - completed).clamp(0, total);
  double get ratio => total > 0 ? (completed / total).clamp(0.0, 1.0) : 0;
}

// ─── Calendar Type ────────────────────────────────────────────────────────────
final calendarTypeProvider = StateNotifierProvider<CalendarTypeNotifier, CalendarType>((ref) {
  return CalendarTypeNotifier(ref);
});

class CalendarTypeNotifier extends StateNotifier<CalendarType> {
  final Ref _ref;
  static const _key = 'qada.calendarType';

  CalendarTypeNotifier(this._ref) : super(CalendarType.miladi) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await _ref.read(sharedPrefsProvider.future);
    final stored = prefs.getString(_key) ?? 'miladi';
    state = stored == 'hijri' ? CalendarType.hijri : CalendarType.miladi;
  }

  Future<void> toggle() async {
    final prefs = await _ref.read(sharedPrefsProvider.future);
    final newType = state == CalendarType.miladi ? CalendarType.hijri : CalendarType.miladi;
    state = newType;
    await prefs.setString(_key, newType == CalendarType.hijri ? 'hijri' : 'miladi');
  }
}

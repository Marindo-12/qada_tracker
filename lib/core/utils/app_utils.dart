// lib/core/utils/app_utils.dart
import 'package:intl/intl.dart';

// ─── Prayer Names ─────────────────────────────────────────────────────────────
const List<String> kPrayerNames = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];

const Map<String, String> kPrayerNamesAr = {
  'fajr': 'الفجر',
  'dhuhr': 'الظهر',
  'asr': 'العصر',
  'maghrib': 'المغرب',
  'isha': 'العشاء',
};

const Map<String, String> kPrayerIcons = {
  'fajr': '🌙',
  'dhuhr': '☀️',
  'asr': '🌤️',
  'maghrib': '🌅',
  'isha': '🌃',
};

// ─── Arabic Digits ────────────────────────────────────────────────────────────
const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String toArabicDigits(dynamic value) {
  final s = value.toString();
  return s.split('').map((c) {
    final d = int.tryParse(c);
    if (d != null) return _arabicDigits[d];
    return c;
  }).join();
}

String formatNumber(int n, {bool useArabic = true}) {
  if (useArabic) return toArabicDigits(n);
  return n.toString();
}

String formatDouble(double n, {bool useArabic = true}) {
  final s = n.toStringAsFixed(1);
  if (useArabic) return toArabicDigits(s);
  return s;
}

// ─── Date Helpers ─────────────────────────────────────────────────────────────
String todayIso() => DateFormat('yyyy-MM-dd').format(DateTime.now());

String dateToIso(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

DateTime isoToDate(String iso) => DateTime.parse(iso);

String formatArabicDate(String isoDate, {String pattern = 'EEEE، dd MMMM yyyy'}) {
  try {
    final date = DateTime.parse(isoDate);
    final formatter = DateFormat(pattern, 'ar');
    return formatter.format(date);
  } catch (_) {
    return isoDate;
  }
}

String formatArabicDateShort(String isoDate) {
  try {
    final date = DateTime.parse(isoDate);
    return DateFormat('dd MMM', 'ar').format(date);
  } catch (_) {
    return isoDate;
  }
}

String formatMonthYear(String isoDate) {
  try {
    final date = DateTime.parse('$isoDate-01');
    return DateFormat('MMMM yyyy', 'ar').format(date);
  } catch (_) {
    return isoDate;
  }
}

/// Number of days between two ISO dates
int diffDays(String from, String to) {
  final a = DateTime.parse(from);
  final b = DateTime.parse(to);
  return b.difference(a).inDays;
}

String addDays(String isoDate, int days) {
  final date = DateTime.parse(isoDate);
  return dateToIso(date.add(Duration(days: days)));
}

/// Get YYYY-MM from a date
String toYearMonth(DateTime date) => DateFormat('yyyy-MM').format(date);

/// Days in a given month (YYYY-MM)
int daysInMonth(String yearMonth) {
  final parts = yearMonth.split('-');
  final y = int.parse(parts[0]);
  final m = int.parse(parts[1]);
  return DateTime(y, m + 1, 0).day;
}

/// All ISO dates in a month
List<String> allDatesInMonth(String yearMonth) {
  final count = daysInMonth(yearMonth);
  final parts = yearMonth.split('-');
  return List.generate(count, (i) {
    final day = (i + 1).toString().padLeft(2, '0');
    return '${parts[0]}-${parts[1]}-$day';
  });
}

// ─── Stats helpers ────────────────────────────────────────────────────────────
StreakResult computeStreak(List<String> datesWithLogs, int dailyTarget) {
  // datesWithLogs: sorted list of dates where count >= dailyTarget * 5
  if (datesWithLogs.isEmpty) return const StreakResult(current: 0, longest: 0);

  final today = todayIso();
  int longest = 0;
  int run = 0;
  String? prev;

  for (final d in datesWithLogs) {
    if (prev != null && diffDays(prev, d) == 1) {
      run++;
    } else {
      run = 1;
    }
    if (run > longest) longest = run;
    prev = d;
  }

  // Current streak
  int current = 0;
  final last = datesWithLogs.last;
  final gap = diffDays(last, today);
  if (gap <= 1) {
    final set = datesWithLogs.toSet();
    String cursor = last;
    while (set.contains(cursor)) {
      current++;
      cursor = addDays(cursor, -1);
    }
  }

  return StreakResult(current: current, longest: longest, lastFullDay: last);
}

class StreakResult {
  final int current;
  final int longest;
  final String? lastFullDay;
  const StreakResult({required this.current, required this.longest, this.lastFullDay});
}
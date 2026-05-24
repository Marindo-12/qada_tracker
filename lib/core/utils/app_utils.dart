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

// ─── Hijri Calendar Helpers ───────────────────────────────────────────────────
/// Enum for calendar type
enum CalendarType { miladi, hijri }

/// Hijri date conversion using Julian Day Number algorithm.
/// This is the standard, well-tested approach used in most Islamic calendar
/// software (Dershowitz & Reingold, "Calendrical Calculations").
class HijriDate {
  final int year;
  final int month;
  final int day;

  HijriDate(this.year, this.month, this.day);

  // ── Gregorian → Hijri ──────────────────────────────────────────────────────
  static HijriDate fromGregorian(DateTime gregorian) {
    // Convert Gregorian date to Julian Day Number
    final jd = _gregorianToJD(gregorian.year, gregorian.month, gregorian.day);
    return _jdToHijri(jd);
  }

  // ── Hijri → Gregorian ──────────────────────────────────────────────────────
  // FIX: original implementation was broken. Using Julian Day Number
  // algorithm instead — accurate and well-tested.
  DateTime toGregorian() {
    final jd = _hijriToJD(year, month, day);
    return _jdToGregorian(jd);
  }

  // ── Julian Day Number helpers ──────────────────────────────────────────────

  /// Gregorian date → Julian Day Number (integer)
  static int _gregorianToJD(int y, int m, int d) {
    return (1461 * (y + 4800 + (m - 14) ~/ 12)) ~/ 4 +
        (367 * (m - 2 - 12 * ((m - 14) ~/ 12))) ~/ 12 -
        (3 * ((y + 4900 + (m - 14) ~/ 12) ~/ 100)) ~/ 4 +
        d -
        32075;
  }

  /// Julian Day Number → Gregorian date
  static DateTime _jdToGregorian(int jd) {
    int l = jd + 68569;
    final n = (4 * l) ~/ 146097;
    l = l - (146097 * n + 3) ~/ 4;
    final i = (4000 * (l + 1)) ~/ 1461001;
    l = l - (1461 * i) ~/ 4 + 31;
    final j = (80 * l) ~/ 2447;
    final d = l - (2447 * j) ~/ 80;
    l = j ~/ 11;
    final m = j + 2 - 12 * l;
    final y = 100 * (n - 49) + i + l;
    return DateTime(y, m, d);
  }

  /// Hijri date → Julian Day Number
  /// Uses the tabular (arithmetic) Islamic calendar (civil epoch).
  /// Formula: Meeus "Astronomical Algorithms" ch.9 — civil Islamic epoch.
  /// Previous formula `hd + (29*(hm-1)) + (hm~/2) + 354*(hy-1) + ...`
  /// was wrong and produced a ~386-day offset in toGregorian().
  static int _hijriToJD(int hy, int hm, int hd) {
    return (11 * hy + 3) ~/ 30 +
        354 * hy +
        30 * hm -
        (hm - 1) ~/ 2 +
        hd +
        1948440 -
        385;
  }

  /// Julian Day Number → Hijri date
  static HijriDate _jdToHijri(int jd) {
    final z = jd - 1948440 + 385;
    final a = (30 * z - 1) ~/ 10631;  // complete 30-year cycles
    final b = z - (10631 * a) ~/ 30;  // day within current cycle
    final c = ((b - 1) ~/ 354).clamp(0, 29); // approximate year within cycle
    // Refine: find exact Hijri year
    int hy = 30 * a + c + 1;
    // Adjust if needed
    while (_hijriToJD(hy + 1, 1, 1) <= jd) hy++;
    while (_hijriToJD(hy, 1, 1) > jd) hy--;

    // Find month
    int hm = 1;
    while (hm < 12 && _hijriToJD(hy, hm + 1, 1) <= jd) hm++;

    // Find day
    final hd = jd - _hijriToJD(hy, hm, 1) + 1;

    return HijriDate(hy, hm, hd);
  }

  @override
  String toString() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  String toYearMonth() => '$year-${month.toString().padLeft(2, '0')}';
}

// ─── Hijri month length ───────────────────────────────────────────────────────

/// Returns the number of days in a given Hijri month (year, month).
/// FIX: replaces the naive alternating formula with a JDN-based calculation
/// that correctly accounts for leap years.
int hijriDaysInMonth(int year, int month) {
  // Days = JD of first day of next month − JD of first day of this month
  final jdThis = HijriDate._hijriToJD(year, month, 1);
  final int jdNext;
  if (month == 12) {
    jdNext = HijriDate._hijriToJD(year + 1, 1, 1);
  } else {
    jdNext = HijriDate._hijriToJD(year, month + 1, 1);
  }
  return jdNext - jdThis;
}

// ─── Format helpers ───────────────────────────────────────────────────────────

/// Format Hijri date in Arabic
String formatHijriDate(HijriDate hijri, {String pattern = 'EEEE، dd MMMM yyyy'}) {
  final hijriMonths = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  final days = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];

  final gregorian = hijri.toGregorian();
  final dayName = days[gregorian.weekday % 7];
  final monthName = hijriMonths[hijri.month - 1];
  final dayStr = hijri.day.toString().padLeft(2, '0');
  final yearStr = hijri.year.toString();

  return '$dayName، $dayStr $monthName $yearStr ه‍';
}

/// Format Hijri month/year in Arabic
String formatHijriMonthYear(String hijriYearMonth) {
  final parts = hijriYearMonth.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);

  final hijriMonths = [
    'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني',
    'جمادى الأولى', 'جمادى الآخرة', 'رجب', 'شعبان',
    'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة',
  ];

  return '${hijriMonths[month - 1]} $year ه‍';
}

/// Get all Hijri dates in a month.
/// FIX: uses hijriDaysInMonth() instead of the wrong alternating formula.
List<String> allHijriDatesInMonth(String hijriYearMonth) {
  final parts = hijriYearMonth.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);

  // FIX: was using a simplified/incorrect formula; now uses JDN-based count
  final count = hijriDaysInMonth(year, month);

  return List.generate(count, (i) {
    final day = (i + 1).toString().padLeft(2, '0');
    return '$year-${month.toString().padLeft(2, '0')}-$day';
  });
}

/// Convert Miladi date (YYYY-MM) to Hijri date (YYYY-MM)
String miladiToHijri(String miladiYearMonth) {
  final parts = miladiYearMonth.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);

  final firstDay = DateTime(year, month, 1);
  final hijri = HijriDate.fromGregorian(firstDay);

  return hijri.toYearMonth();
}

/// Convert Hijri date (YYYY-MM) to Miladi date (YYYY-MM)
String hijriToMiladi(String hijriYearMonth) {
  final parts = hijriYearMonth.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);

  final hijri = HijriDate(year, month, 1);
  final gregorian = hijri.toGregorian();

  return DateFormat('yyyy-MM').format(gregorian);
}
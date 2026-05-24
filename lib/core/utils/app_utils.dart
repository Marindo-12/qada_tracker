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

// ─── Hijri Calendar Helpers ───────────────────────────────────────────────────
/// Enum for calendar type
enum CalendarType { miladi, hijri }

/// Simple Hijri date conversion
/// Based on Kuwaiti algorithm
class HijriDate {
  final int year;
  final int month;
  final int day;

  HijriDate(this.year, this.month, this.day);

  static HijriDate fromGregorian(DateTime gregorian) {
    final N = gregorian.day +
        [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334]
            [gregorian.month - 1] +
        (gregorian.year - 1) * 365 +
        ((gregorian.year - 1) ~/ 4) -
        ((gregorian.year - 1) ~/ 100) +
        ((gregorian.year - 1) ~/ 400) -
        719469;

    final Q = N ~/ 10631;
    final R = N % 10631;

    var a = (R ~/ 325) + 1;
    if (R % 325 < 325) a = R ~/ 325;
    if (a > 11) a = 11;

    var W = R - 325 * a + 1;
    var D = (W % 30) + 1;
    if (W % 30 == 0) D = 30;

    var M = ((W - 1) ~/ 30) + 1;
    if (M > 12) M = 12;

    var Y = Q * 30 + a + 1;

    return HijriDate(Y, M, D);
  }

  DateTime toGregorian() {
    final N = (year - 1) * 354 +
        ((year - 1) ~/ 30) * 11 +
        ((month - 1) * 325 + 5) ~/ 11 +
        day +
        719469;

    int J = 0;
    int K = 0;
    for (int i = 1; i <= 400; i++) {
      K = (i % 4 == 0 && i % 100 != 0) || i % 400 == 0 ? 366 : 365;
      if (N <= J + K) break;
      J += K;
    }

    final dayOfYear = N - J;
    final isLeap = (K == 366);
    final months = [31, isLeap ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    int monthResult = 1;
    int dayResult = dayOfYear;
    for (int i = 0; i < 12; i++) {
      if (dayResult <= months[i]) break;
      dayResult -= months[i];
      monthResult++;
    }

    return DateTime((N ~/ 365.2425).toInt(), monthResult, dayResult);
  }

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  String toYearMonth() => '$year-${month.toString().padLeft(2, '0')}';
}

/// Format Hijri date in Arabic
String formatHijriDate(HijriDate hijri, {String pattern = 'EEEE، dd MMMM yyyy'}) {
  final hijriMonths = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة'
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
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة'
  ];

  return '${hijriMonths[month - 1]} $year ه‍';
}

/// Get all Hijri dates in a month
List<String> allHijriDatesInMonth(String hijriYearMonth) {
  final parts = hijriYearMonth.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);

  final daysInMonth = month == 12 ? 30 : (month % 2 == 1 ? 30 : 29);

  return List.generate(daysInMonth, (i) {
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
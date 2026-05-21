// lib/core/database/daos/prayer_log_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'prayer_log_dao.g.dart';

@DriftAccessor(tables: [PrayerLogTable])
class PrayerLogDao extends DatabaseAccessor<AppDatabase> with _$PrayerLogDaoMixin {
  PrayerLogDao(super.db);

  // ─── CRUD ────────────────────────────────────────────────────────────────────

  /// Get all logs for a date range
  Future<List<PrayerLogTableData>> getLogsForRange(String from, String to) {
    return (select(prayerLogTable)
          ..where((t) => t.date.isBetweenValues(from, to))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  /// Watch logs for a specific date
  Stream<List<PrayerLogTableData>> watchLogsForDate(String date) {
    return (select(prayerLogTable)..where((t) => t.date.equals(date))).watch();
  }

  /// Set count for a prayer on a date (0 = delete)
  Future<void> setCount(String date, String prayer, int count) async {
    if (count <= 0) {
      await (delete(prayerLogTable)
            ..where((t) => t.date.equals(date) & t.prayer.equals(prayer)))
          .go();
    } else {
      final updated = await (update(prayerLogTable)
            ..where((t) => t.date.equals(date) & t.prayer.equals(prayer)))
          .write(
        PrayerLogTableCompanion(
          count: Value(count),
          completedAt: Value(DateTime.now()),
        ),
      );

      if (updated == 0) {
        await into(prayerLogTable).insert(
          PrayerLogTableCompanion.insert(
            date: date,
            prayer: prayer,
            count: Value(count),
            completedAt: Value(DateTime.now()),
          ),
        );
      }
    }
  }

  /// Get count for a specific prayer on a date
  Future<int> getCount(String date, String prayer) async {
    final row = await (select(prayerLogTable)
          ..where((t) => t.date.equals(date) & t.prayer.equals(prayer)))
        .getSingleOrNull();
    return row?.count ?? 0;
  }

  Future<void> incrementCount(String date, String prayer) async {
    await transaction(() async {
      final current = await getCount(date, prayer);
      await setCount(date, prayer, current + 1);
    });
  }

  Future<void> decrementCount(String date, String prayer) async {
    await transaction(() async {
      final current = await getCount(date, prayer);
      await setCount(date, prayer, current - 1);
    });
  }

  // ─── Stats ───────────────────────────────────────────────────────────────────

  /// Total completed prayers
  Future<int> getTotalCompleted() async {
    final result = await customSelect(
      'SELECT COALESCE(SUM(count), 0) as total FROM prayer_log',
      readsFrom: {prayerLogTable},
    ).getSingle();
    return result.data['total'] as int? ?? 0;
  }

  /// Completed prayers per prayer name (breakdown)
  Future<Map<String, int>> getBreakdown() async {
    final rows = await customSelect(
      'SELECT prayer, COALESCE(SUM(count), 0) as total FROM prayer_log GROUP BY prayer',
      readsFrom: {prayerLogTable},
    ).get();
    return {for (final r in rows) r.data['prayer'] as String: r.data['total'] as int? ?? 0};
  }

  /// Get per-day totals for a month (for heatmap)
  Future<Map<String, int>> getMonthlyTotals(String yearMonth) async {
    final from = '$yearMonth-01';
    // last day auto from query
    final rows = await customSelect(
      'SELECT date, COALESCE(SUM(count), 0) as total FROM prayer_log '
      "WHERE date >= ? AND date <= date(?, '+1 month', '-1 day') "
      'GROUP BY date',
      variables: [Variable.withString(from), Variable.withString(from)],
      readsFrom: {prayerLogTable},
    ).get();
    return {for (final r in rows) r.data['date'] as String: r.data['total'] as int? ?? 0};
  }

  /// Get recent logs ordered by completedAt
  Future<List<PrayerLogTableData>> getRecentLogs({int limit = 10}) {
    return (select(prayerLogTable)
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
          ..limit(limit))
        .get();
  }

  /// Get all dates that have logs (for streak computation)
  Future<List<String>> getAllDatesWithLogs() async {
    final rows = await customSelect(
      'SELECT DISTINCT date FROM prayer_log ORDER BY date ASC',
      readsFrom: {prayerLogTable},
    ).get();
    return rows.map((r) => r.data['date'] as String).toList();
  }

  /// Delete everything
  Future<void> deleteAll() => delete(prayerLogTable).go();
}

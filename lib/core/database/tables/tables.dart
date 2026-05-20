// lib/core/database/tables/tables.dart
import 'package:drift/drift.dart';

// ─── Plan Table ───────────────────────────────────────────────────────────────
class PlanTable extends Table {
  @override
  String get tableName => 'plan';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get birthDate => text()();
  TextColumn get bulughDate => text()();
  TextColumn get commitmentDate => text()();
  IntColumn get missedDays => integer()();
  IntColumn get dailyTarget => integer().withDefault(const Constant(1))();
  TextColumn get startDate => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// ─── Prayer Log Table ─────────────────────────────────────────────────────────
class PrayerLogTable extends Table {
  @override
  String get tableName => 'prayer_log';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get date => text()();
  TextColumn get prayer => text()(); // fajr|dhuhr|asr|maghrib|isha
  IntColumn get count => integer().withDefault(const Constant(1))();
  DateTimeColumn get completedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {date, prayer}
      ];

  List<Index> get indices => [
        Index('prayer_log_date_idx', 'CREATE INDEX prayer_log_date_idx ON prayer_log (date)'),
      ];
}

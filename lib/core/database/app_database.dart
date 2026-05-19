// lib/core/database/app_database.dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/tables.dart';
import 'daos/plan_dao.dart';
import 'daos/prayer_log_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [PlanTable, PrayerLogTable],
  daos: [PlanDao, PrayerLogDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          // Future migrations here
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'qada_tracker_db');
  }
}
// lib/core/database/daos/plan_dao.dart
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/tables.dart';

part 'plan_dao.g.dart';

@DriftAccessor(tables: [PlanTable])
class PlanDao extends DatabaseAccessor<AppDatabase> with _$PlanDaoMixin {
  PlanDao(super.db);

  /// Get the current plan (singleton)
  Future<PlanTableData?> getPlan() async {
    return (select(planTable)..orderBy([(t) => OrderingTerm.desc(t.id)])..limit(1))
        .getSingleOrNull();
  }

  /// Watch the current plan for reactive UI
  Stream<PlanTableData?> watchPlan() {
    return (select(planTable)..orderBy([(t) => OrderingTerm.desc(t.id)])..limit(1))
        .watchSingleOrNull();
  }

  /// Create or update the plan
  Future<PlanTableData> upsertPlan(PlanTableCompanion companion) async {
    final existing = await getPlan();
    if (existing != null) {
      await (update(planTable)..where((t) => t.id.equals(existing.id)))
          .write(companion.copyWith(updatedAt: Value(DateTime.now())));
      return (await getPlan())!;
    } else {
      final id = await into(planTable).insert(companion);
      return await (select(planTable)..where((t) => t.id.equals(id))).getSingle();
    }
  }

  /// Delete the plan and all logs
  Future<void> resetPlan() async {
    await delete(planTable).go();
  }
}
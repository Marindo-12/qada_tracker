// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_dao.dart';

// ignore_for_file: type=lint
mixin _$PlanDaoMixin on DatabaseAccessor<AppDatabase> {
  $PlanTableTable get planTable => attachedDatabase.planTable;
  PlanDaoManager get managers => PlanDaoManager(this);
}

class PlanDaoManager {
  final _$PlanDaoMixin _db;
  PlanDaoManager(this._db);
  $$PlanTableTableTableManager get planTable =>
      $$PlanTableTableTableManager(_db.attachedDatabase, _db.planTable);
}

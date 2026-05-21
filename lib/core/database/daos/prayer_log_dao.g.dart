// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_log_dao.dart';

// ignore_for_file: type=lint
mixin _$PrayerLogDaoMixin on DatabaseAccessor<AppDatabase> {
  $PrayerLogTableTable get prayerLogTable => attachedDatabase.prayerLogTable;
  PrayerLogDaoManager get managers => PrayerLogDaoManager(this);
}

class PrayerLogDaoManager {
  final _$PrayerLogDaoMixin _db;
  PrayerLogDaoManager(this._db);
  $$PrayerLogTableTableTableManager get prayerLogTable =>
      $$PrayerLogTableTableTableManager(
          _db.attachedDatabase, _db.prayerLogTable);
}

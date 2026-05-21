// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PlanTableTable extends PlanTable
    with TableInfo<$PlanTableTable, PlanTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<String> birthDate = GeneratedColumn<String>(
      'birth_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bulughDateMeta =
      const VerificationMeta('bulughDate');
  @override
  late final GeneratedColumn<String> bulughDate = GeneratedColumn<String>(
      'bulugh_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commitmentDateMeta =
      const VerificationMeta('commitmentDate');
  @override
  late final GeneratedColumn<String> commitmentDate = GeneratedColumn<String>(
      'commitment_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _missedDaysMeta =
      const VerificationMeta('missedDays');
  @override
  late final GeneratedColumn<int> missedDays = GeneratedColumn<int>(
      'missed_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dailyTargetMeta =
      const VerificationMeta('dailyTarget');
  @override
  late final GeneratedColumn<int> dailyTarget = GeneratedColumn<int>(
      'daily_target', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        birthDate,
        bulughDate,
        commitmentDate,
        missedDays,
        dailyTarget,
        startDate,
        notes,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan';
  @override
  VerificationContext validateIntegrity(Insertable<PlanTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    } else if (isInserting) {
      context.missing(_birthDateMeta);
    }
    if (data.containsKey('bulugh_date')) {
      context.handle(
          _bulughDateMeta,
          bulughDate.isAcceptableOrUnknown(
              data['bulugh_date']!, _bulughDateMeta));
    } else if (isInserting) {
      context.missing(_bulughDateMeta);
    }
    if (data.containsKey('commitment_date')) {
      context.handle(
          _commitmentDateMeta,
          commitmentDate.isAcceptableOrUnknown(
              data['commitment_date']!, _commitmentDateMeta));
    } else if (isInserting) {
      context.missing(_commitmentDateMeta);
    }
    if (data.containsKey('missed_days')) {
      context.handle(
          _missedDaysMeta,
          missedDays.isAcceptableOrUnknown(
              data['missed_days']!, _missedDaysMeta));
    } else if (isInserting) {
      context.missing(_missedDaysMeta);
    }
    if (data.containsKey('daily_target')) {
      context.handle(
          _dailyTargetMeta,
          dailyTarget.isAcceptableOrUnknown(
              data['daily_target']!, _dailyTargetMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}birth_date'])!,
      bulughDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bulugh_date'])!,
      commitmentDate: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}commitment_date'])!,
      missedDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}missed_days'])!,
      dailyTarget: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}daily_target'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $PlanTableTable createAlias(String alias) {
    return $PlanTableTable(attachedDatabase, alias);
  }
}

class PlanTableData extends DataClass implements Insertable<PlanTableData> {
  final int id;
  final String birthDate;
  final String bulughDate;
  final String commitmentDate;
  final int missedDays;
  final int dailyTarget;
  final String startDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const PlanTableData(
      {required this.id,
      required this.birthDate,
      required this.bulughDate,
      required this.commitmentDate,
      required this.missedDays,
      required this.dailyTarget,
      required this.startDate,
      this.notes,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['birth_date'] = Variable<String>(birthDate);
    map['bulugh_date'] = Variable<String>(bulughDate);
    map['commitment_date'] = Variable<String>(commitmentDate);
    map['missed_days'] = Variable<int>(missedDays);
    map['daily_target'] = Variable<int>(dailyTarget);
    map['start_date'] = Variable<String>(startDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlanTableCompanion toCompanion(bool nullToAbsent) {
    return PlanTableCompanion(
      id: Value(id),
      birthDate: Value(birthDate),
      bulughDate: Value(bulughDate),
      commitmentDate: Value(commitmentDate),
      missedDays: Value(missedDays),
      dailyTarget: Value(dailyTarget),
      startDate: Value(startDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlanTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanTableData(
      id: serializer.fromJson<int>(json['id']),
      birthDate: serializer.fromJson<String>(json['birthDate']),
      bulughDate: serializer.fromJson<String>(json['bulughDate']),
      commitmentDate: serializer.fromJson<String>(json['commitmentDate']),
      missedDays: serializer.fromJson<int>(json['missedDays']),
      dailyTarget: serializer.fromJson<int>(json['dailyTarget']),
      startDate: serializer.fromJson<String>(json['startDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'birthDate': serializer.toJson<String>(birthDate),
      'bulughDate': serializer.toJson<String>(bulughDate),
      'commitmentDate': serializer.toJson<String>(commitmentDate),
      'missedDays': serializer.toJson<int>(missedDays),
      'dailyTarget': serializer.toJson<int>(dailyTarget),
      'startDate': serializer.toJson<String>(startDate),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlanTableData copyWith(
          {int? id,
          String? birthDate,
          String? bulughDate,
          String? commitmentDate,
          int? missedDays,
          int? dailyTarget,
          String? startDate,
          Value<String?> notes = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      PlanTableData(
        id: id ?? this.id,
        birthDate: birthDate ?? this.birthDate,
        bulughDate: bulughDate ?? this.bulughDate,
        commitmentDate: commitmentDate ?? this.commitmentDate,
        missedDays: missedDays ?? this.missedDays,
        dailyTarget: dailyTarget ?? this.dailyTarget,
        startDate: startDate ?? this.startDate,
        notes: notes.present ? notes.value : this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  PlanTableData copyWithCompanion(PlanTableCompanion data) {
    return PlanTableData(
      id: data.id.present ? data.id.value : this.id,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      bulughDate:
          data.bulughDate.present ? data.bulughDate.value : this.bulughDate,
      commitmentDate: data.commitmentDate.present
          ? data.commitmentDate.value
          : this.commitmentDate,
      missedDays:
          data.missedDays.present ? data.missedDays.value : this.missedDays,
      dailyTarget:
          data.dailyTarget.present ? data.dailyTarget.value : this.dailyTarget,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanTableData(')
          ..write('id: $id, ')
          ..write('birthDate: $birthDate, ')
          ..write('bulughDate: $bulughDate, ')
          ..write('commitmentDate: $commitmentDate, ')
          ..write('missedDays: $missedDays, ')
          ..write('dailyTarget: $dailyTarget, ')
          ..write('startDate: $startDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, birthDate, bulughDate, commitmentDate,
      missedDays, dailyTarget, startDate, notes, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanTableData &&
          other.id == this.id &&
          other.birthDate == this.birthDate &&
          other.bulughDate == this.bulughDate &&
          other.commitmentDate == this.commitmentDate &&
          other.missedDays == this.missedDays &&
          other.dailyTarget == this.dailyTarget &&
          other.startDate == this.startDate &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class PlanTableCompanion extends UpdateCompanion<PlanTableData> {
  final Value<int> id;
  final Value<String> birthDate;
  final Value<String> bulughDate;
  final Value<String> commitmentDate;
  final Value<int> missedDays;
  final Value<int> dailyTarget;
  final Value<String> startDate;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const PlanTableCompanion({
    this.id = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.bulughDate = const Value.absent(),
    this.commitmentDate = const Value.absent(),
    this.missedDays = const Value.absent(),
    this.dailyTarget = const Value.absent(),
    this.startDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlanTableCompanion.insert({
    this.id = const Value.absent(),
    required String birthDate,
    required String bulughDate,
    required String commitmentDate,
    required int missedDays,
    this.dailyTarget = const Value.absent(),
    required String startDate,
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : birthDate = Value(birthDate),
        bulughDate = Value(bulughDate),
        commitmentDate = Value(commitmentDate),
        missedDays = Value(missedDays),
        startDate = Value(startDate);
  static Insertable<PlanTableData> custom({
    Expression<int>? id,
    Expression<String>? birthDate,
    Expression<String>? bulughDate,
    Expression<String>? commitmentDate,
    Expression<int>? missedDays,
    Expression<int>? dailyTarget,
    Expression<String>? startDate,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (birthDate != null) 'birth_date': birthDate,
      if (bulughDate != null) 'bulugh_date': bulughDate,
      if (commitmentDate != null) 'commitment_date': commitmentDate,
      if (missedDays != null) 'missed_days': missedDays,
      if (dailyTarget != null) 'daily_target': dailyTarget,
      if (startDate != null) 'start_date': startDate,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlanTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? birthDate,
      Value<String>? bulughDate,
      Value<String>? commitmentDate,
      Value<int>? missedDays,
      Value<int>? dailyTarget,
      Value<String>? startDate,
      Value<String?>? notes,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return PlanTableCompanion(
      id: id ?? this.id,
      birthDate: birthDate ?? this.birthDate,
      bulughDate: bulughDate ?? this.bulughDate,
      commitmentDate: commitmentDate ?? this.commitmentDate,
      missedDays: missedDays ?? this.missedDays,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      startDate: startDate ?? this.startDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<String>(birthDate.value);
    }
    if (bulughDate.present) {
      map['bulugh_date'] = Variable<String>(bulughDate.value);
    }
    if (commitmentDate.present) {
      map['commitment_date'] = Variable<String>(commitmentDate.value);
    }
    if (missedDays.present) {
      map['missed_days'] = Variable<int>(missedDays.value);
    }
    if (dailyTarget.present) {
      map['daily_target'] = Variable<int>(dailyTarget.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanTableCompanion(')
          ..write('id: $id, ')
          ..write('birthDate: $birthDate, ')
          ..write('bulughDate: $bulughDate, ')
          ..write('commitmentDate: $commitmentDate, ')
          ..write('missedDays: $missedDays, ')
          ..write('dailyTarget: $dailyTarget, ')
          ..write('startDate: $startDate, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PrayerLogTableTable extends PrayerLogTable
    with TableInfo<$PrayerLogTableTable, PrayerLogTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PrayerLogTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _prayerMeta = const VerificationMeta('prayer');
  @override
  late final GeneratedColumn<String> prayer = GeneratedColumn<String>(
      'prayer', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _countMeta = const VerificationMeta('count');
  @override
  late final GeneratedColumn<int> count = GeneratedColumn<int>(
      'count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
      'completed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, date, prayer, count, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'prayer_log';
  @override
  VerificationContext validateIntegrity(Insertable<PrayerLogTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('prayer')) {
      context.handle(_prayerMeta,
          prayer.isAcceptableOrUnknown(data['prayer']!, _prayerMeta));
    } else if (isInserting) {
      context.missing(_prayerMeta);
    }
    if (data.containsKey('count')) {
      context.handle(
          _countMeta, count.isAcceptableOrUnknown(data['count']!, _countMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {date, prayer},
      ];
  @override
  PrayerLogTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PrayerLogTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      prayer: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}prayer'])!,
      count: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}count'])!,
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}completed_at'])!,
    );
  }

  @override
  $PrayerLogTableTable createAlias(String alias) {
    return $PrayerLogTableTable(attachedDatabase, alias);
  }
}

class PrayerLogTableData extends DataClass
    implements Insertable<PrayerLogTableData> {
  final int id;
  final String date;
  final String prayer;
  final int count;
  final DateTime completedAt;
  const PrayerLogTableData(
      {required this.id,
      required this.date,
      required this.prayer,
      required this.count,
      required this.completedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['prayer'] = Variable<String>(prayer);
    map['count'] = Variable<int>(count);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  PrayerLogTableCompanion toCompanion(bool nullToAbsent) {
    return PrayerLogTableCompanion(
      id: Value(id),
      date: Value(date),
      prayer: Value(prayer),
      count: Value(count),
      completedAt: Value(completedAt),
    );
  }

  factory PrayerLogTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PrayerLogTableData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      prayer: serializer.fromJson<String>(json['prayer']),
      count: serializer.fromJson<int>(json['count']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'prayer': serializer.toJson<String>(prayer),
      'count': serializer.toJson<int>(count),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  PrayerLogTableData copyWith(
          {int? id,
          String? date,
          String? prayer,
          int? count,
          DateTime? completedAt}) =>
      PrayerLogTableData(
        id: id ?? this.id,
        date: date ?? this.date,
        prayer: prayer ?? this.prayer,
        count: count ?? this.count,
        completedAt: completedAt ?? this.completedAt,
      );
  PrayerLogTableData copyWithCompanion(PrayerLogTableCompanion data) {
    return PrayerLogTableData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      prayer: data.prayer.present ? data.prayer.value : this.prayer,
      count: data.count.present ? data.count.value : this.count,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLogTableData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('prayer: $prayer, ')
          ..write('count: $count, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, prayer, count, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PrayerLogTableData &&
          other.id == this.id &&
          other.date == this.date &&
          other.prayer == this.prayer &&
          other.count == this.count &&
          other.completedAt == this.completedAt);
}

class PrayerLogTableCompanion extends UpdateCompanion<PrayerLogTableData> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> prayer;
  final Value<int> count;
  final Value<DateTime> completedAt;
  const PrayerLogTableCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.prayer = const Value.absent(),
    this.count = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  PrayerLogTableCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String prayer,
    this.count = const Value.absent(),
    this.completedAt = const Value.absent(),
  })  : date = Value(date),
        prayer = Value(prayer);
  static Insertable<PrayerLogTableData> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? prayer,
    Expression<int>? count,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (prayer != null) 'prayer': prayer,
      if (count != null) 'count': count,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  PrayerLogTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? date,
      Value<String>? prayer,
      Value<int>? count,
      Value<DateTime>? completedAt}) {
    return PrayerLogTableCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      prayer: prayer ?? this.prayer,
      count: count ?? this.count,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (prayer.present) {
      map['prayer'] = Variable<String>(prayer.value);
    }
    if (count.present) {
      map['count'] = Variable<int>(count.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PrayerLogTableCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('prayer: $prayer, ')
          ..write('count: $count, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PlanTableTable planTable = $PlanTableTable(this);
  late final $PrayerLogTableTable prayerLogTable = $PrayerLogTableTable(this);
  late final PlanDao planDao = PlanDao(this as AppDatabase);
  late final PrayerLogDao prayerLogDao = PrayerLogDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [planTable, prayerLogTable];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$PlanTableTableCreateCompanionBuilder = PlanTableCompanion Function({
  Value<int> id,
  required String birthDate,
  required String bulughDate,
  required String commitmentDate,
  required int missedDays,
  Value<int> dailyTarget,
  required String startDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$PlanTableTableUpdateCompanionBuilder = PlanTableCompanion Function({
  Value<int> id,
  Value<String> birthDate,
  Value<String> bulughDate,
  Value<String> commitmentDate,
  Value<int> missedDays,
  Value<int> dailyTarget,
  Value<String> startDate,
  Value<String?> notes,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$PlanTableTableFilterComposer
    extends Composer<_$AppDatabase, $PlanTableTable> {
  $$PlanTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bulughDate => $composableBuilder(
      column: $table.bulughDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get commitmentDate => $composableBuilder(
      column: $table.commitmentDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get missedDays => $composableBuilder(
      column: $table.missedDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyTarget => $composableBuilder(
      column: $table.dailyTarget, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$PlanTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanTableTable> {
  $$PlanTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bulughDate => $composableBuilder(
      column: $table.bulughDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get commitmentDate => $composableBuilder(
      column: $table.commitmentDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get missedDays => $composableBuilder(
      column: $table.missedDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyTarget => $composableBuilder(
      column: $table.dailyTarget, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$PlanTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanTableTable> {
  $$PlanTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get bulughDate => $composableBuilder(
      column: $table.bulughDate, builder: (column) => column);

  GeneratedColumn<String> get commitmentDate => $composableBuilder(
      column: $table.commitmentDate, builder: (column) => column);

  GeneratedColumn<int> get missedDays => $composableBuilder(
      column: $table.missedDays, builder: (column) => column);

  GeneratedColumn<int> get dailyTarget => $composableBuilder(
      column: $table.dailyTarget, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlanTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PlanTableTable,
    PlanTableData,
    $$PlanTableTableFilterComposer,
    $$PlanTableTableOrderingComposer,
    $$PlanTableTableAnnotationComposer,
    $$PlanTableTableCreateCompanionBuilder,
    $$PlanTableTableUpdateCompanionBuilder,
    (
      PlanTableData,
      BaseReferences<_$AppDatabase, $PlanTableTable, PlanTableData>
    ),
    PlanTableData,
    PrefetchHooks Function()> {
  $$PlanTableTableTableManager(_$AppDatabase db, $PlanTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> birthDate = const Value.absent(),
            Value<String> bulughDate = const Value.absent(),
            Value<String> commitmentDate = const Value.absent(),
            Value<int> missedDays = const Value.absent(),
            Value<int> dailyTarget = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PlanTableCompanion(
            id: id,
            birthDate: birthDate,
            bulughDate: bulughDate,
            commitmentDate: commitmentDate,
            missedDays: missedDays,
            dailyTarget: dailyTarget,
            startDate: startDate,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String birthDate,
            required String bulughDate,
            required String commitmentDate,
            required int missedDays,
            Value<int> dailyTarget = const Value.absent(),
            required String startDate,
            Value<String?> notes = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              PlanTableCompanion.insert(
            id: id,
            birthDate: birthDate,
            bulughDate: bulughDate,
            commitmentDate: commitmentDate,
            missedDays: missedDays,
            dailyTarget: dailyTarget,
            startDate: startDate,
            notes: notes,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PlanTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PlanTableTable,
    PlanTableData,
    $$PlanTableTableFilterComposer,
    $$PlanTableTableOrderingComposer,
    $$PlanTableTableAnnotationComposer,
    $$PlanTableTableCreateCompanionBuilder,
    $$PlanTableTableUpdateCompanionBuilder,
    (
      PlanTableData,
      BaseReferences<_$AppDatabase, $PlanTableTable, PlanTableData>
    ),
    PlanTableData,
    PrefetchHooks Function()>;
typedef $$PrayerLogTableTableCreateCompanionBuilder = PrayerLogTableCompanion
    Function({
  Value<int> id,
  required String date,
  required String prayer,
  Value<int> count,
  Value<DateTime> completedAt,
});
typedef $$PrayerLogTableTableUpdateCompanionBuilder = PrayerLogTableCompanion
    Function({
  Value<int> id,
  Value<String> date,
  Value<String> prayer,
  Value<int> count,
  Value<DateTime> completedAt,
});

class $$PrayerLogTableTableFilterComposer
    extends Composer<_$AppDatabase, $PrayerLogTableTable> {
  $$PrayerLogTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get prayer => $composableBuilder(
      column: $table.prayer, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));
}

class $$PrayerLogTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PrayerLogTableTable> {
  $$PrayerLogTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get prayer => $composableBuilder(
      column: $table.prayer, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get count => $composableBuilder(
      column: $table.count, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));
}

class $$PrayerLogTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PrayerLogTableTable> {
  $$PrayerLogTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get prayer =>
      $composableBuilder(column: $table.prayer, builder: (column) => column);

  GeneratedColumn<int> get count =>
      $composableBuilder(column: $table.count, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);
}

class $$PrayerLogTableTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PrayerLogTableTable,
    PrayerLogTableData,
    $$PrayerLogTableTableFilterComposer,
    $$PrayerLogTableTableOrderingComposer,
    $$PrayerLogTableTableAnnotationComposer,
    $$PrayerLogTableTableCreateCompanionBuilder,
    $$PrayerLogTableTableUpdateCompanionBuilder,
    (
      PrayerLogTableData,
      BaseReferences<_$AppDatabase, $PrayerLogTableTable, PrayerLogTableData>
    ),
    PrayerLogTableData,
    PrefetchHooks Function()> {
  $$PrayerLogTableTableTableManager(
      _$AppDatabase db, $PrayerLogTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PrayerLogTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PrayerLogTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PrayerLogTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> prayer = const Value.absent(),
            Value<int> count = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
          }) =>
              PrayerLogTableCompanion(
            id: id,
            date: date,
            prayer: prayer,
            count: count,
            completedAt: completedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String date,
            required String prayer,
            Value<int> count = const Value.absent(),
            Value<DateTime> completedAt = const Value.absent(),
          }) =>
              PrayerLogTableCompanion.insert(
            id: id,
            date: date,
            prayer: prayer,
            count: count,
            completedAt: completedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PrayerLogTableTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PrayerLogTableTable,
    PrayerLogTableData,
    $$PrayerLogTableTableFilterComposer,
    $$PrayerLogTableTableOrderingComposer,
    $$PrayerLogTableTableAnnotationComposer,
    $$PrayerLogTableTableCreateCompanionBuilder,
    $$PrayerLogTableTableUpdateCompanionBuilder,
    (
      PrayerLogTableData,
      BaseReferences<_$AppDatabase, $PrayerLogTableTable, PrayerLogTableData>
    ),
    PrayerLogTableData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PlanTableTableTableManager get planTable =>
      $$PlanTableTableTableManager(_db, _db.planTable);
  $$PrayerLogTableTableTableManager get prayerLogTable =>
      $$PrayerLogTableTableTableManager(_db, _db.prayerLogTable);
}

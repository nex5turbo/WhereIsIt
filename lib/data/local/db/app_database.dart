import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

// Tables
class Spaces extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get parentId => text().nullable().references(Spaces, #id)();
  TextColumn get name => text()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get depth => integer().withDefault(const Constant(0))();
  IntColumn get itemCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Items extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get spaceId => text().references(Spaces, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('STORED'))(); // ENUM as Text
  DateTimeColumn get lastUsedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class UsageLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itemId => text().references(Items, #id)();
  TextColumn get actionType => text()(); // CHECK_OUT, RESTORE
  DateTimeColumn get timestamp => dateTime()();
}

@DriftDatabase(tables: [Spaces, Items, UsageLogs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

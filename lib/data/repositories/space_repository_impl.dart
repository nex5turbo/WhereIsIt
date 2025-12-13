import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/space_repository.dart';
import '../../domain/entities/space.dart';
import '../local/db/app_database.dart' as db;
import 'package:uuid/uuid.dart';

part 'space_repository_impl.g.dart';

class SpaceRepositoryImpl implements SpaceRepository {
  final db.AppDatabase _database;

  SpaceRepositoryImpl(this._database);

  @override
  Future<void> createSpace({required String name, String? parentId}) async {
    final uuid = const Uuid().v4();

    // Calculate depth
    int depth = 0;
    if (parentId != null) {
      final parent = await (_database.select(
        _database.spaces,
      )..where((tbl) => tbl.id.equals(parentId))).getSingleOrNull();
      if (parent != null) {
        depth = parent.depth + 1;
      }
    }

    await _database
        .into(_database.spaces)
        .insert(
          db.SpacesCompanion.insert(
            id: uuid,
            name: name,
            parentId: Value(parentId),
            depth: Value(depth),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<void> deleteSpace(String id) async {
    // Cascade delete is handled by DB reference usually, or manually here.
    // For now, simple delete. (Recursive delete needed for children in real app)
    await (_database.delete(
      _database.spaces,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<List<Space>> getSpaces({String? parentId}) async {
    final query = _database.select(_database.spaces);
    if (parentId != null) {
      query.where((tbl) => tbl.parentId.equals(parentId));
    } else {
      query.where((tbl) => tbl.parentId.isNull());
    }

    final dbSpaces = await query.get();
    return dbSpaces.map((e) => _mapToEntity(e)).toList();
  }

  @override
  Stream<List<Space>> watchSpaces({String? parentId}) {
    final query = _database.select(_database.spaces);
    if (parentId != null) {
      query.where((tbl) => tbl.parentId.equals(parentId));
    } else {
      query.where((tbl) => tbl.parentId.isNull());
    }

    return query.watch().map(
      (rows) => rows.map((e) => _mapToEntity(e)).toList(),
    );
  }

  @override
  Future<Space?> getSpace(String id) async {
    final dbSpace = await (_database.select(
      _database.spaces,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
    return dbSpace != null ? _mapToEntity(dbSpace) : null;
  }

  @override
  Future<List<Space>> getBreadcrumbs(String spaceId) async {
    // Recursive lookup
    final List<Space> breadcrumbs = [];
    String? currentId = spaceId;

    while (currentId != null) {
      final space = await getSpace(currentId);
      if (space == null) break;
      breadcrumbs.insert(0, space);
      currentId = space.parentId;
    }
    return breadcrumbs;
  }

  @override
  Future<void> updateSpace(Space space) async {
    await (_database.update(
      _database.spaces,
    )..where((tbl) => tbl.id.equals(space.id))).write(
      db.SpacesCompanion(
        name: Value(space.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Space _mapToEntity(db.Space row) {
    return Space(
      id: row.id,
      name: row.name,
      parentId: row.parentId,
      depth: row.depth,
      itemCount: row.itemCount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

// Providers
@riverpod
db.AppDatabase appDatabase(Ref ref) {
  return db.AppDatabase();
}

@riverpod
SpaceRepository spaceRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  return SpaceRepositoryImpl(database);
}

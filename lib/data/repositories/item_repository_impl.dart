import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/entities/item.dart';
import '../local/db/app_database.dart' as db;
import 'space_repository_impl.dart'; // for appDatabaseProvider

part 'item_repository_impl.g.dart';

class ItemRepositoryImpl implements ItemRepository {
  final db.AppDatabase _database;

  ItemRepositoryImpl(this._database);

  @override
  Future<void> createItem(Item item) async {
    await _database.into(_database.items).insert(
      db.ItemsCompanion.insert(
        id: item.id,
        spaceId: item.spaceId,
        name: item.name,
        description: Value(item.description),
        category: Value(item.category),
        imagePath: Value(item.imagePath),
        status: Value(item.status.name), // Store as String
        lastUsedAt: Value(item.lastUsedAt),
      ),
    );
  }

  @override
  Future<void> deleteItem(String id) async {
    await (_database.delete(_database.items)..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<List<Item>> getItemsInSpace(String spaceId) async {
    final rows = await (_database.select(_database.items)..where((tbl) => tbl.spaceId.equals(spaceId))).get();
    return rows.map((e) => _mapToEntity(e)).toList();
  }

  @override
  Future<void> toggleStatus(String itemId, ItemStatus newStatus) async {
    await (_database.update(_database.items)..where((tbl) => tbl.id.equals(itemId))).write(
      db.ItemsCompanion(
        status: Value(newStatus.name),
        lastUsedAt: Value(newStatus == ItemStatus.inUse ? DateTime.now() : null),
      ),
    );
    // Log usage here if needed
  }

  @override
  Future<void> updateItem(Item item) async {
     await (_database.update(_database.items)..where((tbl) => tbl.id.equals(item.id))).write(
      db.ItemsCompanion(
        name: Value(item.name),
        description: Value(item.description),
        category: Value(item.category),
        imagePath: Value(item.imagePath),
      ),
    );
  }

  Item _mapToEntity(db.Item row) {
    return Item(
      id: row.id,
      spaceId: row.spaceId,
      name: row.name,
      description: row.description,
      category: row.category,
      imagePath: row.imagePath,
      status: ItemStatus.values.firstWhere((e) => e.name == row.status, orElse: () => ItemStatus.stored),
      lastUsedAt: row.lastUsedAt,
      isSynced: row.isSynced,
    );
  }
}

@riverpod
ItemRepository itemRepository(ItemRepositoryRef ref) {
  final database = ref.watch(appDatabaseProvider);
  return ItemRepositoryImpl(database);
}

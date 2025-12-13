import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/entities/item.dart';
import '../local/db/app_database.dart' as db;
import 'space_repository_impl.dart'; // for appDatabaseProvider
import '../../core/services/notification_service.dart';

part 'item_repository_impl.g.dart';

class ItemRepositoryImpl implements ItemRepository {
  final db.AppDatabase _database;
  final NotificationService _notificationService;

  ItemRepositoryImpl(this._database, this._notificationService);

  @override
  Future<void> createItem(Item item) async {
    await _database.transaction(() async {
      await _database
          .into(_database.items)
          .insert(
            db.ItemsCompanion.insert(
              id: item.id,
              spaceId: item.spaceId,
              name: item.name,
              description: Value(item.description),
              category: Value(item.category),
              imagePath: Value(item.imagePath),
              status: Value(item.status.name),
              lastUsedAt: Value(item.lastUsedAt),
            ),
          );

      // Update Space itemCount
      final space = await (_database.select(
        _database.spaces,
      )..where((tbl) => tbl.id.equals(item.spaceId))).getSingle();

      await (_database.update(_database.spaces)
            ..where((tbl) => tbl.id.equals(item.spaceId)))
          .write(db.SpacesCompanion(itemCount: Value(space.itemCount + 1)));
    });
  }

  @override
  Future<void> deleteItem(String id) async {
    await _database.transaction(() async {
      // Get item to find spaceId before deleting
      final item = await (_database.select(
        _database.items,
      )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

      if (item != null) {
        await (_database.delete(
          _database.items,
        )..where((tbl) => tbl.id.equals(id))).go();

        // Update Space itemCount
        final space = await (_database.select(
          _database.spaces,
        )..where((tbl) => tbl.id.equals(item.spaceId))).getSingle();

        await (_database.update(
          _database.spaces,
        )..where((tbl) => tbl.id.equals(item.spaceId))).write(
          db.SpacesCompanion(
            itemCount: Value(space.itemCount > 0 ? space.itemCount - 1 : 0),
          ),
        );
      }
    });
  }

  @override
  Future<List<Item>> getItemsInSpace(String spaceId) async {
    final rows = await (_database.select(
      _database.items,
    )..where((tbl) => tbl.spaceId.equals(spaceId))).get();
    return rows.map((e) => _mapToEntity(e)).toList();
  }

  @override
  Future<void> toggleStatus(String itemId, ItemStatus newStatus) async {
    // 1. Update status
    await (_database.update(
      _database.items,
    )..where((tbl) => tbl.id.equals(itemId))).write(
      db.ItemsCompanion(
        status: Value(newStatus.name),
        lastUsedAt: Value(
          newStatus == ItemStatus.inUse ? DateTime.now() : null,
        ),
      ),
    );

    // 2. Handle Notifications
    if (newStatus == ItemStatus.inUse) {
      // Need to fetch item to get name
      final itemRow = await (_database.select(
        _database.items,
      )..where((tbl) => tbl.id.equals(itemId))).getSingleOrNull();

      if (itemRow != null) {
        await _notificationService.scheduleReminder(
          id: itemId.hashCode, // Use hashCode of UUID string as int ID
          title: 'Where is it?',
          body: 'Have you returned "${itemRow.name}"?',
          duration: const Duration(seconds: 5), // Default 3 hours
        );
      }
    } else {
      await _notificationService.cancelReminder(itemId.hashCode);
    }
  }

  @override
  Future<void> updateItem(Item item) async {
    await (_database.update(
      _database.items,
    )..where((tbl) => tbl.id.equals(item.id))).write(
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
      status: ItemStatus.values.firstWhere(
        (e) => e.name == row.status,
        orElse: () => ItemStatus.stored,
      ),
      lastUsedAt: row.lastUsedAt,
      isSynced: row.isSynced,
    );
  }
}

@riverpod
ItemRepository itemRepository(Ref ref) {
  final database = ref.watch(appDatabaseProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return ItemRepositoryImpl(database, notificationService);
}

import '../entities/item.dart';

abstract class ItemRepository {
  Future<List<Item>> getItemsInSpace(String spaceId);
  Future<void> createItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);
  Future<void> toggleStatus(String itemId, ItemStatus newStatus);
}

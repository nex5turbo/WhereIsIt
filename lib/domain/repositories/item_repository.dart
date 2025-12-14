import '../entities/item.dart';

abstract class ItemRepository {
  Stream<List<Item>> getItemsInSpace(String spaceId);
  Future<void> createItem(Item item);
  Future<void> updateItem(Item item);
  Future<void> deleteItem(String id);
  Future<void> toggleStatus(String itemId, ItemStatus newStatus);
  Stream<List<Item>> getAllInUseItems();
  Future<void> moveItem(String itemId, String newSpaceId);
}

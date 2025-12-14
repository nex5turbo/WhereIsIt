import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/item.dart';
import '../../data/repositories/item_repository_impl.dart';

part 'item_providers.g.dart';

@riverpod
@riverpod
Stream<List<Item>> itemsInSpace(Ref ref, String spaceId) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getItemsInSpace(spaceId);
}

@riverpod
Stream<List<Item>> allInUseItems(Ref ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getAllInUseItems();
}

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/item.dart';
import '../../data/repositories/item_repository_impl.dart';

part 'item_providers.g.dart';

@riverpod
Future<List<Item>> itemsInSpace(Ref ref, String spaceId) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getItemsInSpace(spaceId);
}

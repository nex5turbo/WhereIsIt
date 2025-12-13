import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/space.dart';
import '../../data/repositories/space_repository_impl.dart';

part 'space_providers.g.dart';

@riverpod
Stream<List<Space>> spaces(Ref ref, {String? parentId}) {
  final repository = ref.watch(spaceRepositoryProvider);
  return repository.watchSpaces(parentId: parentId);
}

@riverpod
Future<List<Space>> breadcrumbs(Ref ref, String spaceId) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return repository.getBreadcrumbs(spaceId);
}

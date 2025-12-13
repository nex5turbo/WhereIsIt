import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/space.dart';
import '../../data/repositories/space_repository_impl.dart';

part 'space_providers.g.dart';

@riverpod
Future<List<Space>> spaces(Ref ref, {String? parentId}) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return repository.getSpaces(parentId: parentId);
}

@riverpod
Future<List<Space>> breadcrumbs(Ref ref, String spaceId) async {
  final repository = ref.watch(spaceRepositoryProvider);
  return repository.getBreadcrumbs(spaceId);
}

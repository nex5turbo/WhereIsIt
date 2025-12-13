import '../entities/space.dart';

abstract class SpaceRepository {
  Future<List<Space>> getSpaces({String? parentId});
  Future<Space?> getSpace(String id);
  Future<void> createSpace({required String name, String? parentId});
  Future<void> updateSpace(Space space);
  Future<void> deleteSpace(String id);
  Future<List<Space>> getBreadcrumbs(String spaceId);
}

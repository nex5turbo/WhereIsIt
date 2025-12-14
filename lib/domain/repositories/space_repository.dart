import '../entities/space.dart';

abstract class SpaceRepository {
  Future<List<Space>> getSpaces({String? parentId});
  Stream<List<Space>> watchSpaces({String? parentId});
  Future<Space?> getSpace(String id);
  Future<void> createSpace({
    required String name,
    String? parentId,
    String? imagePath,
  });
  Future<void> updateSpace(Space space);
  Future<void> deleteSpace(String id);
  Future<List<Space>> getBreadcrumbs(String spaceId);
  Future<List<Space>> getAllSpaces();
  Future<void> moveSpace(String spaceId, String? newParentId);
}

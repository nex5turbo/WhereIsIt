class Space {
  final String id;
  final String name;
  final String? parentId;
  final String? imagePath;
  final int depth;
  final int itemCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Space({
    required this.id,
    required this.name,
    this.parentId,
    this.imagePath,
    required this.depth,
    this.itemCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });
}

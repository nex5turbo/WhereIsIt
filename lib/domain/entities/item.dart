enum ItemStatus {
  stored,
  inUse;

  String get label => this == stored ? 'Stored' : 'In Use';
}

class Item {
  final String id;
  final String spaceId;
  final String name;
  final String? description;
  final String? category;
  final String? imagePath;
  final ItemStatus status;
  final DateTime? lastUsedAt;
  final int? quantity;
  final bool isSynced;

  Item({
    required this.id,
    required this.spaceId,
    required this.name,
    this.description,
    this.category,
    this.imagePath,
    required this.status,
    this.lastUsedAt,
    this.quantity,
    this.isSynced = false,
  });
}

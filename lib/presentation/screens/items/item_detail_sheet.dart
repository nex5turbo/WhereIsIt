import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/item.dart';
import '../../../data/repositories/item_repository_impl.dart';
import '../../../utils/image_helper.dart';
import 'create_item_sheet.dart';

class ItemDetailSheet extends ConsumerWidget {
  final Item item;

  const ItemDetailSheet({super.key, required this.item});

  Future<void> _deleteItem(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(itemRepositoryProvider).deleteItem(item.id);
        if (context.mounted) {
          context.pop(); // Close detail sheet
        }
      } catch (e) {
        debugPrint('Error deleting item: $e');
      }
    }
  }

  void _editItem(BuildContext context) {
    context.pop(); // Close detail sheet
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CreateItemSheet(
        spaceId: item.spaceId,
        existingItem: item,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInUse = item.status == ItemStatus.inUse;

    return Container(
      decoration: const BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
            ),

            // Hero Image or Icon
            FutureBuilder<File?>(
              future: ImageHelper.getImageFile(item.imagePath),
              builder: (context, snapshot) {
                final imageFile = snapshot.data;
                if (item.imagePath != null && imageFile != null) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: FileImage(imageFile),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  height: 100,
                  width: 100,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.systemGroupedBackground,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.cube_box_fill,
                    size: 48,
                    color: CupertinoColors.systemBlue,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Title & Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isInUse
                          ? CupertinoColors.destructiveRed.withOpacity(0.1)
                          : CupertinoColors.activeGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isInUse
                            ? CupertinoColors.destructiveRed.withOpacity(0.2)
                            : CupertinoColors.activeGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isInUse
                              ? CupertinoIcons.exclamationmark_circle_fill
                              : CupertinoIcons.checkmark_circle_fill,
                          size: 14,
                          color: isInUse
                              ? CupertinoColors.destructiveRed
                              : CupertinoColors.activeGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.status.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isInUse
                                ? CupertinoColors.destructiveRed
                                : CupertinoColors.activeGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Meta Info (Category, Quantity)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (item.category != null) ...[
                    _buildInfoChip(
                        CupertinoIcons.tag_fill, item.category!, CupertinoColors.systemBlue),
                    const SizedBox(width: 12),
                  ],
                  _buildInfoChip(
                    CupertinoIcons.number_circle_fill,
                    item.quantity != null
                        ? '${item.quantity} units'
                        : '1 unit',
                    CupertinoColors.systemOrange,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () => _editItem(context),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.pencil,
                              color: CupertinoColors.label, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Edit',
                            style: TextStyle(
                              color: CupertinoColors.label,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      color: CupertinoColors.activeOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      onPressed: () => _deleteItem(context, ref),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(CupertinoIcons.trash,
                              color: CupertinoColors.destructiveRed, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(
                              color: CupertinoColors.destructiveRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: CupertinoColors.systemGrey),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.label,
            ),
          ),
        ],
      ),
    );
  }
}

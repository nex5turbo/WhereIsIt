import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/space.dart';
import '../../../data/repositories/space_repository_impl.dart';
import '../../../utils/image_helper.dart';
import 'create_space_sheet.dart';

class SpaceDetailSheet extends ConsumerWidget {
  final Space space;

  const SpaceDetailSheet({super.key, required this.space});

  Future<void> _deleteSpace(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Space'),
        content: Text('Are you sure you want to delete "${space.name}"?'),
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
        await ref.read(spaceRepositoryProvider).deleteSpace(space.id);
        if (context.mounted) {
          context.pop(); // Close detail sheet
        }
      } catch (e) {
        debugPrint('Error deleting space: $e');
      }
    }
  }

  void _editSpace(BuildContext context) {
    context.pop(); // Close detail sheet
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CreateSpaceSheet(
        parentId: space.parentId,
        existingSpace: space,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              future: ImageHelper.getImageFile(space.imagePath),
              builder: (context, snapshot) {
                final imageFile = snapshot.data;
                if (space.imagePath != null && imageFile != null) {
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
                    CupertinoIcons.folder_solid,
                    size: 48,
                    color: CupertinoColors.systemYellow,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Title & Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    space.name,
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
                      color: CupertinoColors.systemGrey6,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${space.itemCount} items',
                      style: const TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.secondaryLabel,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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
                      onPressed: () => _editSpace(context),
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
                      onPressed: () => _deleteSpace(context, ref),
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
}


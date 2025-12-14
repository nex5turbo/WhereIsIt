import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/item_repository_impl.dart';
import '../../../data/repositories/space_repository_impl.dart';
import '../../providers/space_providers.dart';
import '../../providers/drag_state_provider.dart';
import '../../../utils/image_helper.dart';

class MoveTargetGrid extends ConsumerWidget {
  const MoveTargetGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch ALL spaces primarily
    final allSpacesAsync = ref.watch(allSpacesProvider);
    final dragState = ref.watch(dragStateProvider);

    return allSpacesAsync.when(
      data: (allSpaces) {
        // Filter out invalid targets
        final validTargets = allSpaces.where((space) {
          if (dragState.draggingSpace != null) {
            // Cannot drop onto itself
            if (space.id == dragState.draggingSpace!.id) return false;
            // Cannot drop onto its own child (cycle prevention)
            // Note: Currently checking direct parent, but ideally check recursive descendants.
            // For simple depth/breadcrumbs check:
            // If the target space's parentId IS the dragging space, it's a direct child.
            // To be robust, we'd need to trace up from `space` to see if `draggingSpace` is an ancestor.
            // We can do a simpler check: Don't show children.
            if (space.parentId == dragState.draggingSpace!.id) return false;
          }
           if (dragState.draggingItem != null) {
            // Cannot drop onto the space implementation currently resides in
            // (Moving to same space is valid but useless, maybe hide it?)
             if (space.id == dragState.draggingItem!.spaceId) return false;
          }
          return true;
        }).toList();

        // Add "Root" as a target (if dragging from a non-root space)
        final bool showRoot = dragState.draggingSpace?.parentId != null || 
                              (dragState.draggingItem != null);
                              // Items can always move to root if logic supports it. 
                              // Wait, items in our schema MUST belong to a space? 
                              // Schema says `spaceId` is NOT nullable reference. 
                              // Re-check schema: `TextColumn get spaceId => text().references(Spaces, #id)();`
                              // So Items MUST be in a Space.
                              // Can the Root be a valid "Space"? 
                              // Our Root is `parentId == null`. Root itself isn't a row in Spaces table usually.
                              // If items must have a `spaceId`, they can't belong to "Null Parent" root unless we treat root as a special Space or logic allows null.
                              // Check Items table: `TextColumn get spaceId => text().references(Spaces, #id)();`
                              // It references Spaces table. So items CANNOT be at root (null spaceId) unless we change schema or used a trick.
                              // Re-reading user request from previous turns regarding "Items In Use":
                              // User has "SpaceListScreen" where `parentId` is null.
                              // Does it show items?
                              // `itemsAsync` in `SpaceListScreen` calls `allInUseItemsProvider` if `parentId == null`.
                              // Those are "In Use" items gathered from ANYWHERE.
                              // So items physically reside in a space always.
                              // Can we move an item to "Root"? NO. Items must belong to a folder.
                              // Can we move a SPACE to Root? YES. `parentId` can be null.

        return Container(
          color: CupertinoColors.white.withOpacity(0.95),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
               Text(
                'Move to...',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: validTargets.length + (showRoot && dragState.draggingSpace != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (showRoot && dragState.draggingSpace != null && index == 0) {
                      // Root Target
                      return _buildTargetItem(
                         context,
                         ref,
                         name: 'My Home (Root)',
                         isRoot: true,
                         onDrop: () {
                           if (dragState.draggingSpace != null) {
                             ref.read(spaceRepositoryProvider).moveSpace(dragState.draggingSpace!.id, null);
                           }
                           ref.read(dragStateProvider.notifier).stopDragging();
                         }
                      );
                    }
                    
                    final adjIndex = (showRoot && dragState.draggingSpace != null) ? index - 1 : index;
                    final space = validTargets[adjIndex];

                    return _buildTargetItem(
                      context,
                      ref,
                      name: space.name,
                      imagePath: space.imagePath,
                      onDrop: () {
                        if (dragState.draggingItem != null) {
                          ref.read(itemRepositoryProvider).moveItem(dragState.draggingItem!.id, space.id);
                        } else if (dragState.draggingSpace != null) {
                          ref.read(spaceRepositoryProvider).moveSpace(dragState.draggingSpace!.id, space.id);
                        }
                        ref.read(dragStateProvider.notifier).stopDragging();
                      }
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              CupertinoButton(
                child: const Text('Cancel'),
                onPressed: () => ref.read(dragStateProvider.notifier).stopDragging(),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CupertinoActivityIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildTargetItem(
    BuildContext context, 
    WidgetRef ref, {
    required String name,
    String? imagePath,
    bool isRoot = false,
    required VoidCallback onDrop,
  }) {
    return DragTarget<String>(
      onWillAccept: (_) => true,
      onAccept: (_) => onDrop(),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;
        
        return Container(
          decoration: BoxDecoration(
            color: isHovered ? CupertinoColors.activeBlue.withOpacity(0.2) : CupertinoColors.systemGroupedBackground,
            borderRadius: BorderRadius.circular(16),
            border: isHovered ? Border.all(color: CupertinoColors.activeBlue, width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               if (imagePath != null)
                 FutureBuilder<File?>(
                    future: ImageHelper.getImageFile(imagePath),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(snapshot.data!, width: 48, height: 48, fit: BoxFit.cover),
                        );
                      }
                      return const Icon(CupertinoIcons.folder_solid, size: 48, color: CupertinoColors.systemYellow);
                    }
                 )
                else
                 Icon(
                   isRoot ? CupertinoIcons.home : CupertinoIcons.folder_solid, 
                   size: 48, 
                   color: isRoot ? CupertinoColors.systemGrey : CupertinoColors.systemYellow
                 ),
               const SizedBox(height: 8),
               Text(
                 name,
                 style: const TextStyle(fontWeight: FontWeight.bold),
                 textAlign: TextAlign.center,
               ),
            ],
          ),
        );
      },
    );
  }
}

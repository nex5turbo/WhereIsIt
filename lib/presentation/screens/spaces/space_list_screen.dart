import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/space.dart';
import '../../providers/item_providers.dart';
import '../items/create_item_sheet.dart';
import '../items/item_detail_sheet.dart';
import '../../../data/repositories/item_repository_impl.dart'; // for provider
import '../../providers/space_providers.dart';
import '../../providers/view_mode_provider.dart';
import 'create_space_sheet.dart';
import 'space_graph_view.dart';
import 'space_detail_sheet.dart';
import '../../../utils/image_helper.dart';

class SpaceListScreen extends ConsumerWidget {
  final String? parentId;

  const SpaceListScreen({super.key, this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(currentViewModeProvider);

    final breadcrumbsAsync = parentId != null
        ? ref.watch(breadcrumbsProvider(parentId!))
        : const AsyncValue.data(<Space>[]);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        // Leading handled automatically by Navigator/GoRouter usually, or explicit back button
        // leading: parentId != null
        //     ? CupertinoNavigationBarBackButton(onPressed: () => context.pop())
        //     : null,
        leading: breadcrumbsAsync.when(
          data: (crumbs) {
            // Combine "My Home" and the spaces path
            final breadcrumbItems = [
              // Root item placeholder
              _BreadcrumbItem(name: 'My Home', id: null),
              ...crumbs.map((s) => _BreadcrumbItem(name: s.name, id: s.id)),
            ];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: breadcrumbItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast = index == breadcrumbItems.length - 1;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Separator (don't show before the first item)
                      if (index > 0)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            '>',
                            style: TextStyle(
                              color: CupertinoColors.systemGrey,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Breadcrumb Item
                      GestureDetector(
                        onTap: isLast
                            ? null
                            : () {
                                if (item.id == null) {
                                  context.go('/');
                                } else {
                                  context.go('/space/${item.id}');
                                }
                              },
                        child: Text(
                          item.name,
                          style: TextStyle(
                            color: isLast
                                ? CupertinoColors.black
                                : CupertinoColors.systemGrey,
                            fontWeight: isLast
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Add Button (replaces FAB)
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.add),
              onPressed: () {
                // Show action sheet to choose Space or Item
                if (parentId != null) {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => CupertinoActionSheet(
                      actions: [
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            showCupertinoModalPopup(
                              context: context,
                              builder: (_) =>
                                  CreateSpaceSheet(parentId: parentId),
                            );
                          },
                          child: const Text('New Folder'),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            showCupertinoModalPopup(
                              context: context,
                              builder: (_) =>
                                  CreateItemSheet(spaceId: parentId!),
                            );
                          },
                          child: const Text('New Item'),
                        ),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  );
                } else {
                  // Only Space allowed at root
                  showCupertinoModalPopup(
                    context: context,
                    builder: (_) => CreateSpaceSheet(parentId: parentId),
                  );
                }
              },
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // View Mode Toggle (Below Nav Bar)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                child: CupertinoSlidingSegmentedControl<ViewMode>(
                  groupValue: viewMode,
                  children: const {
                    ViewMode.list: Text('List'),
                    ViewMode.grid: Text('Grid'),
                    ViewMode.graph: Text('Tree'),
                  },
                  onValueChanged: (mode) {
                    if (mode != null) {
                      ref.read(currentViewModeProvider.notifier).setMode(mode);
                    }
                  },
                ),
              ),
            ),
            Expanded(
              child: viewMode == ViewMode.graph
                  ? SpaceGraphView(rootId: parentId)
                  : _buildScrollView(context, ref, viewMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollView(
    BuildContext context,
    WidgetRef ref,
    ViewMode viewMode,
  ) {
    final spacesAsync = ref.watch(spacesProvider(parentId: parentId));
    final itemsAsync = parentId != null
        ? ref.watch(itemsInSpaceProvider(parentId!))
        : const AsyncValue.data(<Item>[]);

    return CustomScrollView(
      slivers: [
        spacesAsync.when(
          data: (spaces) {
            if (viewMode == ViewMode.grid) {
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      2, // 2 columns usually looks better with images
                  childAspectRatio: 1.0, // Square for better image visibility
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final space = spaces[index];
                  final hasImage = space.imagePath != null;
                  return Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemGroupedBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FutureBuilder<File?>(
                        future: ImageHelper.getImageFile(space.imagePath),
                        builder: (context, snapshot) {
                          final imageFile = snapshot.data;
                          final showImage = hasImage && imageFile != null;
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background (Image or Placeholder)
                              if (showImage)
                                Image.file(
                                  imageFile,
                                  fit: BoxFit.cover,
                                  color: const Color(
                                      0xFF000000), // Base color to blend
                                  colorBlendMode: BlendMode.dstATop,
                                )
                              else
                                Container(color: CupertinoColors.systemGroupedBackground),
                              
                              if (showImage)
                                Container(
                                  color: CupertinoColors.black.withOpacity(0.3),
                                ),

                              // Content Split
                              Row(
                                children: [
                                  // Left 80% - Details
                                  Expanded(
                                    flex: 4,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        showCupertinoModalPopup(
                                          context: context,
                                          builder: (context) =>
                                              SpaceDetailSheet(space: space),
                                        );
                                      },
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          if (!showImage)
                                            const Icon(
                                              CupertinoIcons.folder_solid,
                                              size: 32, // Slightly smaller to fit
                                              color: CupertinoColors.systemYellow,
                                            ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 4.0),
                                            child: Text(
                                              space.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: showImage
                                                    ? CupertinoColors.white
                                                    : CupertinoColors.black,
                                                fontSize: showImage ? 18 : 16,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            '${space.itemCount} items',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: showImage
                                                  ? CupertinoColors.white
                                                      .withOpacity(0.8)
                                                  : CupertinoColors.systemGrey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Right 20% - Navigation
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () =>
                                          context.push('/space/${space.id}'),
                                      child: Container(
                                        color: showImage ? CupertinoColors.black.withOpacity(0.1) : CupertinoColors.systemGrey6.withOpacity(0.5),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          CupertinoIcons.chevron_forward,
                                          color: showImage ? CupertinoColors.white : CupertinoColors.systemGrey,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  );
                }, childCount: spaces.length),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final space = spaces[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        // Main Click Area (Image + Text)
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              showCupertinoModalPopup(
                                context: context,
                                builder: (context) =>
                                    SpaceDetailSheet(space: space),
                              );
                            },
                            child: Row(
                              children: [
                                FutureBuilder<File?>(
                                  future:
                                      ImageHelper.getImageFile(space.imagePath),
                                  builder: (context, snapshot) {
                                    final imageFile = snapshot.data;
                                    return space.imagePath != null &&
                                            imageFile != null
                                        ? Container(
                                            width: 80,
                                            height: 80,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              image: DecorationImage(
                                                image: FileImage(imageFile),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            CupertinoIcons.folder_solid,
                                            color: CupertinoColors.systemYellow,
                                            size: 48,
                                          );
                                  },
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        space.name,
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .copyWith(fontSize: 17),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text('${space.itemCount} items',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: CupertinoColors.systemGrey,
                                          )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Navigation Area
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => context.push('/space/${space.id}'),
                          child: Container(
                            height: 80, // Match typical height or make flexible
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            child: const Icon(
                              CupertinoIcons.chevron_forward,
                              color: CupertinoColors.systemGrey3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }, childCount: spaces.length),
            );
          },
          loading: () =>
              const SliverToBoxAdapter(child: CupertinoActivityIndicator()),
          error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
        ),

        if (itemsAsync.hasValue && itemsAsync.value!.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Items',
                style: CupertinoTheme.of(context).textTheme.navTitleTextStyle,
              ),
            ),
          ),

        itemsAsync.when(
          data: (items) {
            if (viewMode == ViewMode.grid) {
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.0,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  final isInUse = item.status == ItemStatus.inUse;
                  final hasImage = item.imagePath != null;

                  return GestureDetector(
                    onTap: () {
                      showCupertinoModalPopup(
                        context: context,
                        builder: (context) => ItemDetailSheet(item: item),
                      );
                    },
                    child: FutureBuilder<File?>(
                      future: ImageHelper.getImageFile(item.imagePath),
                      builder: (context, snapshot) {
                        final imageFile = snapshot.data;
                        final showImage = hasImage && imageFile != null;
                        return Container(
                          decoration: BoxDecoration(
                            color: isInUse
                                ? CupertinoColors.systemRed.withOpacity(0.1)
                                : CupertinoColors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: showImage
                                ? DecorationImage(
                                    image: FileImage(imageFile),
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(
                                      CupertinoColors.black.withOpacity(
                                        isInUse ? 0.5 : 0.3,
                                      ),
                                      BlendMode.darken,
                                    ),
                                  )
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (!showImage)
                                    Icon(
                                      isInUse
                                          ? CupertinoIcons.exclamationmark_circle
                                          : CupertinoIcons.check_mark_circled,
                                      size: 48,
                                      color: isInUse
                                          ? CupertinoColors.systemRed
                                          : CupertinoColors.systemGreen,
                                    ),
                                  if (!showImage) const SizedBox(height: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            item.name,
                                            style: TextStyle(
                                              decoration: isInUse
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              fontWeight: FontWeight.w600,
                                              color: showImage
                                                  ? CupertinoColors.white
                                                  : CupertinoColors.black,
                                              fontSize: showImage ? 20 : 16,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (item.quantity != null && item.quantity! > 1) ...[
                                          const SizedBox(width: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: showImage
                                                  ? CupertinoColors.white.withOpacity(0.3)
                                                  : CupertinoColors.systemGrey5,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '×${item.quantity}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: showImage
                                                    ? CupertinoColors.white
                                                    : CupertinoColors.systemGrey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Text(
                                    item.status.label,
                                    style: TextStyle(
                                      color: showImage
                                          ? CupertinoColors.white.withOpacity(0.8)
                                          : CupertinoColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              if (isInUse && showImage)
                                const Center(
                                  child: Icon(
                                    CupertinoIcons.exclamationmark_circle,
                                    size: 64,
                                    color: CupertinoColors.destructiveRed,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }, childCount: items.length),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = items[index];
                final isInUse = item.status == ItemStatus.inUse;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => ItemDetailSheet(item: item),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                        // Image
                        FutureBuilder<File?>(
                          future: ImageHelper.getImageFile(item.imagePath),
                          builder: (context, snapshot) {
                            final imageFile = snapshot.data;
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: CupertinoColors.systemGrey6,
                                image: item.imagePath != null && imageFile != null
                                    ? DecorationImage(
                                        image: FileImage(imageFile),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: item.imagePath == null || imageFile == null
                                  ? const Icon(
                                      CupertinoIcons.cube_box,
                                      color: CupertinoColors.systemGrey,
                                      size: 32,
                                    )
                                  : null,
                            );
                          },
                        ),
                        const SizedBox(width: 16),
                        // Layout: Name & Status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  if (item.quantity != null && item.quantity! > 1)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemGrey5,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '×${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: CupertinoColors.systemGrey,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isInUse
                                    ? _formatDate(
                                        item.lastUsedAt ?? DateTime.now(),
                                      )
                                    : 'Stored',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isInUse
                                      ? CupertinoColors.systemRed
                                      : CupertinoColors.activeGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Spacer automatic via Expanded
                        // Toggle
                        CupertinoSwitch(
                          value: !isInUse,
                          onChanged: (val) async {
                            final newStatus = val
                                ? ItemStatus.stored
                                : ItemStatus.inUse;
                            await ref
                                .read(itemRepositoryProvider)
                                .toggleStatus(item.id, newStatus);
                            ref.invalidate(itemsInSpaceProvider(parentId!));
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
                );
              }, childCount: items.length),
            );
          },
          loading: () => const SliverToBoxAdapter(),
          error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _toggleItemStatus(WidgetRef ref, Item item, bool toStore) async {
    final newStatus = toStore ? ItemStatus.stored : ItemStatus.inUse;
    await ref.read(itemRepositoryProvider).toggleStatus(item.id, newStatus);
    if (parentId != null) {
      ref.invalidate(itemsInSpaceProvider(parentId!));
    }
  }
}

class _BreadcrumbItem {
  final String name;
  final String? id;

  _BreadcrumbItem({required this.name, required this.id});
}

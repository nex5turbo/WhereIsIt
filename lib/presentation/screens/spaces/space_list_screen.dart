import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/space.dart';
import '../../providers/item_providers.dart';
import '../items/create_item_dialog.dart';
import '../../../data/repositories/item_repository_impl.dart'; // for provider
import '../../providers/space_providers.dart';
import '../../providers/view_mode_provider.dart';
import 'create_space_dialog.dart';
import 'space_graph_view.dart';

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
        leading: parentId != null
            ? CupertinoNavigationBarBackButton(onPressed: () => context.pop())
            : null,
        middle: breadcrumbsAsync.when(
          data: (crumbs) {
            if (crumbs.isEmpty) return const Text('My Home');
            // Simplified breadcrumb for title area or just show current space name
            return Text(crumbs.isNotEmpty ? crumbs.last.name : 'My Home');
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
                            showCupertinoDialog(
                              context: context,
                              builder: (_) =>
                                  CreateSpaceDialog(parentId: parentId),
                            );
                          },
                          child: const Text('New Folder'),
                        ),
                        CupertinoActionSheetAction(
                          onPressed: () {
                            Navigator.pop(context);
                            showCupertinoDialog(
                              context: context,
                              builder: (_) =>
                                  CreateItemDialog(spaceId: parentId!),
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
                  showCupertinoDialog(
                    context: context,
                    builder: (_) => CreateSpaceDialog(parentId: parentId),
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
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final space = spaces[index];
                  return GestureDetector(
                    onTap: () => context.push('/space/${space.id}'),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemGroupedBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.folder_solid,
                            size: 48,
                            color: CupertinoColors.systemYellow,
                          ),
                          Text(
                            space.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${space.itemCount} items',
                            style: const TextStyle(
                              color: CupertinoColors.systemGrey,
                            ),
                          ),
                        ],
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
                    child: CupertinoListTile(
                      leading: const Icon(
                        CupertinoIcons.folder_solid,
                        color: CupertinoColors.systemYellow,
                      ),
                      title: Text(space.name),
                      subtitle: Text('${space.itemCount} items'),
                      trailing: const Icon(
                        CupertinoIcons.chevron_forward,
                        color: CupertinoColors.systemGrey3,
                      ),
                      onTap: () => context.push('/space/${space.id}'),
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
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  final isInUse = item.status == ItemStatus.inUse;
                  return GestureDetector(
                    onTap: () => _toggleItemStatus(ref, item, isInUse),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isInUse
                            ? CupertinoColors.systemRed.withOpacity(0.1)
                            : CupertinoColors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isInUse
                                ? CupertinoIcons.exclamationmark_circle
                                : CupertinoIcons.check_mark_circled,
                            size: 48,
                            color: isInUse
                                ? CupertinoColors.systemRed
                                : CupertinoColors.systemGreen,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.name,
                            style: TextStyle(
                              decoration: isInUse
                                  ? TextDecoration.lineThrough
                                  : null,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(item.status.label),
                        ],
                      ),
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
                    vertical: 4,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isInUse
                          ? CupertinoColors.destructiveRed.withOpacity(0.1)
                          : CupertinoColors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: CupertinoListTile(
                      leading: Icon(
                        isInUse
                            ? CupertinoIcons.exclamationmark_circle
                            : CupertinoIcons.check_mark_circled,
                        color: isInUse
                            ? CupertinoColors.destructiveRed
                            : CupertinoColors.activeGreen,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration: isInUse
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text(item.status.label),
                      trailing: CupertinoSwitch(
                        value: !isInUse, // "Is Stored" is true
                        onChanged: (val) async {
                          final newStatus = val
                              ? ItemStatus.stored
                              : ItemStatus.inUse;
                          await ref
                              .read(itemRepositoryProvider)
                              .toggleStatus(item.id, newStatus);
                          ref.invalidate(
                            itemsInSpaceProvider(parentId!),
                          ); // refresh
                        },
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

  Future<void> _toggleItemStatus(WidgetRef ref, Item item, bool toStore) async {
    final newStatus = toStore ? ItemStatus.stored : ItemStatus.inUse;
    await ref.read(itemRepositoryProvider).toggleStatus(item.id, newStatus);
    if (parentId != null) {
      ref.invalidate(itemsInSpaceProvider(parentId!));
    }
  }
}

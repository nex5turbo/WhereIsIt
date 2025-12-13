import 'package:flutter/material.dart';
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

    return Scaffold(
      appBar: AppBar(
        leading: parentId != null
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => context.pop(),
              )
            : null,
        title: breadcrumbsAsync.when(
          data: (crumbs) {
            if (crumbs.isEmpty) return const Text('My Home');
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: Text(
                      'Home',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                  ...crumbs.map(
                    (e) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (e.id != parentId) {
                              context.push('/space/${e.id}');
                            }
                          },
                          child: Text(
                            e.name,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          // View Mode Toggle
          SegmentedButton<ViewMode>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: ViewMode.list, icon: Icon(Icons.list)),
              ButtonSegment(value: ViewMode.grid, icon: Icon(Icons.grid_view)),
              ButtonSegment(
                value: ViewMode.graph,
                icon: Icon(Icons.account_tree),
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (Set<ViewMode> newSelection) {
              ref
                  .read(currentViewModeProvider.notifier)
                  .setMode(newSelection.first);
            },
            style: const ButtonStyle(visualDensity: VisualDensity.compact),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: viewMode == ViewMode.graph
          ? SpaceGraphView(rootId: parentId)
          : _buildScrollView(context, ref, viewMode),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_space',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => CreateSpaceDialog(parentId: parentId),
            ),
            child: const Icon(Icons.create_new_folder),
          ),
          const SizedBox(height: 16),
          if (parentId != null)
            FloatingActionButton(
              heroTag: 'add_item',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => CreateItemDialog(spaceId: parentId!),
              ),
              child: const Icon(Icons.add),
            ),
        ],
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
        // Spaces Section
        spacesAsync.when(
          data: (spaces) {
            if (viewMode == ViewMode.grid) {
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final space = spaces[index];
                  return Card(
                    child: InkWell(
                      onTap: () => context.push('/space/${space.id}'),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.folder,
                            size: 48,
                            color: Colors.amber,
                          ),
                          Text(
                            space.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text('${space.itemCount} items'),
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
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.folder, color: Colors.amber),
                    title: Text(space.name),
                    subtitle: Text('${space.itemCount} items inside'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/space/${space.id}'),
                  ),
                );
              }, childCount: spaces.length),
            );
          },
          loading: () =>
              const SliverToBoxAdapter(child: LinearProgressIndicator()),
          error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
        ),

        // Items Section Header
        if (itemsAsync.hasValue && itemsAsync.value!.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Items',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

        // Items List
        itemsAsync.when(
          data: (items) {
            if (viewMode == ViewMode.grid) {
              return SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final item = items[index];
                  final isInUse = item.status == ItemStatus.inUse;
                  return Card(
                    color: isInUse ? Colors.red.shade50 : null,
                    child: InkWell(
                      onTap: () => _toggleItemStatus(ref, item, isInUse),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isInUse
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_outline,
                            size: 48,
                            color: isInUse ? Colors.red : Colors.green,
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
                return Card(
                  color: isInUse ? Colors.red.shade50 : null,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: Icon(
                      isInUse
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      color: isInUse ? Colors.red : Colors.green,
                    ),
                    title: Text(
                      item.name,
                      style: TextStyle(
                        decoration: isInUse ? TextDecoration.lineThrough : null,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(item.status.label),
                    trailing: Switch(
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

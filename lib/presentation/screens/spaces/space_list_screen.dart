import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/space.dart';
import '../../providers/item_providers.dart';
import '../items/create_item_dialog.dart';
import '../../../data/repositories/item_repository_impl.dart'; // for provider
import '../../providers/space_providers.dart';
import 'create_space_dialog.dart';

class SpaceListScreen extends ConsumerWidget {
  final String? parentId;

  const SpaceListScreen({super.key, this.parentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacesAsync = ref.watch(spacesProvider(parentId: parentId));
    final itemsAsync = parentId != null
        ? ref.watch(itemsInSpaceProvider(parentId!))
        : const AsyncValue.data(<Item>[]);

    final breadcrumbsAsync = parentId != null
        ? ref.watch(breadcrumbsProvider(parentId!))
        : const AsyncValue.data(<Space>[]);

    return Scaffold(
      appBar: AppBar(
        title: breadcrumbsAsync.when(
          data: (crumbs) {
            if (crumbs.isEmpty) return const Text('My Home');
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/'),
                    child: const Text(
                      'Home > ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  ...crumbs.map(
                    (e) => GestureDetector(
                      onTap: () {
                        // Basic navigation to that ID. In a real app we might check if it's already in stack.
                        // Using 'go' replaces stack, so push is better for history,
                        // but 'go' to /space/:id works if structured.
                        // Here just pushing for simplicity or could use names.
                        context.push('/space/${e.id}');
                      },
                      child: Text(
                        '${e.name} > ',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const Text(
                    'Here',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            );
          },
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Spaces Section
          spacesAsync.when(
            data: (spaces) => SliverList(
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
            ),
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
            data: (items) => SliverList(
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
                        decoration: isInUse
                            ? TextDecoration.lineThrough
                            : null, // stylistic choice? Or maybe "In Use" should be highlighted.
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
            ),
            loading: () => const SliverToBoxAdapter(),
            error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
          ),
        ],
      ),
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
}

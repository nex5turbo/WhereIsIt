import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphview/GraphView.dart';
import '../../../domain/entities/space.dart';
import '../../../domain/entities/item.dart';
import '../../providers/item_providers.dart';
import '../../providers/space_providers.dart';

class SpaceGraphView extends ConsumerStatefulWidget {
  final String? rootId;
  const SpaceGraphView({super.key, this.rootId});

  @override
  ConsumerState<SpaceGraphView> createState() => _SpaceGraphViewState();
}

class _SpaceGraphViewState extends ConsumerState<SpaceGraphView> {
  final Graph _graph = Graph()..isTree = true;
  late BuchheimWalkerConfiguration _builder;

  @override
  void initState() {
    super.initState();
    _builder = BuchheimWalkerConfiguration()
      ..siblingSeparation = (100)
      ..levelSeparation = (150)
      ..subtreeSeparation = (150)
      ..orientation = (BuchheimWalkerConfiguration.ORIENTATION_TOP_BOTTOM);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Fetch data
    final spacesAsync = ref.watch(spacesProvider(parentId: widget.rootId));
    final itemsAsync = widget.rootId != null
        ? ref.watch(itemsInSpaceProvider(widget.rootId!))
        : const AsyncValue<List<Item>>.data([]);

    return spacesAsync.when(
      data: (spaces) {
        return itemsAsync.when(
          data: (items) {
            _buildGraph(spaces, items);
            if (_graph.nodeCount() == 0) {
              return const Center(child: Text('No elements to display'));
            }
            return InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(100),
              minScale: 0.01,
              maxScale: 5.6,
              child: GraphView(
                graph: _graph,
                algorithm: BuchheimWalkerAlgorithm(
                  _builder,
                  TreeEdgeRenderer(_builder),
                ),
                paint: Paint()
                  ..color = Colors.green
                  ..strokeWidth = 1
                  ..style = PaintingStyle.stroke,
                builder: (Node node) {
                  final id = node.key!.value.toString();
                  return _buildNodeWidget(id, spaces, items);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Text('Error: $e'),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, s) => Text('Error: $e'),
    );
  }

  void _buildGraph(List<Space> spaces, List<Item> items) {
    _graph.nodes.clear();
    _graph.edges.clear();

    final rootNode = Node.Id(widget.rootId ?? 'root');
    // Only add root if we are inside a space, effectively "Current Space"
    if (widget.rootId != null) {
      _graph.addNode(rootNode);
    }

    // Add Spaces
    for (var space in spaces) {
      final spaceNode = Node.Id(space.id);
      _graph.addNode(spaceNode);
      if (widget.rootId != null) {
        _graph.addEdge(rootNode, spaceNode);
      }
    }

    // Add Items
    for (var item in items) {
      final itemNode = Node.Id(item.id);
      _graph.addNode(itemNode);
      if (widget.rootId != null) {
        _graph.addEdge(rootNode, itemNode);
      }
    }
  }

  Widget _buildNodeWidget(String id, List<Space> spaces, List<Item> items) {
    if (id == widget.rootId) {
      return _rectangleWidget('Current Space', Colors.blue.shade100);
    }

    final space = spaces.where((e) => e.id == id).firstOrNull;
    if (space != null) {
      return _rectangleWidget(space.name, Colors.amber.shade100);
    }

    final item = items.where((e) => e.id == id).firstOrNull;
    if (item != null) {
      return _rectangleWidget(item.name, Colors.white, isItem: true);
    }

    return _rectangleWidget('Unknown', Colors.grey);
  }

  Widget _rectangleWidget(String a, Color bgColor, {bool isItem = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, spreadRadius: 1)],
        color: bgColor,
        border: isItem ? Border.all(color: Colors.grey.shade300) : null,
      ),
      child: Column(
        children: [
          Icon(
            isItem ? Icons.inventory_2_outlined : Icons.folder_outlined,
            size: 20,
            color: isItem ? Colors.grey : Colors.amber.shade800,
          ),
          const SizedBox(height: 4),
          Text(
            a,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

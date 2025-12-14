import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/item.dart';
import '../../domain/entities/space.dart';

// Represents what is being dragged
class DragState {
  final bool isDragging;
  final Item? draggingItem;
  final Space? draggingSpace;

  const DragState({
    this.isDragging = false,
    this.draggingItem,
    this.draggingSpace,
  });

  DragState copyWith({
    bool? isDragging,
    Item? draggingItem,
    Space? draggingSpace,
  }) {
    return DragState(
      isDragging: isDragging ?? this.isDragging,
      draggingItem: draggingItem ?? this.draggingItem,
      draggingSpace: draggingSpace ?? this.draggingSpace,
    );
  }
}

class DragStateNotifier extends Notifier<DragState> {
  @override
  DragState build() {
    return const DragState();
  }

  void startDraggingItem(Item item) {
    state = state.copyWith(isDragging: true, draggingItem: item, draggingSpace: null);
  }

  void startDraggingSpace(Space space) {
    state = state.copyWith(isDragging: true, draggingSpace: space, draggingItem: null);
  }

  void stopDragging() {
    state = const DragState(isDragging: false);
  }
}

final dragStateProvider = NotifierProvider<DragStateNotifier, DragState>(DragStateNotifier.new);

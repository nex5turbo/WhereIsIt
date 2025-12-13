import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'view_mode_provider.g.dart';

enum ViewMode { list, grid, graph }

@riverpod
class CurrentViewMode extends _$CurrentViewMode {
  @override
  ViewMode build() {
    return ViewMode.list;
  }

  void setMode(ViewMode mode) {
    state = mode;
  }
}

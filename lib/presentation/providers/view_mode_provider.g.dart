// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'view_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CurrentViewMode)
const currentViewModeProvider = CurrentViewModeProvider._();

final class CurrentViewModeProvider
    extends $NotifierProvider<CurrentViewMode, ViewMode> {
  const CurrentViewModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentViewModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentViewModeHash();

  @$internal
  @override
  CurrentViewMode create() => CurrentViewMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ViewMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ViewMode>(value),
    );
  }
}

String _$currentViewModeHash() => r'ff7638bf2c131b4b5c28358204499bec8b073864';

abstract class _$CurrentViewMode extends $Notifier<ViewMode> {
  ViewMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<ViewMode, ViewMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ViewMode, ViewMode>,
              ViewMode,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

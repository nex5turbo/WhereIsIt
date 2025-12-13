// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(spaces)
const spacesProvider = SpacesFamily._();

final class SpacesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Space>>,
          List<Space>,
          FutureOr<List<Space>>
        >
    with $FutureModifier<List<Space>>, $FutureProvider<List<Space>> {
  const SpacesProvider._({
    required SpacesFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'spacesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$spacesHash();

  @override
  String toString() {
    return r'spacesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Space>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Space>> create(Ref ref) {
    final argument = this.argument as String?;
    return spaces(ref, parentId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SpacesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$spacesHash() => r'a780a2a03ae5779a8d06895cd48cb10be22928af';

final class SpacesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Space>>, String?> {
  const SpacesFamily._()
    : super(
        retry: null,
        name: r'spacesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SpacesProvider call({String? parentId}) =>
      SpacesProvider._(argument: parentId, from: this);

  @override
  String toString() => r'spacesProvider';
}

@ProviderFor(breadcrumbs)
const breadcrumbsProvider = BreadcrumbsFamily._();

final class BreadcrumbsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Space>>,
          List<Space>,
          FutureOr<List<Space>>
        >
    with $FutureModifier<List<Space>>, $FutureProvider<List<Space>> {
  const BreadcrumbsProvider._({
    required BreadcrumbsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'breadcrumbsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$breadcrumbsHash();

  @override
  String toString() {
    return r'breadcrumbsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Space>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Space>> create(Ref ref) {
    final argument = this.argument as String;
    return breadcrumbs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BreadcrumbsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$breadcrumbsHash() => r'2ea032d45f2b25c44aee413324ab7afb3f905b51';

final class BreadcrumbsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Space>>, String> {
  const BreadcrumbsFamily._()
    : super(
        retry: null,
        name: r'breadcrumbsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  BreadcrumbsProvider call(String spaceId) =>
      BreadcrumbsProvider._(argument: spaceId, from: this);

  @override
  String toString() => r'breadcrumbsProvider';
}

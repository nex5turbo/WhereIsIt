// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(itemsInSpace)
const itemsInSpaceProvider = ItemsInSpaceFamily._();

final class ItemsInSpaceProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          Stream<List<Item>>
        >
    with $FutureModifier<List<Item>>, $StreamProvider<List<Item>> {
  const ItemsInSpaceProvider._({
    required ItemsInSpaceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'itemsInSpaceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$itemsInSpaceHash();

  @override
  String toString() {
    return r'itemsInSpaceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Item>> create(Ref ref) {
    final argument = this.argument as String;
    return itemsInSpace(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ItemsInSpaceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$itemsInSpaceHash() => r'0c7ac7b3d2ae55d927c5f6b9ae0111f6a819883c';

final class ItemsInSpaceFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Item>>, String> {
  const ItemsInSpaceFamily._()
    : super(
        retry: null,
        name: r'itemsInSpaceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ItemsInSpaceProvider call(String spaceId) =>
      ItemsInSpaceProvider._(argument: spaceId, from: this);

  @override
  String toString() => r'itemsInSpaceProvider';
}

@ProviderFor(allInUseItems)
const allInUseItemsProvider = AllInUseItemsProvider._();

final class AllInUseItemsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Item>>,
          List<Item>,
          Stream<List<Item>>
        >
    with $FutureModifier<List<Item>>, $StreamProvider<List<Item>> {
  const AllInUseItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allInUseItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allInUseItemsHash();

  @$internal
  @override
  $StreamProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Item>> create(Ref ref) {
    return allInUseItems(ref);
  }
}

String _$allInUseItemsHash() => r'4db47fb927052b81c6bb56c7da5c873cebbfb500';

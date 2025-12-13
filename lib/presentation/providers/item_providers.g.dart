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
          FutureOr<List<Item>>
        >
    with $FutureModifier<List<Item>>, $FutureProvider<List<Item>> {
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
  $FutureProviderElement<List<Item>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Item>> create(Ref ref) {
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

String _$itemsInSpaceHash() => r'8a5d4bc37dfc5b422c4aaa14fabd597a8fa26a91';

final class ItemsInSpaceFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Item>>, String> {
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(itemRepository)
const itemRepositoryProvider = ItemRepositoryProvider._();

final class ItemRepositoryProvider
    extends $FunctionalProvider<ItemRepository, ItemRepository, ItemRepository>
    with $Provider<ItemRepository> {
  const ItemRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'itemRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$itemRepositoryHash();

  @$internal
  @override
  $ProviderElement<ItemRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ItemRepository create(Ref ref) {
    return itemRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ItemRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ItemRepository>(value),
    );
  }
}

String _$itemRepositoryHash() => r'2740816a163130dd2b8bb162df51e5ecdc17b673';

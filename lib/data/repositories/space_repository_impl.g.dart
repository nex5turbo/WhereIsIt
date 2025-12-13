// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'space_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appDatabase)
const appDatabaseProvider = AppDatabaseProvider._();

final class AppDatabaseProvider
    extends $FunctionalProvider<db.AppDatabase, db.AppDatabase, db.AppDatabase>
    with $Provider<db.AppDatabase> {
  const AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<db.AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  db.AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(db.AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<db.AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'82be8e5ef038b1bb8599a73f500ae949d1a69f75';

@ProviderFor(spaceRepository)
const spaceRepositoryProvider = SpaceRepositoryProvider._();

final class SpaceRepositoryProvider
    extends
        $FunctionalProvider<SpaceRepository, SpaceRepository, SpaceRepository>
    with $Provider<SpaceRepository> {
  const SpaceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'spaceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$spaceRepositoryHash();

  @$internal
  @override
  $ProviderElement<SpaceRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SpaceRepository create(Ref ref) {
    return spaceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpaceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpaceRepository>(value),
    );
  }
}

String _$spaceRepositoryHash() => r'b5cb6c2d6d3c3d95617f9e11436b487347fc1858';

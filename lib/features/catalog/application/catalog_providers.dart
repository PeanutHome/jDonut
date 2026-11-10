import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/result.dart';
import '../../../core/network/reachability.dart';
import '../data/catalog_database.dart';
import '../data/local_catalog_repository.dart';
import '../domain/catalog_models.dart';
import '../domain/repositories/catalog_repository.dart';

final catalogDatabaseProvider = Provider<CatalogDatabase>((ref) {
  throw StateError('CatalogDatabase not initialized — call bootstrap()');
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return LocalCatalogRepository(ref.watch(catalogDatabaseProvider));
});

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

/// Link state from connectivity_plus (may be captive / no real internet).
final isOfflineProvider = Provider<bool>((ref) {
  final net = ref.watch(connectivityProvider).maybeWhen(
        data: (r) => r,
        orElse: () => null,
      );
  if (net == null) return false;
  return net.every((r) => r == ConnectivityResult.none);
});

/// Real reachability probe (DNS lookup) — refreshed with connectivity changes.
final hasReachabilityProvider = FutureProvider<bool>((ref) async {
  ref.watch(connectivityProvider);
  return hasInternetReachability();
});

final homeCatalogProvider =
    AsyncNotifierProvider<HomeCatalogNotifier, HomeCatalog>(HomeCatalogNotifier.new);

class HomeCatalogNotifier extends AsyncNotifier<HomeCatalog> {
  @override
  Future<HomeCatalog> build() async {
    final result = await ref.watch(catalogRepositoryProvider).loadHome();
    return result.when(
      ok: (v) => v,
      err: (f) => throw Exception(f.message),
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() async {
      final result = await ref.read(catalogRepositoryProvider).refresh();
      return result.when(
        ok: (v) => v,
        err: (f) => throw Exception(f.message),
      );
    });
  }
}

final memberProvider = Provider<CatalogMember?>((ref) {
  return ref.watch(homeCatalogProvider).value?.member;
});

final challengesProvider = Provider<List<CatalogChallenge>>((ref) {
  return ref.watch(homeCatalogProvider).value?.challenges ?? const [];
});

final productProvider =
    FutureProvider.family<CatalogProduct?, String>((ref, id) async {
  final result = await ref.watch(catalogRepositoryProvider).productById(id);
  return switch (result) {
    Ok(:final value) => value,
    Err(:final failure) => throw Exception(failure.message),
  };
});

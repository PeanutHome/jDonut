import '../../../../core/domain/result.dart';
import '../catalog_models.dart';

/// Offline-first catalog contract — UI talks to this, not sqflite.
abstract class CatalogRepository {
  Future<Result<HomeCatalog>> loadHome();

  Future<Result<CatalogProduct?>> productById(String id);

  Future<Result<HomeCatalog>> refresh();

  Future<Result<List<CatalogChallenge>>> loadChallenges();
}

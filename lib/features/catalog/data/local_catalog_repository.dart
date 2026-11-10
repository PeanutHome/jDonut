import '../../../core/domain/app_failure.dart';
import '../../../core/domain/result.dart';
import '../domain/catalog_models.dart';
import '../domain/repositories/catalog_repository.dart';
import 'catalog_database.dart';

class LocalCatalogRepository implements CatalogRepository {
  LocalCatalogRepository(this._db);

  final CatalogDatabase _db;

  @override
  Future<Result<HomeCatalog>> loadHome() async {
    try {
      await _db.ensureSeeded();
      return Ok(await _db.loadHome());
    } catch (e) {
      return Err(CacheFailure('Could not load catalog: $e'));
    }
  }

  @override
  Future<Result<CatalogProduct?>> productById(String id) async {
    try {
      await _db.ensureSeeded();
      return Ok(await _db.productById(id));
    } catch (e) {
      return Err(CacheFailure('Could not load product: $e'));
    }
  }

  @override
  Future<Result<HomeCatalog>> refresh() async {
    try {
      await _db.replaceFromSeedAsset();
      return Ok(await _db.loadHome());
    } catch (e) {
      return Err(CacheFailure('Could not refresh catalog: $e'));
    }
  }

  @override
  Future<Result<List<CatalogChallenge>>> loadChallenges() async {
    try {
      await _db.ensureSeeded();
      return Ok(await _db.loadChallenges());
    } catch (e) {
      return Err(CacheFailure('Could not load challenges: $e'));
    }
  }
}

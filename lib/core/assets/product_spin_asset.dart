import '../../features/catalog/domain/catalog_models.dart';

const _boxIds = {
  'p_mistletoe',
  'p_sweet_box',
  'p_mini_family',
  'p_santa_cookies',
  'p_santa_coffee',
};

/// True for Donuts tab list (no boxes / bundles).
bool isSingleDonutProduct(CatalogProduct product) {
  if (_boxIds.contains(product.id)) return false;
  final name = product.name.toLowerCase();
  if (name.contains('box') || name.contains('set')) return false;
  return true;
}

/// Transparent PNG cutouts for spinning hero (pink page shows through).
String productSpinAsset(CatalogProduct product) {
  if (!isSingleDonutProduct(product)) {
    return 'assets/images/products/cutout_coconut.png';
  }
  return switch (product.id) {
    'p_coconut' => 'assets/images/products/cutout_coconut.png',
    'p_strawberry' => 'assets/images/products/cutout_strawberry.png',
    'p_coffee' => 'assets/images/products/cutout_coffee.png',
    _ => 'assets/images/products/cutout_coconut.png',
  };
}

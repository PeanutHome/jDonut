import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/widgets/jd_catalog_image.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/catalog_models.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  static const routePath = '/shop';
  static const routeName = 'shop';

  static const _bg = Color(0xFFF0F2F3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(homeCatalogProvider);

    return ColoredBox(
      color: _bg,
      child: SafeArea(
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Shop unavailable\n$e', textAlign: TextAlign.center)),
          data: (data) {
            final products = data.productsById.values.toList();
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
                    child: Text(
                      'Shop',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF29323A)),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 24),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _ShopProductTile(product: products[i]),
                      childCount: products.length,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ShopProductTile extends StatelessWidget {
  const _ShopProductTile({required this.product});

  final CatalogProduct product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.productDetailPath(product.id, from: AppRoutes.shop),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: JdCatalogImage(
                  asset: product.imageAsset,
                  url: product.imageUrl,
                  preferAsset: true,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                '${product.priceMmk} MMK',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7780)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

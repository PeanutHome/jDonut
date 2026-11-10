import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/product_spin_asset.dart';
import '../../../core/format/mmk_format.dart';
import '../../../core/motion/jd_motion.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/jd_catalog_image.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../shell/presentation/jd_bottom_nav.dart';

/// Donuts tab — buy grid (same tile pattern as early shop grid).
class DonutsScreen extends ConsumerWidget {
  const DonutsScreen({super.key});

  static const routePath = '/donuts';
  static const routeName = 'donuts';

  static const _bg = Color(0xFFF0F2F3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(homeCatalogProvider);
    final bottom = JdBottomNav.heightFor(context);

    return ColoredBox(
      color: _bg,
      child: SafeArea(
        child: catalog.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Could not load menu\n$e', textAlign: TextAlign.center)),
          data: (data) {
            final products = _donutMenu(data);

            return RefreshIndicator(
              onRefresh: () => ref.read(homeCatalogProvider.notifier).refresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Donuts',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF29323A)),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Pick a flavour and order.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(14, 8, 14, bottom + 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _DonutTile(product: products[i]),
                        childCount: products.length,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<CatalogProduct> _donutMenu(HomeCatalog data) {
    final ids = <String>{};
    final out = <CatalogProduct>[];

    for (final section in data.sections) {
      if (section.id == 'popular' || section.id.startsWith('seasonal')) {
        for (final p in data.productsFor(section)) {
          if (!isSingleDonutProduct(p)) continue;
          if (ids.add(p.id)) out.add(p);
        }
      }
    }

    if (out.isNotEmpty) return out;
    return data.productsById.values.where(isSingleDonutProduct).toList();
  }
}

class _DonutTile extends StatelessWidget {
  const _DonutTile({required this.product});

  final CatalogProduct product;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push(
          AppRoutes.productDetailPath(product.id, from: AppRoutes.donuts),
          extra: JdMotion.productHeroTag(product.id, scope: 'donuts'),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Hero(
                    tag: JdMotion.productHeroTag(product.id, scope: 'donuts'),
                    child: Material(
                      type: MaterialType.transparency,
                      child: JdCatalogImage(
                        asset: product.imageAsset,
                        url: product.imageUrl,
                        preferAsset: true,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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
                '${formatMmk(product.priceMmk)} MMK',
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7780)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

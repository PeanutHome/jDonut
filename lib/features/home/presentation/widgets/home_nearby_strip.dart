import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jd_catalog_image.dart';
import '../../../catalog/domain/catalog_models.dart';

class HomeNearbyStrip extends StatelessWidget {
  const HomeNearbyStrip({required this.shops, super.key});

  final List<CatalogShop> shops;

  static const _pink = AppColors.pink;
  static const _sky = AppColors.cyan;
  static const _shopRowHeight = 200.0;

  /// Title + CTA + shop row — Home adds nav overlap so the scene fills to the bar.
  static const contentHeight = 310.0;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/nearby_scene_bg.jpg',
              fit: BoxFit.cover,
              alignment: const Alignment(0, -0.15),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 90,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _sky.withValues(alpha: 0.55),
                    _sky.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 0, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'There are ${shops.length} J’Donut shops\nnear you. 🥰',
                  style: const TextStyle(
                    color: AppColors.onAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                    shadows: [Shadow(color: AppColors.shadow, blurRadius: 8)],
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                      child: Text(
                        'EXPLORE NOW',
                        style: TextStyle(color: _sky, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: _shopRowHeight,
                  child: shops.isEmpty
                      ? const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No shops nearby',
                            style: TextStyle(color: AppColors.onAccent),
                          ),
                        )
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.only(right: 18),
                          itemCount: shops.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (_, i) => SizedBox(
                            height: _shopRowHeight,
                            child: _ShopCard(shop: shops[i]),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({required this.shop});

  final CatalogShop shop;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: JdCatalogImage(
                  asset: shop.imageAsset,
                  url: shop.imageUrl,
                  preferAsset: true,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      shop.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      shop.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 9,
                        color: AppColors.textSecondary,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Order Online',
                      style: TextStyle(
                        color: HomeNearbyStrip._pink,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

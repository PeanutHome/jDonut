import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/motion/jd_motion.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jd_catalog_image.dart';
import '../../../catalog/domain/catalog_models.dart';

enum HomeProductCardStyle {
  /// PDF seasonal — photo is the tile; name below.
  filled,
  /// PDF popular — white tile, photo inset.
  inset,
}


class HomeProductStrip extends StatelessWidget {
  const HomeProductStrip({
    super.key,
    required this.title,
    required this.products,
    this.heroScope = 'home',
    this.style = HomeProductCardStyle.filled,
    this.error,
    this.onRetry,
  });

  final String title;
  final List<CatalogProduct> products;
  final String heroScope;
  final HomeProductCardStyle style;
  final String? error;
  final VoidCallback? onRetry;

  static const _cardWidth = 148.0;
  static const _filledAspect = 0.92;
  static const _insetAspect = 0.92;
  static const _titleBlockHeight = 36.0;
  static const _gapBelowImage = 7.0;

  double get _stripHeight {
    final aspect = style == HomeProductCardStyle.filled ? _filledAspect : _insetAspect;
    return _cardWidth / aspect + _gapBelowImage + _titleBlockHeight;
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(AppColors.pad, 15, AppColors.pad, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(error!, style: const TextStyle(color: AppColors.danger)),
            if (onRetry != null)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(AppColors.pad, 15, AppColors.pad, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppColors.radius),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Nothing here yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 15, 18, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.surface,
                child: Icon(Icons.chevron_right, size: 20, color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _stripHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final product = products[i];
              return style == HomeProductCardStyle.filled
                  ? _FilledProductCard(
                      product: product,
                      heroScope: heroScope,
                      width: _cardWidth,
                      aspect: _filledAspect,
                      titleHeight: _titleBlockHeight,
                      gapBelowImage: _gapBelowImage,
                    )
                  : _InsetProductCard(
                      product: product,
                      heroScope: heroScope,
                      width: _cardWidth,
                      aspect: _insetAspect,
                      titleHeight: _titleBlockHeight,
                      gapBelowImage: _gapBelowImage,
                    );
            },
          ),
        ),
      ],
    );
  }
}

/// Seasonal — image edge-to-edge; discount inside; title under (PDF p.8).
class _FilledProductCard extends StatelessWidget {
  const _FilledProductCard({
    required this.product,
    required this.heroScope,
    required this.width,
    required this.aspect,
    required this.titleHeight,
    required this.gapBelowImage,
  });

  final CatalogProduct product;
  final String heroScope;
  final double width;
  final double aspect;
  final double titleHeight;
  final double gapBelowImage;

  static const _cardBg = AppColors.seasonalCard;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: aspect,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Material(
                color: _cardBg,
                child: InkWell(
                  onTap: () => context.push(
                    AppRoutes.productDetailPath(product.id, from: AppRoutes.home),
                    extra: JdMotion.productHeroTag(product.id, scope: heroScope),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned.fill(
                        child: Hero(
                          tag: JdMotion.productHeroTag(product.id, scope: heroScope),
                          createRectTween: (begin, end) =>
                              MaterialRectArcTween(begin: begin, end: end),
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
                      if (discount != null)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.discount,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              child: Text(
                                '$discount% off',
                                style: const TextStyle(
                                  color: AppColors.surface,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: gapBelowImage),
          SizedBox(
            height: titleHeight,
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.25,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Popular / order again — white card, centered product (PDF p.8).
class _InsetProductCard extends StatelessWidget {
  const _InsetProductCard({
    required this.product,
    required this.heroScope,
    required this.width,
    required this.aspect,
    required this.titleHeight,
    required this.gapBelowImage,
  });

  final CatalogProduct product;
  final String heroScope;
  final double width;
  final double aspect;
  final double titleHeight;
  final double gapBelowImage;

  @override
  Widget build(BuildContext context) {
    final discount = product.discountPercent;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: aspect,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Material(
                color: Colors.white,
                child: InkWell(
                  onTap: () => context.push(
                    AppRoutes.productDetailPath(product.id, from: AppRoutes.home),
                    extra: JdMotion.productHeroTag(product.id, scope: heroScope),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Center(
                            child: Hero(
                              tag: JdMotion.productHeroTag(product.id, scope: heroScope),
                              createRectTween: (begin, end) =>
                                  MaterialRectArcTween(begin: begin, end: end),
                              child: Material(
                                type: MaterialType.transparency,
                                child: JdCatalogImage(
                                  asset: product.imageAsset,
                                  url: product.imageUrl,
                                  preferAsset: true,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (discount != null)
                        Positioned(
                          right: 8,
                          bottom: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.discount,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              child: Text(
                                '$discount% off',
                                style: const TextStyle(
                                  color: AppColors.surface,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: gapBelowImage),
          SizedBox(
            height: titleHeight,
            child: Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.25,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

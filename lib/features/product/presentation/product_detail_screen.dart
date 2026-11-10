import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/mmk_format.dart';
import '../../../core/motion/jd_motion.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/jd_skeleton.dart';
import '../../../l10n/app_localizations.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/catalog_models.dart';
import 'widgets/product_hero_image.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.heroTag,
  });

  final String productId;
  final String? heroTag;

  static const routeName = 'product-detail';

  static const _cyan = AppColors.cyan;
  static const _titleColor = AppColors.textPrimary;

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  int _qty = 1;

  /// Prefer home-cache so destination Hero exists on the first push frame.
  CatalogProduct? _resolveProduct(AsyncValue<CatalogProduct?> async) {
    final cached =
        ref.watch(homeCatalogProvider).asData?.value.productsById[widget.productId];
    return async.asData?.value ?? cached;
  }

  String get _heroTag =>
      widget.heroTag ?? JdMotion.productHeroTag(widget.productId, scope: 'detail');

  static const _titleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: ProductDetailScreen._titleColor,
    height: 1.2,
  );

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productProvider(widget.productId));
    final product = _resolveProduct(productAsync);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.pageBg,
      appBar: AppBar(
        backgroundColor: AppColors.pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(
          color: ProductDetailScreen._titleColor,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: product == null
          ? _loadingOrError(productAsync, l10n)
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppColors.pad,
                0,
                AppColors.pad,
                AppColors.pad,
              ),
              children: [
                _ProductCard(
                  product: product,
                  heroTag: _heroTag,
                  qty: _qty,
                  onQty: (v) => setState(() => _qty = v),
                  titleStyle: _titleStyle,
                  l10n: l10n,
                ),
                const SizedBox(height: 18),
                _WhatsThis(description: product.description, l10n: l10n),
                const SizedBox(height: 88),
              ],
            ),
      bottomNavigationBar: product == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppColors.pad,
                  0,
                  AppColors.pad,
                  12,
                ),
                child: SizedBox(
                  height: AppColors.buttonHeight,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.addedToCart)),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: ProductDetailScreen._cyan,
                      foregroundColor: AppColors.onAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Text(
                      '${l10n.addToCart}  |  ${l10n.mmkPrice(formatMmk(_qty * product.priceMmk))}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _loadingOrError(
    AsyncValue<CatalogProduct?> productAsync,
    AppLocalizations l10n,
  ) {
    return productAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AppColors.pad),
        child: Column(
          children: [
            JdSkeleton(height: 320, radius: AppColors.radiusLg),
            SizedBox(height: 16),
            JdSkeleton(height: 20, width: 200),
          ],
        ),
      ),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${l10n.productNotFound}\n$e'),
            TextButton(
              onPressed: () =>
                  ref.invalidate(productProvider(widget.productId)),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
      data: (_) => Center(child: Text(l10n.productNotFound)),
    );
  }
}

/// White card: row [code … badge] → name → price → image → qty.
class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.heroTag,
    required this.qty,
    required this.onQty,
    required this.titleStyle,
    required this.l10n,
  });

  final CatalogProduct product;
  final String heroTag;
  final int qty;
  final ValueChanged<int> onQty;
  final TextStyle titleStyle;
  final AppLocalizations l10n;

  String? get _endBadge {
    if (product.discountPercent != null) {
      return l10n.percentOff(product.discountPercent!);
    }
    if (product.isNew) return l10n.newBadge;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final badge = _endBadge;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppColors.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    product.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: product.discountPercent != null
                          ? AppColors.discount
                          : AppColors.accentOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: AppColors.onAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(product.name, style: titleStyle),
            const SizedBox(height: 6),
            Text(l10n.mmkPrice(formatMmk(product.priceMmk)), style: titleStyle),
            const SizedBox(height: 12),
            Center(
              child: Hero(
                tag: heroTag,
                createRectTween: (begin, end) =>
                    MaterialRectArcTween(begin: begin, end: end),
                child: Material(
                  type: MaterialType.transparency,
                  child: ProductHeroImage(
                    asset: product.imageAsset,
                    url: product.imageUrl,
                    size: 240,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Center(child: _QtyPill(qty: qty, onQty: onQty)),
          ],
        ),
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  const _QtyPill({required this.qty, required this.onQty});

  final int qty;
  final ValueChanged<int> onQty;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.track,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _qtyBtn(Icons.remove, () {
              if (qty > 1) onQty(qty - 1);
            }),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: AnimatedSwitcher(
                duration: JdMotion.reduced(context, JdMotion.qtyChange),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Text(
                  '$qty',
                  key: ValueKey<int>(qty),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: ProductDetailScreen._titleColor,
                  ),
                ),
              ),
            ),
            _qtyBtn(Icons.add, () => onQty(qty + 1)),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return Material(
      color: ProductDetailScreen._cyan,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: AppColors.onAccent, size: 18),
        ),
      ),
    );
  }
}

class _WhatsThis extends StatelessWidget {
  const _WhatsThis({required this.description, required this.l10n});

  final String description;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: AppColors.helpGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: AppColors.onAccent,
                  size: 20,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.whatsThisShort,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: ProductDetailScreen._titleColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 1,
          height: 72,
          margin: const EdgeInsets.only(right: 14),
          color: AppColors.border,
        ),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

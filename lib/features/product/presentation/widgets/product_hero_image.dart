import 'package:flutter/material.dart';

import '../../../../core/widgets/jd_catalog_image.dart';

/// Static product art for Hero flights (no spin — boxes look wrong rotating).
class ProductHeroImage extends StatelessWidget {
  const ProductHeroImage({
    super.key,
    required this.asset,
    this.url,
    this.size = 240,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final String? url;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: JdCatalogImage(
        asset: asset,
        url: url,
        preferAsset: true,
        fit: fit,
        width: size,
        height: size,
      ),
    );
  }
}

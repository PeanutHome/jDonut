import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Asset first; optional URL uses disk cache with asset placeholder + error fallback.
class JdCatalogImage extends StatelessWidget {
  const JdCatalogImage({
    super.key,
    required this.asset,
    this.url,
    this.fit = BoxFit.contain,
    this.height,
    this.width,
    this.preferAsset = false,
  });

  final String asset;
  final String? url;
  final BoxFit fit;
  final double? height;
  final double? width;

  /// Home product art uses bundled donut/box shots — skip remote placeholders.
  final bool preferAsset;

  @override
  Widget build(BuildContext context) {
    Widget placeholder = Image.asset(
      asset,
      fit: fit,
      height: height,
      width: width,
      errorBuilder: (_, _, _) => _fallback(),
    );

    final localUrl = url;
    if (preferAsset || localUrl == null || localUrl.isEmpty) {
      return _bound(placeholder);
    }

    final remote = CachedNetworkImage(
      imageUrl: localUrl,
      fit: fit,
      height: height,
      width: width,
      placeholder: (_, _) => placeholder,
      errorWidget: (_, _, _) => placeholder,
    );

    return _bound(remote);
  }

  Widget _bound(Widget child) {
    if (width != null && height != null) {
      return SizedBox(width: width, height: height, child: child);
    }
    if (fit == BoxFit.cover) {
      return SizedBox.expand(child: child);
    }
    return child;
  }

  Widget _fallback() => SizedBox(
        height: height,
        width: width,
        child: const Icon(Icons.bakery_dining, color: Colors.orange, size: 48),
      );
}

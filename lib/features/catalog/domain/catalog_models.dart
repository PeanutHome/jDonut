/// Immutable catalog models (Dart 3 final classes — no freezed codegen).
final class CatalogMember {
  const CatalogMember({
    required this.displayName,
    required this.tier,
    required this.nextTier,
    required this.pointsToNextTier,
    required this.totalPoints,
    required this.notificationCount,
    required this.avatarAsset,
  });

  final String displayName;
  final String tier;
  final String nextTier;
  final int pointsToNextTier;
  final int totalPoints;
  final int notificationCount;
  final String avatarAsset;

  factory CatalogMember.fromJson(Map<String, dynamic> j) => CatalogMember(
        displayName: j['displayName'] as String,
        tier: j['tier'] as String,
        nextTier: j['nextTier'] as String,
        pointsToNextTier: j['pointsToNextTier'] as int,
        totalPoints: j['totalPoints'] as int,
        notificationCount: j['notificationCount'] as int,
        avatarAsset: j['avatarAsset'] as String,
      );
}

final class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.code,
    required this.name,
    required this.priceMmk,
    required this.isNew,
    required this.discountPercent,
    required this.imageAsset,
    required this.imageUrl,
    required this.description,
  });

  final String id;
  final String code;
  final String name;
  final int priceMmk;
  final bool isNew;
  final int? discountPercent;
  final String imageAsset;
  final String? imageUrl;
  final String description;

  String? get discountLabel =>
      discountPercent != null ? '$discountPercent% off' : null;

  factory CatalogProduct.fromJson(Map<String, dynamic> j) => CatalogProduct(
        id: j['id'] as String,
        code: j['code'] as String,
        name: j['name'] as String,
        priceMmk: j['priceMmk'] as int,
        isNew: j['isNew'] as bool,
        discountPercent: j['discountPercent'] as int?,
        imageAsset: j['imageAsset'] as String,
        imageUrl: j['imageUrl'] as String?,
        description: j['description'] as String,
      );
}

final class CatalogBanner {
  const CatalogBanner({
    required this.id,
    required this.eyebrow,
    required this.title,
    required this.badge,
    required this.imageAsset,
    required this.imageUrl,
    required this.backgroundColor,
    required this.accentColor,
  });

  final String id;
  final String eyebrow;
  final String title;
  final String badge;
  final String imageAsset;
  final String? imageUrl;
  final String backgroundColor;
  final String accentColor;

  factory CatalogBanner.fromJson(Map<String, dynamic> j) => CatalogBanner(
        id: j['id'] as String,
        eyebrow: j['eyebrow'] as String,
        title: j['title'] as String,
        badge: j['badge'] as String,
        imageAsset: j['imageAsset'] as String,
        imageUrl: j['imageUrl'] as String?,
        backgroundColor: j['backgroundColor'] as String,
        accentColor: (j['accentColor'] as String?) ?? '#6E8FDB',
      );
}

final class CatalogSection {
  const CatalogSection({
    required this.id,
    required this.title,
    required this.productIds,
  });

  final String id;
  final String title;
  final List<String> productIds;

  factory CatalogSection.fromJson(Map<String, dynamic> j) => CatalogSection(
        id: j['id'] as String,
        title: j['title'] as String,
        productIds: (j['productIds'] as List).cast<String>(),
      );
}

final class CatalogShop {
  const CatalogShop({
    required this.id,
    required this.name,
    required this.address,
    required this.imageAsset,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String address;
  final String imageAsset;
  final String? imageUrl;

  factory CatalogShop.fromJson(Map<String, dynamic> j) => CatalogShop(
        id: j['id'] as String,
        name: j['name'] as String,
        address: j['address'] as String,
        imageAsset: j['imageAsset'] as String,
        imageUrl: j['imageUrl'] as String?,
      );
}

final class CatalogChallenge {
  const CatalogChallenge({
    required this.id,
    required this.title,
    required this.current,
    required this.total,
    required this.points,
    required this.imageAsset,
    required this.buttonLabel,
    required this.kind,
  });

  final String id;
  final String title;
  final int current;
  final int total;
  final int points;
  final String imageAsset;
  final String buttonLabel;
  /// `pieces` (donut quarters) or `arc` (coffee cups).
  final String kind;

  bool get isComplete => current >= total && total > 0;
  String get progressLabel => '$current/$total';
  double get progressFraction => total <= 0 ? 0 : (current / total).clamp(0, 1);

  factory CatalogChallenge.fromJson(Map<String, dynamic> j) => CatalogChallenge(
        id: j['id'] as String,
        title: j['title'] as String,
        current: j['current'] as int,
        total: j['total'] as int,
        points: j['points'] as int,
        imageAsset: j['imageAsset'] as String,
        buttonLabel: (j['buttonLabel'] as String?) ?? 'EARN',
        kind: (j['kind'] as String?) ?? 'pieces',
      );
}

final class HomeCatalog {
  const HomeCatalog({
    required this.member,
    required this.banners,
    required this.sections,
    required this.productsById,
    required this.shops,
    this.challenges = const [],
  });

  final CatalogMember member;
  final List<CatalogBanner> banners;
  final List<CatalogSection> sections;
  final Map<String, CatalogProduct> productsById;
  final List<CatalogShop> shops;
  final List<CatalogChallenge> challenges;

  List<CatalogProduct> productsFor(CatalogSection section) => [
        for (final id in section.productIds)
          if (productsById[id] != null) productsById[id]!,
      ];
}

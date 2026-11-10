import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/motion/jd_motion.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/jd_catalog_image.dart';
import '../../../catalog/domain/catalog_models.dart';

/// PDF screen 8 — peach header, banner column layout.
class HomeProfileHeader extends StatelessWidget {
  const HomeProfileHeader({
    super.key,
    required this.member,
    required this.banners,
  });

  final CatalogMember member;
  final List<CatalogBanner> banners;

  static const _peach = AppColors.headerPeach;
  static const _ringLight = AppColors.ringLight;
  static const _ringDark = AppColors.ringDark;

  static Color _hex(String hex) {
    final clean = hex.trim();
    if (clean.isEmpty) return AppColors.bannerFallback;
    try {
      return Color(int.parse(clean.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.bannerFallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top;

    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomRight: Radius.circular(40)),
      child: ColoredBox(
        color: _peach,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  child: SafeArea(
                    bottom: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _AvatarRing(asset: member.avatarAsset),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.displayName,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${member.tier} member',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.brown.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${member.pointsToNextTier} points left to become ${member.nextTier} Member',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: topPad + 12,
                  child: _NotificationChip(count: member.notificationCount),
                ),
              ],
            ),
            if (banners.isNotEmpty) _HeaderBannerSlider(banners: banners),
          ],
        ),
      ),
    );
  }
}

class _AvatarRing extends StatelessWidget {
  const _AvatarRing({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    const size = 56.0;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(size, size),
            painter: _LeftGradientArcPainter(
              light: HomeProfileHeader._ringLight,
              dark: HomeProfileHeader._ringDark,
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: ClipOval(
              child: Image.asset(
                asset,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.person, color: HomeProfileHeader._ringDark),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ~30% arc on the left; peach-track → deep brown along the stroke.
class _LeftGradientArcPainter extends CustomPainter {
  _LeftGradientArcPainter({required this.light, required this.dark});

  final Color light;
  final Color dark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    const sweep = math.pi * 2 * 0.30;
    const start = -math.pi * 0.72;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final startPoint = Offset(
      center.dx + radius * math.cos(start),
      center.dy + radius * math.sin(start),
    );
    final endPoint = Offset(
      center.dx + radius * math.cos(start + sweep),
      center.dy + radius * math.sin(start + sweep),
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        colors: [light, dark],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(Rect.fromPoints(startPoint, endPoint));

    canvas.drawArc(rect, start, sweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant _LeftGradientArcPainter old) =>
      old.light != light || old.dark != dark;
}

class _NotificationChip extends StatelessWidget {
  const _NotificationChip({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.accentOrange,
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
        child: SizedBox(
          height: 30,
          child: Padding(
            padding: EdgeInsets.only(
              left: count > 0 ? 10 : 14,
              right: count > 0 ? 8 : 14,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderBannerSlider extends StatefulWidget {
  const _HeaderBannerSlider({required this.banners});

  final List<CatalogBanner> banners;

  @override
  State<_HeaderBannerSlider> createState() => _HeaderBannerSliderState();
}

class _HeaderBannerSliderState extends State<_HeaderBannerSlider> {
  late final PageController _pageController;
  Timer? _autoPlay;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // MediaQuery may update often — only (re)start when idle or Reduce Motion flips.
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _autoPlay?.cancel();
      _autoPlay = null;
      return;
    }
    if (_autoPlay == null) _restartAutoPlay();
  }

  @override
  void didUpdateWidget(covariant _HeaderBannerSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners != widget.banners) {
      _autoPlay?.cancel();
      _autoPlay = null;
      if (!MediaQuery.disableAnimationsOf(context)) _restartAutoPlay();
    }
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  List<CatalogBanner> get _slides {
    if (widget.banners.isEmpty) return [];
    final out = <CatalogBanner>[];
    while (out.length < 4) {
      out.addAll(widget.banners);
    }
    return out.take(4).toList();
  }

  void _restartAutoPlay() {
    _autoPlay?.cancel();
    _autoPlay = null;
    if (MediaQuery.disableAnimationsOf(context)) return;
    final count = _slides.length;
    if (count < 2) return;
    _autoPlay = Timer.periodic(JdMotion.bannerAutoPlay, (_) {
      if (!mounted || !_pageController.hasClients) return;
      _index = (_index + 1) % count;
      _pageController.animateToPage(
        _index,
        duration: JdMotion.bannerPage,
        curve: JdMotion.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _slides;
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 184,
      child: PageView.builder(
        controller: _pageController,
        itemCount: items.length,
        onPageChanged: (i) => _index = i,
        itemBuilder: (context, i) {
          final b = items[i];
          final base = HomeProfileHeader._hex(b.backgroundColor);
          final accent = HomeProfileHeader._hex(b.accentColor);

          return Padding(
            padding: EdgeInsets.only(left: i == 0 ? 16 : 6, right: 6),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: SizedBox(
                  height: 168,
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [base, accent],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 10),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentOrange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              b.badge,
                              style: const TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b.eyebrow,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.92),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                            child: _BannerPhoto(
                              imageAsset: b.imageAsset,
                              imageUrl: b.imageUrl,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BannerPhoto extends StatelessWidget {
  const _BannerPhoto({required this.imageAsset, required this.imageUrl});

  final String imageAsset;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            child: JdCatalogImage(
              asset: imageAsset,
              url: imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: -10,
          child: Material(
            elevation: 2,
            shadowColor: Colors.black26,
            color: Colors.white,
            shape: const CircleBorder(),
            child: SizedBox(
              width: 24,
              height: 24,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Image.asset(
                  'assets/images/shop_icon.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.storefront, size: 12, color: AppColors.accentOrange),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Pinterest-style masonry: two clipped columns scroll forever (GIF-like).
/// Only full-bleed product JPGs (no cutout / empty-background assets).
class WelcomeDonutShowcase extends StatefulWidget {
  const WelcomeDonutShowcase({super.key, this.compactHeights = false});

  final bool compactHeights;

  /// Full-frame product photos that fill the card with BoxFit.cover.
  static const assets = [
    'assets/images/products/coconut_donut.jpg',
    'assets/images/products/strawberry_donut.jpg',
    'assets/images/products/romance_box.jpg',
    'assets/images/products/sweet_box.jpg',
    'assets/images/products/mini_family.jpg',
    'assets/images/products/coffee_drink.jpg',
    'assets/images/shop_central_display.jpg',
    'assets/images/shop_myaynigone.jpg',
  ];

  @override
  State<WelcomeDonutShowcase> createState() => _WelcomeDonutShowcaseState();
}

class _WelcomeDonutShowcaseState extends State<WelcomeDonutShowcase>
    with SingleTickerProviderStateMixin {
  late final AnimationController _loop;
  late final List<String> _rightAssets;

  @override
  void initState() {
    super.initState();
    // ~60fps ticker; 20s loop keeps motion smooth without thrashing.
    _loop = AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _rightAssets = WelcomeDonutShowcase.assets.reversed.toList(growable: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _loop.stop();
      _loop.value = 0;
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!constraints.maxHeight.isFinite || constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }
        const gap = 10.0;
        final colW = (constraints.maxWidth - gap) / 2;
        final viewH = constraints.maxHeight;

        final scale = widget.compactHeights ? 0.82 : 1.0;
        final leftHeights = [
          colW * 1.15 * scale,
          colW * 0.88 * scale,
          colW * 1.08 * scale,
          colW * 0.98 * scale,
        ];
        final rightHeights = [
          colW * 0.85 * scale,
          colW * 1.18 * scale,
          colW * 0.95 * scale,
          colW * 1.1 * scale,
        ];

        return SizedBox(
          width: constraints.maxWidth,
          height: viewH,
          child: ClipRect(
            child: ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (rect) {
                return const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.7, 0.88, 1.0],
                  colors: [
                    Colors.white,
                    Colors.white,
                    Color(0x66FFFFFF),
                    Color(0x00000000),
                  ],
                ).createShader(rect);
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, col) => _ScrollingColumn(
                        controller: _loop,
                        phase: 0,
                        width: col.maxWidth,
                        viewportH: viewH,
                        heights: leftHeights,
                        assets: WelcomeDonutShowcase.assets,
                        upward: true,
                        gap: gap,
                      ),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, col) => _ScrollingColumn(
                        controller: _loop,
                        phase: 0.45,
                        width: col.maxWidth,
                        viewportH: viewH,
                        heights: rightHeights,
                        assets: _rightAssets,
                        upward: false,
                        gap: gap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ScrollingColumn extends StatelessWidget {
  const _ScrollingColumn({
    required this.controller,
    required this.phase,
    required this.width,
    required this.viewportH,
    required this.heights,
    required this.assets,
    required this.upward,
    required this.gap,
  });

  final AnimationController controller;
  final double phase;
  final double width;
  final double viewportH;
  final List<double> heights;
  final List<String> assets;
  final bool upward;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final tiles = <_TileSpec>[
      for (var i = 0; i < heights.length; i++)
        _TileSpec(assets[i % assets.length], heights[i]),
    ];
    final loopTiles = [...tiles, ...tiles];
    final blockH = heights.fold<double>(0, (a, b) => a + b) + gap * heights.length;

    return SizedBox(
      width: width,
      height: viewportH,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final raw = (controller.value + phase) % 1.0;
            final t = upward ? raw : (1 - raw);
            final offset = -t * blockH;
            return Transform.translate(
              offset: Offset(0, offset),
              filterQuality: FilterQuality.low,
              child: child,
            );
          },
          child: OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: 0,
            maxHeight: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final tile in loopTiles) ...[
                  _DonutCard(asset: tile.asset, width: width, height: tile.height),
                  SizedBox(height: gap),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TileSpec {
  const _TileSpec(this.asset, this.height);
  final String asset;
  final double height;
}

class _DonutCard extends StatelessWidget {
  const _DonutCard({
    required this.asset,
    required this.width,
    required this.height,
  });

  final String asset;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cache = (width * MediaQuery.devicePixelRatioOf(context)).round().clamp(64, 512);
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radiusLg),
      child: ColoredBox(
        color: const Color(0xFFE8EBED),
        child: SizedBox(
          width: width,
          height: height,
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.low,
            cacheWidth: cache,
            gaplessPlayback: true,
          ),
        ),
      ),
    );
  }
}

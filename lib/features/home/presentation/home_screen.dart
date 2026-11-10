import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/jd_staggered_fade.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/jd_skeleton.dart';
import '../../shell/presentation/jd_bottom_nav.dart';
import '../../catalog/application/catalog_providers.dart';
import 'widgets/home_nearby_strip.dart';
import 'widgets/home_product_strip.dart';
import 'widgets/home_profile_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routePath = '/home';
  static const routeName = 'home';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(homeCatalogProvider);
    // Scene continues under the pink nav — no grey gap after shop cards.
    final nearbyExtra = JdBottomNav.heightFor(context) * 0.55;

    return ColoredBox(
      color: AppColors.pageBg,
      child: catalog.when(
        loading: () => const HomeSkeleton(),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppColors.pad),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Could not load home\n$e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(homeCatalogProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (data) => RefreshIndicator(
          onRefresh: () => ref.read(homeCatalogProvider.notifier).refresh(),
          child: ListView(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              JdStaggeredFade(
                index: 0,
                child: HomeProfileHeader(
                  member: data.member,
                  banners: data.banners,
                ),
              ),
              for (var i = 0; i < data.sections.length; i++)
                JdStaggeredFade(
                  index: i + 1,
                  child: HomeProductStrip(
                    title: data.sections[i].title,
                    products: data.productsFor(data.sections[i]),
                    heroScope: data.sections[i].id,
                    style: data.sections[i].id.startsWith('seasonal')
                        ? HomeProductCardStyle.filled
                        : HomeProductCardStyle.inset,
                    onRetry: () => ref.invalidate(homeCatalogProvider),
                  ),
                ),
              const SizedBox(height: 12),
              JdStaggeredFade(
                index: data.sections.length + 1,
                child: SizedBox(
                  height: HomeNearbyStrip.contentHeight + nearbyExtra,
                  child: HomeNearbyStrip(shops: data.shops),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

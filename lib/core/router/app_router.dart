import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/application/auth_session_notifier.dart';
import '../../features/catalog/application/catalog_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/jd_offline_banner.dart';
import '../../features/auth/presentation/auth_flow_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/product/presentation/product_detail_screen.dart';
import '../../features/donuts/presentation/donuts_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../features/rewards/presentation/rewards_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/jd_bottom_nav.dart';
import '../../features/welcome/presentation/welcome_screen.dart';
import 'app_routes.dart';
import 'jd_transition_page.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRoute _productDetailRoute({required String name}) {
  return GoRoute(
    path: 'product/:productId',
    name: name,
    pageBuilder: (context, state) {
      final productId = state.pathParameters['productId'] ?? '';
      final heroTag = state.extra is String ? state.extra as String : null;
      return CustomTransitionPage<void>(
        key: state.pageKey,
        // Keep Home under the route so the push Hero flight can read both ends.
        opaque: false,
        child: ProductDetailScreen(productId: productId, heroTag: heroTag),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Fade only — Hero owns the shared-element motion.
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: child,
          );
        },
      );
    },
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  // Do NOT watch authSessionProvider here — that recreates GoRouter and
  // snaps back to initialLocation (onboarding) on every session rebuild.
  final refresh = ref.watch(authRefreshListenableProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.onboarding,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(authSessionProvider);
      if (session.isLoading) return null;

      final loggedIn = session.value != null;
      final path = state.uri.path;
      final onAuth = path == AuthFlowScreen.routePath || path.startsWith('/auth/');

      bool isProtected(String p) =>
          p == AppRoutes.home ||
          p.startsWith('${AppRoutes.home}/') ||
          p == AppRoutes.shop ||
          p.startsWith('${AppRoutes.shop}/') ||
          p == AppRoutes.donuts ||
          p.startsWith('${AppRoutes.donuts}/') ||
          p == AppRoutes.rewards ||
          p == AppRoutes.wallet ||
          p == AppRoutes.more;

      if (loggedIn) {
        if (path == AppRoutes.onboarding || onAuth) return AppRoutes.home;
        if (path == AppRoutes.rewards) return AppRoutes.shop;
        // Legacy top-level product URL → home nested route.
        if (path.startsWith('/product/')) {
          final id = path.split('/').last;
          return AppRoutes.productDetailPath(id);
        }
      } else {
        if (isProtected(path) || path.startsWith('/product/')) {
          return AppRoutes.onboarding;
        }
      }
      return null;
    },
    routes: [
      GoRoute(
        path: OnboardingScreen.routePath,
        name: OnboardingScreen.routeName,
        pageBuilder: (context, state) =>
            jdAuthTransitionPage(state: state, child: const OnboardingScreen()),
      ),
      GoRoute(
        path: AuthFlowScreen.routePath,
        name: AuthFlowScreen.routeName,
        pageBuilder: (context, state) =>
            jdAuthTransitionPage(state: state, child: const AuthFlowScreen()),
      ),
      GoRoute(path: '/auth/phone', redirect: (_, _) => AuthFlowScreen.routePath),
      GoRoute(path: '/auth/verify', redirect: (_, _) => AuthFlowScreen.routePath),
      GoRoute(path: '/auth/name', redirect: (_, _) => AuthFlowScreen.routePath),
      GoRoute(path: '/auth/birthday', redirect: (_, _) => AuthFlowScreen.routePath),
      GoRoute(
        path: WelcomeScreen.routePath,
        name: WelcomeScreen.routeName,
        pageBuilder: (context, state) =>
            jdAuthTransitionPage(state: state, child: const WelcomeScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final hideNav = state.uri.path.contains('/product/');
          return Consumer(
            builder: (context, ref, _) {
              final offline = ref.watch(isOfflineProvider);
              ref.listen(connectivityProvider, (prev, next) async {
                final linkUp =
                    next.asData?.value.any((r) => r != ConnectivityResult.none) ??
                        false;
                if (!linkUp) return;
                final reachable = await ref.read(hasReachabilityProvider.future);
                if (reachable) {
                  ref.read(homeCatalogProvider.notifier).refresh();
                }
              });
              return Scaffold(
                backgroundColor: AppColors.pageBg,
                body: Column(
                  children: [
                    if (offline) const JdOfflineBanner(),
                    Expanded(child: navigationShell),
                  ],
                ),
                bottomNavigationBar: hideNav
                    ? null
                    : JdBottomNav(
                        currentIndex: navigationShell.currentIndex,
                        onSelect: (index) {
                          navigationShell.goBranch(
                            index,
                            initialLocation:
                                index == navigationShell.currentIndex,
                          );
                        },
                      ),
              );
            },
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: HomeScreen.routePath,
                name: HomeScreen.routeName,
                builder: (context, state) => const HomeScreen(),
                routes: [
                  _productDetailRoute(name: 'home-product-detail'),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.shop,
                name: 'shop',
                builder: (context, state) => const RewardsScreen(),
                routes: [
                  _productDetailRoute(name: 'shop-product-detail'),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: DonutsScreen.routePath,
                name: DonutsScreen.routeName,
                builder: (context, state) => const DonutsScreen(),
                routes: [
                  _productDetailRoute(name: 'donuts-product-detail'),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: WalletScreen.routePath,
                name: WalletScreen.routeName,
                builder: (context, state) => const WalletScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: SettingsScreen.routePath,
                name: SettingsScreen.routeName,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

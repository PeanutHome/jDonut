/// Paths used for redirects and deep links (screen classes own route names).
abstract final class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const rewards = '/rewards';
  static const shop = '/shop';
  static const donuts = '/donuts';
  static const wallet = '/wallet';
  static const more = '/more';

  /// Nested under a shell tab so Hero shares the same Navigator.
  static String productDetailPath(
    String productId, {
    String from = home,
  }) =>
      '$from/product/$productId';
}

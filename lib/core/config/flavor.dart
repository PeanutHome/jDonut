import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppFlavor {
  dev,
  staging,
  prod;

  static AppFlavor parse(String raw) =>
      AppFlavor.values.firstWhere((f) => f.name == raw.toLowerCase(), orElse: () => AppFlavor.dev);
}

class FlavorConfig {
  const FlavorConfig({
    required this.appName,
    required this.apiBaseUrl,
    required this.showDebugBanner,
  });

  final String appName;
  final String apiBaseUrl;
  final bool showDebugBanner;

  static const _apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static FlavorConfig resolve(AppFlavor flavor) {
    final base = switch (flavor) {
      AppFlavor.dev => const FlavorConfig(
          appName: 'Zawe Dev',
          apiBaseUrl: 'https://api-dev.jdonuts.local',
          showDebugBanner: false,
        ),
      AppFlavor.staging => const FlavorConfig(
          appName: 'Zawe Staging',
          apiBaseUrl: 'https://api-staging.jdonuts.local',
          showDebugBanner: false,
        ),
      AppFlavor.prod => const FlavorConfig(
          appName: 'Zawe',
          apiBaseUrl: 'https://api.jdonuts.com',
          showDebugBanner: false,
        ),
    };
    if (_apiBaseUrl.isEmpty) return base;
    return FlavorConfig(
      appName: base.appName,
      apiBaseUrl: _apiBaseUrl,
      showDebugBanner: base.showDebugBanner,
    );
  }
}

final flavorConfigProvider = Provider<FlavorConfig>((ref) {
  throw StateError('Override flavorConfigProvider in bootstrap');
});

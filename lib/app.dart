import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/flavor.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  static var _warmedAssets = false;

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final flavor = ref.watch(flavorConfigProvider);

    return MaterialApp.router(
      title: flavor.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: router,
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        if (!_warmedAssets) {
          _warmedAssets = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _warmAssets(context));
        }
        // Brief: portrait phones up to text scale 1.3 without overflow.
        final mq = MediaQuery.of(context);
        final scaler = mq.textScaler.clamp(
          minScaleFactor: 1.0,
          maxScaleFactor: AppColors.maxTextScale,
        );
        return MediaQuery(
          data: mq.copyWith(textScaler: scaler),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }

  void _warmAssets(BuildContext context) {
    const paths = [
      'assets/images/onboarding_screen1.jpg',
      'assets/images/donut_purple.jpg',
      'assets/images/donut_pink.jpg',
      'assets/images/donut_peach.jpg',
    ];
    for (final p in paths) {
      precacheImage(AssetImage(p), context);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/flavor.dart';
import 'features/auth/application/auth_providers.dart';
import 'features/catalog/application/catalog_providers.dart';
import 'features/catalog/data/catalog_database.dart';

Future<void> bootstrap(AppFlavor flavor) async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemStatusBarContrastEnforced: false,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  final config = FlavorConfig.resolve(flavor);
  final prefs = await SharedPreferences.getInstance();
  final catalogDb = await CatalogDatabase.open();
  await catalogDb.ensureSeeded();

  runApp(
    ProviderScope(
      overrides: [
        flavorConfigProvider.overrideWithValue(config),
        sharedPreferencesProvider.overrideWithValue(prefs),
        catalogDatabaseProvider.overrideWithValue(catalogDb),
      ],
      child: const App(),
    ),
  );
}

Future<void> bootstrapFromEnvironment() async {
  const flavorRaw = String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');
  await bootstrap(AppFlavor.parse(flavorRaw));
}

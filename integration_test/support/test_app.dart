import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:zawe/app.dart';
import 'package:zawe/core/config/flavor.dart';
import 'package:zawe/features/auth/application/auth_providers.dart';
import 'package:zawe/features/auth/data/fake_auth_repository.dart';
import 'package:zawe/features/auth/data/secure_string_store.dart';
import 'package:zawe/features/catalog/application/catalog_providers.dart';
import 'package:zawe/features/catalog/data/catalog_database.dart';

bool _ffiReady = false;

Future<void> ensureTestDbFactory() async {
  if (_ffiReady) return;
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  _ffiReady = true;
}

/// Full app with zero-latency auth + fresh prefs/session for integration tests.
Future<void> pumpZaweApp(WidgetTester tester) async {
  await ensureTestDbFactory();
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final secure = MemorySecureStringStore();
  final catalogDb = await CatalogDatabase.open();
  await catalogDb.ensureSeeded();

  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Force Reduce Motion so auth ring / welcome / route pumps settle.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        flavorConfigProvider.overrideWithValue(FlavorConfig.resolve(AppFlavor.dev)),
        sharedPreferencesProvider.overrideWithValue(prefs),
        secureStringStoreProvider.overrideWithValue(secure),
        catalogDatabaseProvider.overrideWithValue(catalogDb),
        authRepositoryProvider.overrideWithValue(
          FakeAuthRepository(prefs, secure, networkDelay: Duration.zero),
        ),
        connectivityProvider.overrideWith(
          (ref) => Stream.value(const [ConnectivityResult.wifi]),
        ),
        hasReachabilityProvider.overrideWith((ref) async => true),
      ],
      child: const App(),
    ),
  );
  await tester.pumpAndSettle();
}

String uniqueTestPhone() {
  final n = DateTime.now().microsecondsSinceEpoch % 100000000;
  return '9${n.toString().padLeft(8, '0')}';
}

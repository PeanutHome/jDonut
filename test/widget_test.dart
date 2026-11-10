import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zawe/app.dart';
import 'package:zawe/core/config/flavor.dart';
import 'package:zawe/features/auth/application/auth_providers.dart';
import 'package:zawe/features/auth/data/secure_string_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('opens onboarding screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final config = FlavorConfig.resolve(AppFlavor.dev);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          flavorConfigProvider.overrideWithValue(config),
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureStringStoreProvider.overrideWithValue(MemorySecureStringStore()),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Round food'), findsOneWidget);
    expect(find.text("LET'S GET STARTED"), findsOneWidget);
  });
}

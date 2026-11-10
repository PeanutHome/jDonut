import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:zawe/features/auth/application/auth_flow_notifier.dart';
import 'package:zawe/features/auth/application/auth_providers.dart';
import 'package:zawe/features/auth/data/fake_auth_repository.dart';
import 'package:zawe/features/auth/data/secure_string_store.dart';
import 'package:zawe/features/auth/domain/auth_constants.dart';
import 'package:zawe/features/auth/domain/repositories/auth_repository.dart';
import 'package:zawe/features/auth/domain/validators/phone_validator.dart';
import 'package:zawe/features/auth/presentation/steps/auth_birthday_step.dart';
import 'package:zawe/features/auth/presentation/steps/auth_name_step.dart';
import 'package:zawe/features/auth/presentation/steps/auth_otp_step.dart';
import 'package:zawe/features/auth/presentation/steps/auth_phone_step.dart';

Future<ProviderContainer> _container({
  AuthFlowMode mode = AuthFlowMode.register,
  String? phoneE164,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final secure = MemorySecureStringStore();
  final repo = FakeAuthRepository(prefs, secure, networkDelay: Duration.zero);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      secureStringStoreProvider.overrideWithValue(secure),
      authRepositoryProvider.overrideWithValue(repo),
    ],
  );
  container.read(authFlowProvider.notifier).setMode(mode);
  if (phoneE164 != null) {
    container.read(authFlowProvider.notifier).setPhoneE164(phoneE164);
  }
  return container;
}

Widget _wrap(ProviderContainer container, Widget child) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: child),
      ),
    ),
  );
}

FilledButton _continueButton(WidgetTester tester) {
  return tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('phone validation', () {
    testWidgets('shows inline error after editing complete when invalid', (tester) async {
      final container = await _container();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(container, AuthPhoneStep(onAdvanced: () {})),
      );

      await tester.enterText(find.byType(TextField), '81234567');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text(PhoneValidation.invalidMessage), findsOneWidget);
      expect(_continueButton(tester).onPressed, isNull);
    });

    testWidgets('login shows register link when number is not registered', (tester) async {
      final container = await _container(mode: AuthFlowMode.login);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(container, AuthPhoneStep(onAdvanced: () {})),
      );

      await tester.enterText(find.byType(TextField), '9254135592');
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('This number is not registered yet.'), findsOneWidget);
      expect(find.text('Register with this number'), findsOneWidget);
    });
  });

  group('name validation', () {
    testWidgets('shows first-name inline error after blur', (tester) async {
      final container = await _container();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(container, AuthNameStep(onAdvanced: () {})),
      );

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Hania123');
      await tester.testTextInput.receiveAction(TextInputAction.next);
      await tester.pump();

      expect(find.text('Use letters and spaces only'), findsOneWidget);
      expect(_continueButton(tester).onPressed, isNull);
    });

    testWidgets('allows empty last name with valid first name', (tester) async {
      final container = await _container();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(container, AuthNameStep(onAdvanced: () {})),
      );

      await tester.enterText(find.byType(TextField).at(0), 'Hania');
      await tester.pump();

      expect(_continueButton(tester).onPressed, isNotNull);
    });
  });

  group('otp validation', () {
    testWidgets('wrong codes show message and lock after 3 attempts', (tester) async {
      final container = await _container(phoneE164: '+959254135592');
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(container, AuthOtpStep(onRegisterVerified: () {})),
      );

      Future<void> submitWrong() async {
        await tester.enterText(find.byType(EditableText), '000000');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pump();
      }

      await submitWrong();
      expect(find.text('Incorrect code. Try again.'), findsOneWidget);

      await submitWrong();
      expect(find.text('Incorrect code. Try again.'), findsOneWidget);

      await submitWrong();
      expect(
        find.text('Too many wrong codes. Tap Resend to try again.'),
        findsOneWidget,
      );
      expect(container.read(authFlowProvider).otpLocked, isTrue);
      expect(_continueButton(tester).onPressed, isNull);
    });

    testWidgets('accepts fake otp 123456 for register path', (tester) async {
      final container = await _container(phoneE164: '+959254135592');
      addTearDown(container.dispose);
      var advanced = false;

      await tester.pumpWidget(
        _wrap(
          container,
          AuthOtpStep(onRegisterVerified: () => advanced = true),
        ),
      );

      await tester.enterText(find.byType(EditableText), AuthConstants.fakeOtpCode);
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(advanced, isTrue);
    });
  });

  group('date of birth validation', () {
    testWidgets('shows inline error for impossible calendar date', (tester) async {
      final container = await _container(phoneE164: '+959254135592');
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(container, AuthBirthdayStep(onRingComplete: (_) {})),
      );

      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), '4');
      await tester.enterText(fields.at(1), '31');
      await tester.enterText(fields.at(2), '2000');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.textContaining('valid calendar date'), findsOneWidget);
      expect(_continueButton(tester).onPressed, isNull);
    });
  });
}

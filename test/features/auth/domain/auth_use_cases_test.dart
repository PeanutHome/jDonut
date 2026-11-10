import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zawe/core/domain/result.dart';
import 'package:zawe/features/auth/data/fake_auth_repository.dart';
import 'package:zawe/features/auth/data/secure_string_store.dart';
import 'package:zawe/features/auth/domain/auth_constants.dart';
import 'package:zawe/features/auth/domain/use_cases/auth_use_cases.dart';

void main() {
  late FakeAuthRepository repo;
  late LoginWithOtp login;
  late CompleteRegistration register;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    repo = FakeAuthRepository(
      prefs,
      MemorySecureStringStore(),
      networkDelay: Duration.zero,
    );
    login = LoginWithOtp(repo);
    register = CompleteRegistration(repo);
  });

  test('register then login returns same user', () async {
    final created = await register(
      phoneE164: '+959254135592',
      firstName: 'Hania',
      dateOfBirth: DateTime(2000, 1, 1),
    );
    expect(created.isOk, isTrue);

    final loggedIn = await login(
      phoneE164: '+959254135592',
      otp: AuthConstants.fakeOtpCode,
    );
    expect(loggedIn, isA<Ok>());
    expect(loggedIn.valueOrNull?.firstName, 'Hania');
  });

  test('login with wrong otp returns AuthFailure', () async {
    await register(
      phoneE164: '+959254135592',
      firstName: 'Hania',
      dateOfBirth: DateTime(2000, 1, 1),
    );
    final result = await login(phoneE164: '+959254135592', otp: '000000');
    expect(result.isErr, isTrue);
    expect(result.failureOrNull?.message, contains('Invalid'));
  });
}

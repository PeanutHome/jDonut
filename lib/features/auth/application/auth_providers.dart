import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/fake_auth_repository.dart';
import '../data/secure_string_store.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/use_cases/auth_use_cases.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw StateError('Override sharedPreferencesProvider in bootstrap');
});

final secureStringStoreProvider = Provider<SecureStringStore>((ref) {
  return FlutterSecureStringStore();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FakeAuthRepository(
    ref.watch(sharedPreferencesProvider),
    ref.watch(secureStringStoreProvider),
  );
});

final sendOtpProvider = Provider((ref) => SendOtp(ref.watch(authRepositoryProvider)));
final checkPhoneRegisteredProvider =
    Provider((ref) => CheckPhoneRegistered(ref.watch(authRepositoryProvider)));
final loginWithOtpProvider =
    Provider((ref) => LoginWithOtp(ref.watch(authRepositoryProvider)));
final completeRegistrationProvider =
    Provider((ref) => CompleteRegistration(ref.watch(authRepositoryProvider)));

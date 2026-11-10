import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/domain/app_failure.dart';
import '../../../core/domain/result.dart';
import '../domain/auth_constants.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/validators/otp_validator.dart';
import 'secure_string_store.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(
    this._prefs,
    this._secure, {
    this.networkDelay = AuthConstants.fakeNetworkDelay,
  });

  final SharedPreferences _prefs;
  final SecureStringStore _secure;
  final Duration networkDelay;

  static const usersKey = 'auth_registered_users';
  static const sessionKey = 'auth_session_phone';

  Future<void> _delay() => Future<void>.delayed(networkDelay);

  Future<List<AppUser>> _users() async {
    final raw = _prefs.getString(usersKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => AppUser.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _saveUsers(List<AppUser> users) async {
    await _prefs.setString(
      usersKey,
      jsonEncode(users.map((u) => u.toJson()).toList()),
    );
  }

  Future<void> _writeSession(String phoneE164) async {
    await _secure.write(sessionKey, phoneE164);
    await _prefs.remove(sessionKey);
  }

  Future<String?> _readSession() async {
    final secure = await _secure.read(sessionKey);
    if (secure != null && secure.isNotEmpty) return secure;

    final legacy = _prefs.getString(sessionKey);
    if (legacy == null || legacy.isEmpty) return null;
    await _secure.write(sessionKey, legacy);
    await _prefs.remove(sessionKey);
    return legacy;
  }

  @override
  Future<Result<Unit>> sendOtp(String phoneE164) async {
    await _delay();
    return const Ok(Unit.value);
  }

  @override
  Future<Result<bool>> isPhoneRegistered(String phoneE164) async {
    await _delay();
    final users = await _users();
    return Ok(users.any((u) => u.phoneE164 == phoneE164));
  }

  @override
  Future<Result<AppUser>> completeRegistration({
    required String phoneE164,
    required String firstName,
    String? lastName,
    required DateTime dateOfBirth,
  }) async {
    await _delay();
    final users = await _users();
    if (users.any((u) => u.phoneE164 == phoneE164)) {
      return const Err(AuthFailure('Phone number is already registered'));
    }
    final user = AppUser(
      phoneE164: phoneE164,
      firstName: firstName.trim(),
      lastName: lastName?.trim().isEmpty ?? true ? null : lastName!.trim(),
      dateOfBirth: dateOfBirth,
    );
    users.add(user);
    await _saveUsers(users);
    await _writeSession(phoneE164);
    return Ok(user);
  }

  @override
  Future<Result<AppUser>> loginWithOtp({
    required String phoneE164,
    required String otp,
  }) async {
    await _delay();
    if (!isFakeOtpCorrect(otp)) {
      return const Err(AuthFailure('Invalid verification code'));
    }
    for (final u in await _users()) {
      if (u.phoneE164 == phoneE164) {
        await _writeSession(phoneE164);
        return Ok(u);
      }
    }
    return const Err(AuthFailure('not_registered'));
  }

  @override
  Future<Result<AppUser?>> getCurrentUser() async {
    final phone = await _readSession();
    if (phone == null) return const Ok(null);
    for (final u in await _users()) {
      if (u.phoneE164 == phone) return Ok(u);
    }
    await _secure.delete(sessionKey);
    return const Ok(null);
  }

  @override
  Future<Result<Unit>> clearSession() async {
    await _secure.delete(sessionKey);
    await _prefs.remove(sessionKey);
    return const Ok(Unit.value);
  }
}

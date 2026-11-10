import '../../../../core/domain/result.dart';
import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

class SendOtp {
  const SendOtp(this._repo);
  final AuthRepository _repo;

  Future<Result<Unit>> call(String phoneE164) => _repo.sendOtp(phoneE164);
}

class CheckPhoneRegistered {
  const CheckPhoneRegistered(this._repo);
  final AuthRepository _repo;

  Future<Result<bool>> call(String phoneE164) =>
      _repo.isPhoneRegistered(phoneE164);
}

class LoginWithOtp {
  const LoginWithOtp(this._repo);
  final AuthRepository _repo;

  Future<Result<AppUser>> call({
    required String phoneE164,
    required String otp,
  }) =>
      _repo.loginWithOtp(phoneE164: phoneE164, otp: otp);
}

class CompleteRegistration {
  const CompleteRegistration(this._repo);
  final AuthRepository _repo;

  Future<Result<AppUser>> call({
    required String phoneE164,
    required String firstName,
    String? lastName,
    required DateTime dateOfBirth,
  }) =>
      _repo.completeRegistration(
        phoneE164: phoneE164,
        firstName: firstName,
        lastName: lastName,
        dateOfBirth: dateOfBirth,
      );
}

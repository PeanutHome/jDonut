import '../../../../core/domain/result.dart';
import '../entities/app_user.dart';

enum AuthFlowMode { register, login }

abstract class AuthRepository {
  Future<Result<Unit>> sendOtp(String phoneE164);

  Future<Result<bool>> isPhoneRegistered(String phoneE164);

  Future<Result<AppUser>> completeRegistration({
    required String phoneE164,
    required String firstName,
    String? lastName,
    required DateTime dateOfBirth,
  });

  Future<Result<AppUser>> loginWithOtp({
    required String phoneE164,
    required String otp,
  });

  Future<Result<AppUser?>> getCurrentUser();

  Future<Result<Unit>> clearSession();
}

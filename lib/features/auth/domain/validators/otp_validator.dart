import '../auth_constants.dart';

class OtpValidation {
  const OtpValidation({required this.isValid, this.error});

  final bool isValid;
  final String? error;
}

OtpValidation validateOtpCode(String code) {
  if (!RegExp(r'^\d{6}$').hasMatch(code)) {
    return const OtpValidation(isValid: false, error: 'Enter the 6-digit code');
  }
  return const OtpValidation(isValid: true);
}

bool isFakeOtpCorrect(String code) => code == AuthConstants.fakeOtpCode;

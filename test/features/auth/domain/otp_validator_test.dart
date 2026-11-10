import 'package:flutter_test/flutter_test.dart';
import 'package:zawe/features/auth/domain/validators/otp_validator.dart';

void main() {
  test('validateOtpCode requires 6 digits', () {
    expect(validateOtpCode('12345').isValid, isFalse);
    expect(validateOtpCode('123456').isValid, isTrue);
    expect(validateOtpCode('12a456').isValid, isFalse);
  });

  test('fake otp is 123456', () {
    expect(isFakeOtpCorrect('123456'), isTrue);
    expect(isFakeOtpCorrect('000000'), isFalse);
  });
}

abstract final class AuthConstants {
  static const minRegistrationAge = 13;
  static const fakeOtpCode = '123456';
  static const maxWrongOtpAttempts = 3;
  static const resendSeconds = 5 * 60;
  static const fakeNetworkDelay = Duration(seconds: 1);
}

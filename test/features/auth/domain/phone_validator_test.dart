import 'package:flutter_test/flutter_test.dart';
import 'package:zawe/features/auth/domain/validators/phone_validator.dart';

void main() {
  group('normalizePhoneLocalPart', () {
    test('strips spaces, dashes and one leading 0', () {
      expect(normalizePhoneLocalPart('092-5413-5592'), '9254135592');
      expect(normalizePhoneLocalPart('092 541 35592'), '9254135592');
    });
  });

  group('validatePhoneLocalPart', () {
    test('accepts 9 followed by 7-9 digits', () {
      final r = validatePhoneLocalPart('9254135592');
      expect(r.isValid, isTrue);
      expect(r.e164, '+959254135592');
    });

    test('rejects too few digits', () {
      expect(validatePhoneLocalPart('9123456').isValid, isFalse);
    });

    test('rejects non-leading 9', () {
      expect(validatePhoneLocalPart('8123456789').isValid, isFalse);
    });
  });
}

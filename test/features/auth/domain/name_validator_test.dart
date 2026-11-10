import 'package:flutter_test/flutter_test.dart';
import 'package:zawe/features/auth/domain/validators/name_validator.dart';

void main() {
  test('first name required and length', () {
    expect(validateFirstName('').isValid, isFalse);
    expect(validateFirstName('Aung').isValid, isTrue);
    expect(validateFirstName('a' * 51).isValid, isFalse);
  });

  test('rejects digits in names', () {
    expect(validateFirstName('Aung1').isValid, isFalse);
  });

  test('allows Myanmar script', () {
    expect(validateFirstName('ကောင်းထက်စံ').isValid, isTrue);
  });

  test('last name optional', () {
    expect(validateLastName('').isValid, isTrue);
    expect(validateLastName('Kyaw').isValid, isTrue);
  });
}

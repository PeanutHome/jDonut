import 'package:flutter_test/flutter_test.dart';
import 'package:zawe/features/auth/domain/auth_constants.dart';
import 'package:zawe/features/auth/domain/validators/date_of_birth_validator.dart';

void main() {
  final now = DateTime(2026, 6, 15);

  test('rejects invalid calendar dates', () {
    expect(
      validateDateOfBirth(month: 4, day: 31, year: 2000, now: now).isValid,
      isFalse,
    );
    expect(
      validateDateOfBirth(month: 2, day: 29, year: 2001, now: now).isValid,
      isFalse,
    );
    expect(
      validateDateOfBirth(month: 2, day: 29, year: 2000, now: now).isValid,
      isTrue,
    );
  });

  test('rejects future dates', () {
    expect(
      validateDateOfBirth(month: 12, day: 31, year: 2030, now: now).isValid,
      isFalse,
    );
  });

  test('enforces minimum age', () {
    final tooYoung = DateTime(now.year - AuthConstants.minRegistrationAge + 1, 6, 16);
    expect(
      validateDateOfBirth(
        month: tooYoung.month,
        day: tooYoung.day,
        year: tooYoung.year,
        now: now,
      ).isValid,
      isFalse,
    );
  });
}

import '../auth_constants.dart';

class DateOfBirthValidation {
  const DateOfBirthValidation({required this.isValid, this.error, this.date});

  final bool isValid;
  final String? error;
  final DateTime? date;
}

DateOfBirthValidation validateDateOfBirth({
  required int month,
  required int day,
  required int year,
  DateTime? now,
}) {
  final clock = now ?? DateTime.now();
  if (month < 1 || month > 12 || day < 1 || year < 1900) {
    return const DateOfBirthValidation(
      isValid: false,
      error: 'Enter a valid date',
    );
  }

  late final DateTime date;
  try {
    date = DateTime(year, month, day);
  } catch (_) {
    return const DateOfBirthValidation(
      isValid: false,
      error: 'Enter a valid date',
    );
  }
  if (date.month != month || date.day != day || date.year != year) {
    return const DateOfBirthValidation(
      isValid: false,
      error: 'Enter a valid calendar date',
    );
  }

  final today = DateTime(clock.year, clock.month, clock.day);
  if (date.isAfter(today)) {
    return const DateOfBirthValidation(
      isValid: false,
      error: 'Date of birth cannot be in the future',
    );
  }

  var age = today.year - date.year;
  final hadBirthdayThisYear = (today.month > date.month) ||
      (today.month == date.month && today.day >= date.day);
  if (!hadBirthdayThisYear) {
    age -= 1;
  }
  if (age < AuthConstants.minRegistrationAge) {
    return DateOfBirthValidation(
      isValid: false,
      error: 'You must be at least ${AuthConstants.minRegistrationAge} years old',
    );
  }

  return DateOfBirthValidation(isValid: true, date: date);
}

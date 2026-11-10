class PhoneValidation {
  const PhoneValidation({required this.isValid, this.error, this.e164});

  final bool isValid;
  final String? error;
  final String? e164;

  static const invalidMessage =
      'Enter a valid Myanmar mobile number (9 followed by 7–9 digits).';
}

/// Strips spaces/dashes and one leading 0 after the +95 prefix field.
String normalizePhoneLocalPart(String raw) {
  var digits = raw.replaceAll(RegExp(r'[\s-]'), '');
  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  return digits;
}

PhoneValidation validatePhoneLocalPart(String raw) {
  final digits = normalizePhoneLocalPart(raw);
  if (digits.isEmpty) {
    return const PhoneValidation(isValid: false);
  }
  if (!RegExp(r'^9\d{7,9}$').hasMatch(digits)) {
    return const PhoneValidation(isValid: false, error: PhoneValidation.invalidMessage);
  }
  return PhoneValidation(isValid: true, e164: '+95$digits');
}

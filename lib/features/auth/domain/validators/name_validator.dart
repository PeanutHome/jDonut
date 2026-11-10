class NameValidation {
  const NameValidation({required this.isValid, this.error});

  final bool isValid;
  final String? error;
}

// Latin letters, spaces, Myanmar script blocks; no digits.
final _namePattern = RegExp(
  r'^[a-zA-Z\u1000-\u109F\uAA60-\uAA7F\uA9E0-\uA9FF\s]+$',
);

NameValidation validateFirstName(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return const NameValidation(isValid: false, error: 'First name is required');
  }
  if (trimmed.length > 50) {
    return const NameValidation(
      isValid: false,
      error: 'First name must be 50 characters or less',
    );
  }
  if (!_namePattern.hasMatch(trimmed)) {
    return const NameValidation(
      isValid: false,
      error: 'Use letters and spaces only',
    );
  }
  return const NameValidation(isValid: true);
}

NameValidation validateLastName(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return const NameValidation(isValid: true);
  }
  if (trimmed.length > 50) {
    return const NameValidation(
      isValid: false,
      error: 'Last name must be 50 characters or less',
    );
  }
  if (!_namePattern.hasMatch(trimmed)) {
    return const NameValidation(
      isValid: false,
      error: 'Use letters and spaces only',
    );
  }
  return const NameValidation(isValid: true);
}

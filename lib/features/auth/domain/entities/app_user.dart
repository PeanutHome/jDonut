final class AppUser {
  const AppUser({
    required this.phoneE164,
    required this.firstName,
    this.lastName,
    required this.dateOfBirth,
  });

  final String phoneE164;
  final String firstName;
  final String? lastName;
  final DateTime dateOfBirth;

  Map<String, dynamic> toJson() => {
        'phoneE164': phoneE164,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      phoneE164: json['phoneE164'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
    );
  }
}

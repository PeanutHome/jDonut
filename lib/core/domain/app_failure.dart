/// Typed failures for Result — no raw exceptions across layers.
sealed class AppFailure {
  const AppFailure(this.message);
  final String message;
}

final class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure(super.message);
}

final class CacheFailure extends AppFailure {
  const CacheFailure(super.message);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure(super.message);
}

final class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'Something went wrong']);
}

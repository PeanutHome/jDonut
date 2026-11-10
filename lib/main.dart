import 'bootstrap.dart';

/// Default entry — flavor from `--dart-define=APP_FLAVOR=dev`
/// or `--dart-define-from-file=flavors/dev.json`.
void main() => bootstrapFromEnvironment();

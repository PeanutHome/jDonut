import 'package:flutter_test/flutter_test.dart';
import 'package:zawe/core/domain/app_failure.dart';
import 'package:zawe/core/domain/result.dart';

void main() {
  test('Ok exposes value and when branch', () {
    const result = Ok<int>(42);
    expect(result.isOk, isTrue);
    expect(result.valueOrNull, 42);
    expect(
      result.when(ok: (v) => v * 2, err: (_) => -1),
      84,
    );
  });

  test('Err exposes failure and when branch', () {
    const result = Err<int>(AuthFailure('bad'));
    expect(result.isErr, isTrue);
    expect(result.failureOrNull?.message, 'bad');
    expect(
      result.when(ok: (_) => 'ok', err: (f) => f.message),
      'bad',
    );
  });
}

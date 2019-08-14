import 'package:test/test.dart';

import 'package:unplugg_prototype/core/shared/utilities.dart';

void main() {

  test('calculateDurationSinceStartTime', () {
    var startTime = DateTime.now();
    var duration = const Duration(minutes: 1);
    var remainingDuration = calculateDurationSinceStartTime(startTime, duration);
    print(remainingDuration);
    expect(remainingDuration <= duration, isTrue);
  });

  test('calculateDurationSinceStartTime startTime cannot be in future', () {
    var startTime = DateTime.now().add(Duration(seconds: 30));
    var duration = const Duration(minutes: 1);
    expect(() => calculateDurationSinceStartTime(startTime, duration),
        throwsA(TypeMatcher<AssertionError>()));
  });
}
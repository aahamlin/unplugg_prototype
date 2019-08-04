import 'package:test/test.dart';

import 'package:unplugg_prototype/shared/phone_event_observer.dart';
import 'package:unplugg_prototype/shared/phone_event_model.dart';
import 'package:unplugg_prototype/shared/phone_event_state.dart';

void main() {

  test('PhoneEvent from String', () {
    PhoneEventModel pe = PhoneEventModel.fromString('unlocked');
    expect(pe.state, PhoneEventState.unlocked);
    expect(pe.dateTime, isA<DateTime>());
    expect(pe.dateTime.isBefore(DateTime.now()), isTrue);
  });

  test('PhoneEvent atomic dateTime', () {
    var dt1 = PhoneEventModel(PhoneEventState.locking).dateTime;
    var dt2 = PhoneEventModel(PhoneEventState.locking).dateTime;
    expect(dt1.isBefore(dt2), isTrue);
  });
}
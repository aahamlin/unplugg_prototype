import 'package:test/test.dart';

import 'package:unplugg_prototype/services/phone_event_observer.dart';

void main() {

  test('PhoneEvent from String', () {
    PhoneEvent pe = PhoneEvent.fromString('unlocked');
    expect(pe.name, PhoneEventName.unlocked);
    expect(pe.dateTime, isA<DateTime>());
    expect(pe.dateTime.isBefore(DateTime.now()), isTrue);
  });

  test('PhoneEvent atomic dateTime', () {
    var dt1 = PhoneEvent(PhoneEventName.locking).dateTime;
    var dt2 = PhoneEvent(PhoneEventName.locking).dateTime;
    expect(dt1.isBefore(dt2), isTrue);
  });
}
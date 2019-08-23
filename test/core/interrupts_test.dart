
import 'dart:async';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:flutter/services.dart';
//import 'package:flutter/widgets.dart';
//import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:unplugg_prototype/core/interrupts.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';

void main() {

  InterruptsManager interruptsManager;

  setUp(() {
    interruptsManager = InterruptsManager();
  });

  group('interrupt events', () {

    test('exit emits interrupt immediately', () async {
      final StreamQueue<InterruptEvent> queue =
        StreamQueue<InterruptEvent>(interruptsManager.onInterruptEvent);

      interruptsManager.addPhoneEventState(PhoneState.exiting);
      expect(await queue.next, allOf(
        isA<InterruptEvent>(),
        predicate<InterruptEvent>((evt) => evt.failImmediate)
      ));
    });

    test('lock then resume emits interrupt immediately', () async {
      final StreamQueue<InterruptEvent> queue =
      StreamQueue<InterruptEvent>(interruptsManager.onInterruptEvent);

      interruptsManager.addPhoneEventState(PhoneState.locking);
      expect(queue.eventsDispatched, 0);

      interruptsManager.addAppLifecycleState(AppLifecycleState.resumed);
      expect(await queue.next, allOf(
          isA<InterruptEvent>(),
          predicate<InterruptEvent>((evt) => evt.failImmediate)
      ));
    });

    test('unlock then pause emits interrupt immediately', () async {
      final StreamQueue<InterruptEvent> queue =
      StreamQueue<InterruptEvent>(interruptsManager.onInterruptEvent);

      interruptsManager.addPhoneEventState(PhoneState.unlocked);
      expect(queue.eventsDispatched, 0);

      interruptsManager.addAppLifecycleState(AppLifecycleState.paused);
      expect(await queue.next, allOf(
          isA<InterruptEvent>(),
          predicate<InterruptEvent>((evt) => evt.failImmediate)
      ));
    });

    test('resume does not emit interrupt', () async {
      final StreamQueue<InterruptEvent> queue =
        StreamQueue<InterruptEvent>(interruptsManager.onInterruptEvent);

      interruptsManager.addAppLifecycleState(AppLifecycleState.resumed);
      expect(queue.eventsDispatched, 0);
    });

    test('pause then lock does not emit interrupt', () async {
      final StreamQueue<InterruptEvent> queue =
      StreamQueue<InterruptEvent>(interruptsManager.onInterruptEvent);

      interruptsManager.addAppLifecycleState(AppLifecycleState.paused);
      expect(queue.eventsDispatched, 0);
      expect(interruptsManager.interruptsTimer.isActive, isTrue);

      interruptsManager.addPhoneEventState(PhoneState.locking);
      expect(queue.eventsDispatched, 0);

      interruptsManager.interruptsTimer.cancel();
    });

    test('pause checks events after delay', () async {
      final StreamQueue<InterruptEvent> queue =
      StreamQueue<InterruptEvent>(interruptsManager.onInterruptEvent);

      interruptsManager.addAppLifecycleState(AppLifecycleState.paused);
      expect(queue.eventsDispatched, 0);
      expect(interruptsManager.interruptsTimer.isActive, isTrue);

      expect(await queue.next, allOf(
          isA<InterruptEvent>(),
          predicate<InterruptEvent>((evt) => !evt.failImmediate)
      ));

      expect(interruptsManager.interruptsTimer.isActive, isFalse);
    });

  });
}

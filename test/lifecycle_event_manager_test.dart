
import 'dart:async';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:flutter/services.dart';
//import 'package:flutter/widgets.dart';
//import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:unplugg_prototype/core/lifecycle_event_manager.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';

void main() {

  LifecycleEventManager lifecycleEventManager;

  setUp(() {
    lifecycleEventManager = LifecycleEventManager();
  });

  group('interrupt events', () {

    test('exit emits interrupt immediately', () async {
      final StreamQueue<InterruptEvent> queue =
        StreamQueue<InterruptEvent>(lifecycleEventManager.onInterruptEvent);

      lifecycleEventManager.addPhoneEventState(PhoneState.exiting);
      expect(await queue.next, allOf(
        isA<InterruptEvent>(),
        predicate<InterruptEvent>((evt) => evt.failImmediate)
      ));
    });

    test('lock then resume emits interrupt immediately', () async {
      final StreamQueue<InterruptEvent> queue =
      StreamQueue<InterruptEvent>(lifecycleEventManager.onInterruptEvent);

      lifecycleEventManager.addPhoneEventState(PhoneState.locking);
      expect(queue.eventsDispatched, 0);

      lifecycleEventManager.addAppLifecycleState(AppLifecycleState.resumed);
      expect(await queue.next, allOf(
          isA<InterruptEvent>(),
          predicate<InterruptEvent>((evt) => evt.failImmediate)
      ));
    });

    test('unlock then pause emits interrupt immediately', () async {
      final StreamQueue<InterruptEvent> queue =
      StreamQueue<InterruptEvent>(lifecycleEventManager.onInterruptEvent);

      lifecycleEventManager.addPhoneEventState(PhoneState.unlocked);
      expect(queue.eventsDispatched, 0);

      lifecycleEventManager.addAppLifecycleState(AppLifecycleState.paused);
      expect(await queue.next, allOf(
          isA<InterruptEvent>(),
          predicate<InterruptEvent>((evt) => evt.failImmediate)
      ));
    });

    test('resume does not emit interrupt', () async {
      final StreamQueue<InterruptEvent> queue =
        StreamQueue<InterruptEvent>(lifecycleEventManager.onInterruptEvent);

      lifecycleEventManager.addAppLifecycleState(AppLifecycleState.resumed);
      expect(queue.eventsDispatched, 0);
    });

    test('pause then lock does not emit interrupt', () async {
      final StreamQueue<InterruptEvent> queue =
      StreamQueue<InterruptEvent>(lifecycleEventManager.onInterruptEvent);

      lifecycleEventManager.addAppLifecycleState(AppLifecycleState.paused);
      expect(queue.eventsDispatched, 0);
      expect(lifecycleEventManager.interruptsTimer.isActive, isTrue);

      lifecycleEventManager.addPhoneEventState(PhoneState.locking);
      expect(queue.eventsDispatched, 0);

      lifecycleEventManager.interruptsTimer.cancel();
    });

    test('pause checks events after delay', () async {
      final StreamQueue<InterruptEvent> queue =
      StreamQueue<InterruptEvent>(lifecycleEventManager.onInterruptEvent);

      lifecycleEventManager.addAppLifecycleState(AppLifecycleState.paused);
      expect(queue.eventsDispatched, 0);
      expect(lifecycleEventManager.interruptsTimer.isActive, isTrue);

      expect(await queue.next, allOf(
          isA<InterruptEvent>(),
          predicate<InterruptEvent>((evt) => !evt.failImmediate)
      ));

      expect(lifecycleEventManager.interruptsTimer.isActive, isFalse);
    });

  });
}

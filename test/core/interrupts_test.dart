
import 'dart:async';
import 'dart:ui';
//import 'package:async/async.dart';
//import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
//import 'package:flutter/widgets.dart';
import 'package:test/test.dart';
import 'package:unplugg_prototype/core/interrupts.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';

void main() {

  InterruptsMixin interruptsMixinTester;

  setUp(() {
    interruptsMixinTester = InterruptsMixinTester();
  });

  test('exit emits interrupt to fail immediately', () {
    interruptsMixinTester.addPhoneEventState(PhoneState.exiting);
    expect(
      verify(interruptsMixinTester.onInterrupt(captureThat(isA<InterruptEvent>()))).captured.single,
      predicate<InterruptEvent>((e) => e.failImmediate)
    );
  });

  test('lock then resume emits interrupt to fail immediately', () {
    interruptsMixinTester.addPhoneEventState(PhoneState.locking);
    verifyNever(interruptsMixinTester.onInterrupt((any)));

    interruptsMixinTester.addAppLifecycleState(AppLifecycleState.resumed);
    expect(
        verify(interruptsMixinTester.onInterrupt(captureThat(isA<InterruptEvent>()))).captured.single,
        predicate<InterruptEvent>((e) => e.failImmediate)
    );
  });

  test('unlock then pause emits interrupt to fail immediately', () {
    interruptsMixinTester.addPhoneEventState(PhoneState.unlocked);
    verifyNever(interruptsMixinTester.onInterrupt((any)));

    interruptsMixinTester.addAppLifecycleState(AppLifecycleState.paused);
    expect(
        verify(interruptsMixinTester.onInterrupt(captureThat(isA<InterruptEvent>()))).captured.single,
        predicate<InterruptEvent>((e) => e.failImmediate)
    );
  });

  test('resume does not emit interrupt', () {
    interruptsMixinTester.addAppLifecycleState(AppLifecycleState.resumed);
    verifyNever(interruptsMixinTester.onInterrupt((any)));
  });

  test('pause then lock does not emit interrupt', () {
    interruptsMixinTester.addAppLifecycleState(AppLifecycleState.paused);
    verifyNever(interruptsMixinTester.onInterrupt((any)));
    expect(interruptsMixinTester.interruptsTimer.isActive, isTrue);

    interruptsMixinTester.addPhoneEventState(PhoneState.locking);
    verifyNever(interruptsMixinTester.onInterrupt((any)));
    interruptsMixinTester.interruptsTimer.cancel();
  });

  test('pause emit interrupt after delay', () async {
    interruptsMixinTester.addAppLifecycleState(AppLifecycleState.paused);
    verifyNever(interruptsMixinTester.onInterrupt((any)));
    expect(interruptsMixinTester.interruptsTimer.isActive, isTrue);
    await Future.delayed(Duration(seconds:1));
    expect(
        verify(interruptsMixinTester.onInterrupt(captureThat(isA<InterruptEvent>()))).captured.single,
        predicate<InterruptEvent>((e) => !e.failImmediate)
    );
    expect(interruptsMixinTester.interruptsTimer.isActive, isFalse);
  });

}

class InterruptsMixinTester extends Mock with InterruptsMixin {}
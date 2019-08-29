
import 'dart:async';
import 'dart:ui';
//import 'package:async/async.dart';
//import 'package:flutter/services.dart';
//import 'package:mockito/mockito.dart';
//import 'package:flutter/widgets.dart';
import 'package:test/test.dart';
import 'package:unplugg_prototype/core/interrupts.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';

void main() {

  Interrupts interrupts;
  InterruptEvent capturedEvent;
  bool resumed;

  setUp(() {
    capturedEvent = null;
    resumed = false;
    interrupts = Interrupts(
      onInterrupt: (e) => capturedEvent = e,
      onResume: () => resumed = true,
    );
  });

  test('exit emits interrupt to fail immediately', () {
    interrupts.addPhoneEventState(PhoneState.exiting);
    expect(capturedEvent.failImmediate, isTrue);
  });

  test('lock then resume emits interrupt to fail immediately', () {
    interrupts.addPhoneEventState(PhoneState.locking);
    expect(capturedEvent, isNull);

    interrupts.addAppLifecycleState(AppLifecycleState.resumed);
    expect(capturedEvent.failImmediate, isTrue);
  });

  test('unlock then pause emits interrupt to fail immediately', () {
    interrupts.addPhoneEventState(PhoneState.unlocked);
    expect(capturedEvent, isNull);

    interrupts.addAppLifecycleState(AppLifecycleState.paused);
    expect(capturedEvent.failImmediate, isTrue);
  });

  test('resume does not emit interrupt', () {
    interrupts.addAppLifecycleState(AppLifecycleState.resumed);
    expect(capturedEvent, isNull);
  });

  test('pause then lock does not emit interrupt', () {
    interrupts.addAppLifecycleState(AppLifecycleState.paused);
    expect(capturedEvent, isNull);
    expect(interrupts.interruptsTimer.isActive, isTrue);

    interrupts.addPhoneEventState(PhoneState.locking);
    expect(capturedEvent, isNull);
    interrupts.interruptsTimer.cancel();
  });

  test('pause emit interrupt after delay', () async {
    interrupts.addAppLifecycleState(AppLifecycleState.paused);
    expect(capturedEvent, isNull);
    expect(interrupts.interruptsTimer.isActive, isTrue);
    await Future.delayed(Duration(seconds:1));
    expect(capturedEvent.failImmediate, isFalse);
    expect(interrupts.interruptsTimer.isActive, isFalse);
  });

}


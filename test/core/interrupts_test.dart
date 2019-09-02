
import 'dart:async';
import 'dart:ui';
//import 'package:async/async.dart';
//import 'package:flutter/services.dart';
//import 'package:mockito/mockito.dart';
//import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:unplugg_prototype/core/interrupts.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';

void main() {

  TestInterrupter interrupts;

  setUp(() {
    interrupts = TestInterrupter();
  });

  test('exit emits interrupt to fail immediately', () {
    interrupts.addPhoneEventState(PhoneState.exiting);
    expect(interrupts.capturedEvent?.failImmediate, isTrue);
  });

  test('lock then resume emits interrupt to fail immediately', () {
    interrupts.addPhoneEventState(PhoneState.locking);
    expect(interrupts.capturedEvent, isNull);

    interrupts.addAppLifecycleState(AppLifecycleState.resumed);
    expect(interrupts.capturedEvent?.failImmediate, isTrue);

  });

  test('unlock then pause emits interrupt to fail immediately', () {
    interrupts.addPhoneEventState(PhoneState.unlocked);
    expect(interrupts.capturedEvent, isNull);

    interrupts.addAppLifecycleState(AppLifecycleState.paused);
    expect(interrupts.capturedEvent?.failImmediate, isTrue);

  });

  test('resume does not emit interrupt', () {
    interrupts.addAppLifecycleState(AppLifecycleState.resumed);
    expect(interrupts.capturedEvent, isNull);
    expect(interrupts.resumeCalled, isTrue);
  });

  test('pause then lock does not emit interrupt', () {
    interrupts.addAppLifecycleState(AppLifecycleState.paused);
    expect(interrupts.capturedEvent, isNull);
    expect(interrupts.interruptsTimer.isActive, isTrue);

    interrupts.addPhoneEventState(PhoneState.locking);
    expect(interrupts.capturedEvent, isNull);
    interrupts.interruptsTimer.cancel();
  });

  test('pause emit interrupt after delay', () async {
    interrupts.addAppLifecycleState(AppLifecycleState.paused);
    expect(interrupts.capturedEvent, isNull);
    expect(interrupts.interruptsTimer.isActive, isTrue);
    await Future.delayed(Duration(seconds:1));
    expect(interrupts.capturedEvent?.failImmediate, isFalse);
    expect(interrupts.interruptsTimer.isActive, isFalse);
  });

}

class TestInterrupter with Interrupts {

  InterruptEvent _capturedEvent = null;
  bool _resumeCalled = false;

  @override
  void onInterrupt(InterruptEvent event) {
    _capturedEvent = event;
  }

  @override
  void onResume() {
    _resumeCalled = true;
  }

  InterruptEvent get capturedEvent => _capturedEvent;

  bool get resumeCalled => _resumeCalled;
}


import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/services.dart';
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
  });
}

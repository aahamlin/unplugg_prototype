
import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';

void main() {
  MockEventChannel eventChannel;
  PhoneEventService phoneEventService;

  setUp(() {
    eventChannel = MockEventChannel();
    phoneEventService = PhoneEventService.private(eventChannel);
  });


  group('phone state events', () {

    StreamController<String> controller;

    setUp(() {
      controller = StreamController<String>();
      when(eventChannel.receiveBroadcastStream())
          .thenAnswer((Invocation invoke) => controller.stream);
    });

    tearDown(() {
      controller.close();
    });

    test('calls receiveBroadcastStream once', () {
      phoneEventService.onPhoneStateChanged;
      phoneEventService.onPhoneStateChanged;
      phoneEventService.onPhoneStateChanged;
      verify(eventChannel.receiveBroadcastStream()).called(1);
    });

    test('phone event states', () async {
      final StreamQueue<PhoneState> queue =
          StreamQueue<PhoneState>(phoneEventService.onPhoneStateChanged);

      controller.add('exiting');
      expect(await queue.next, PhoneState.exiting);

      controller.add('locking');
      expect(await queue.next, PhoneState.locking);

      controller.add('unlocked');
      expect(await queue.next, PhoneState.unlocked);

      controller.add('unknown');
      expect(queue.next, throwsArgumentError);
    });
  });
}

class MockEventChannel extends Mock implements EventChannel {}

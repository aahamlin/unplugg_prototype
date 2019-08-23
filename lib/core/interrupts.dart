import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'services/phone_event/phone_event_service.dart';

//Events
//P pause
//R resume
//L locking
//U unlocked
//E exiting
enum Event {
  P,
  R,
  L,
  U,
  E,
}

class InterruptEvent {
  final String name; // event name for debugging
  final bool failImmediate;
  InterruptEvent({this.name, this.failImmediate = false});
}
class InterruptsManager {

  StreamController<InterruptEvent> _controller =
    StreamController<InterruptEvent>();

  Stream<InterruptEvent> _onSessionInterrupt;

  Stream<InterruptEvent> get onInterruptEvent => _controller.stream;

  Event previous;
  Event current;
  Timer _stateTimer;

  void _recordEvent(Event e) {
    previous = current;
    current = e;
    _calculate();
  }


  //States
  //P + L = ok
  //? + R = ok
  //L + R = fail (other app unlocked) (immediate)
  //U + P = fail (immediate)
  //P + !LR = fail (ought to warn user)
  //E = fail (immediate)
  List<Event> pauseInterrupts = [Event.P, Event.U, Event.E];
  void _calculate() {
    debugPrint('$previous $current');
    if (current == Event.E) {
      _controller.sink.add(InterruptEvent(name: 'E', failImmediate: true));
    }
    else if (previous == Event.L && current == Event.R) {
      _controller.sink.add(InterruptEvent(name: 'LR', failImmediate: true));
    }
    else if (previous == Event.U && current == Event.P) {
      _controller.sink.add(InterruptEvent(name: 'UP', failImmediate: true));
    }
    else if (current == Event.P) {
      debugPrint('timer scheduling due to pause');
      _stateTimer = Timer(Duration(seconds: 1), () {
        debugPrint('timer fired: $previous$current');
        if (current == Event.P) {
          var name = previous != null ? (describeEnum(previous) + 'P') : 'P';
          _controller.sink.add(InterruptEvent(name: name));
        }
      });
    }
  }

  @protected
  @visibleForTesting
  Timer get interruptsTimer => _stateTimer;

  void addAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.paused) {
      _recordEvent(Event.P);
    }
    else if (state == AppLifecycleState.resumed) {
      _recordEvent(Event.R);
    }
  }


  void addPhoneEventState(PhoneState state) {
    if(state == PhoneState.exiting) {
      _recordEvent(Event.E);
    }
    else if(state == PhoneState.locking) {
      _recordEvent(Event.L);
    }
    else if(state == PhoneState.unlocked) {
      _recordEvent(Event.U);
    }
  }

}
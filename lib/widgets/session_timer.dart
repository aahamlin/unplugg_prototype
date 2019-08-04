import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:unplugg_prototype/data/models.dart';
import 'package:unplugg_prototype/shared/phone_event_observer.dart';
import 'package:unplugg_prototype/shared/phone_event_model.dart';
import 'timer_text.dart';

class SessionTimer extends StatefulWidget {
  final Duration duration;
  final Function onComplete;
  final Function(Event) onEvent;
  SessionTimer({Key key,
    Duration this.duration,
    Function this.onComplete,
    Function(Event) this.onEvent}) : super(key: key);

  @override
  _SessionTimerState createState() => _SessionTimerState();

}

class _SessionTimerState extends State<SessionTimer> with WidgetsBindingObserver, PhoneEventObserver {

  Timer _timer;
  Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(new Duration(seconds: 1), callback);
    _stopwatch = Stopwatch();
    _stopwatch.start();
    WidgetsBinding.instance.addObserver(this);
    PhoneEventService.instance.addObserver(this);
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    PhoneEventService.instance.removeObserver(this);
    _timer.cancel();
    _stopwatch.reset();

    super.dispose();
  }

  void callback(Timer timer) {
    if (_stopwatch.elapsed >= widget.duration) {
      _timer.cancel();
      _stopwatch.stop();
      widget.onComplete();
    }
    setState(() {

    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    widget.onEvent(Event(eventType: describeEnum(state), timeStamp: DateTime.now()));
  }


  @override
  void onPhoneEvent(PhoneEventModel phoneEvent) {
    widget.onEvent(Event(eventType: describeEnum(phoneEvent.state), timeStamp: phoneEvent.dateTime));
  }

  Duration get timeRemaining {
    return widget.duration - _stopwatch.elapsed;
  }

  @override
  Widget build(BuildContext context) {
    return TimerText(duration: timeRemaining);
  }
}
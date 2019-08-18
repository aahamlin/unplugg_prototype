import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unplugg_prototype/core/shared/log_manager.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_observer.dart';
import 'timer_text.dart';

class SessionTimer extends StatefulWidget {
  final Duration duration;
  final Function onSessionWarn;
  final Function onSessionClear;
  final Function onComplete;
  SessionTimer({Key key,
    Duration this.duration,
    Function this.onSessionWarn,
    Function this.onSessionClear,
    Function this.onComplete}) : super(key: key);

  @override
  _SessionTimerState createState() => _SessionTimerState();

}

class _SessionTimerState extends State<SessionTimer> with WidgetsBindingObserver, PhoneEventObserver  {

  Timer _timer;
  Stopwatch _stopwatch;

  final _logger = LogManager.getLogger('SessionTimerState');

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
    _timer.cancel();
    _stopwatch.reset();
    WidgetsBinding.instance.removeObserver(this);
    PhoneEventService.instance.removeObserver(this);
    super.dispose();
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.i('applifecycle state change: $state');
    // on pause, set expiry on run table and notification
    if (state == AppLifecycleState.paused) {;
      widget.onSessionWarn();
    }
    // on resume, cancel expiry on run table and clear notification
    if (state == AppLifecycleState.resumed) {
      widget.onSessionClear();
    }
  }


  @override
  void onPhoneEvent(PhoneEventModel phoneEvent) {
    _logger.i('phoneevent state change: ${phoneEvent.state}');
    // on unlock, set expiry on run table and notification
    if (phoneEvent.state == PhoneEventState.unlocked) {
      widget.onSessionWarn();
    }

    // on lock, (within notification window?), cancel expiry on run table and clear notification
    if (phoneEvent.state == PhoneEventState.locking) {
      widget.onSessionClear();
    }
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

  Duration get timeRemaining {
    return widget.duration - _stopwatch.elapsed;
  }

  @override
  Widget build(BuildContext context) {
    return TimerText(duration: timeRemaining);
  }
}
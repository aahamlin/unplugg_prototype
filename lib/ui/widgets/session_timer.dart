import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unplugg_prototype/core/lifecycle_event_manager.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';
import 'timer_text.dart';

class SessionTimer extends StatefulWidget {
  final Duration duration;
  final Function onComplete;
  final Function(InterruptEvent) onInterrupt;
  SessionTimer({Key key,
    @required this.duration,
    @required this.onComplete,
    @required this.onInterrupt}) : super(key: key);

  @override
  _SessionTimerState createState() => _SessionTimerState();

}

class _SessionTimerState extends State<SessionTimer> with WidgetsBindingObserver {

  Timer _timer;
  Stopwatch _stopwatch;
  PhoneEventService _phoneEventService;
  LifecycleEventManager _lifecycleEventManager;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(new Duration(seconds: 1), callback);
    _stopwatch = Stopwatch();
    _stopwatch.start();
    _phoneEventService = PhoneEventService();
    _lifecycleEventManager = LifecycleEventManager();
    WidgetsBinding.instance.addObserver(this);

    _phoneEventService.onPhoneStateChanged.listen(
        _lifecycleEventManager.addPhoneEventState);

    _lifecycleEventManager.onInterruptEvent.listen(
        widget.onInterrupt);
  }


  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.reset();
    _phoneEventService = null;
    _lifecycleEventManager = null;
    WidgetsBinding.instance.removeObserver(this);
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

  Duration get timeRemaining {
    return widget.duration - _stopwatch.elapsed;
  }

  @override
  Widget build(BuildContext context) {
    return TimerText(duration: timeRemaining);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleEventManager.addAppLifecycleState(state);
  }
}
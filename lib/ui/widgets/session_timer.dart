import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unplugg_prototype/core/interrupts.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';
import 'timer_text.dart';

class SessionTimer extends StatefulWidget {
  final Duration duration;
  final Function(InterruptEvent) onInterrupt;
  final Function onResume;
  final Function onComplete;

  SessionTimer({Key key,
    @required this.duration,
    @required this.onInterrupt,
    @required this.onResume,
    @required this.onComplete}) : super(key: key);

  @override
  _SessionTimerState createState() => _SessionTimerState();

}

class _SessionTimerState extends State<SessionTimer> with WidgetsBindingObserver {

  Timer _timer;
  Stopwatch _stopwatch;
  PhoneEventService _phoneEventService;
  StreamSubscription<PhoneState> _subscription;
  Interrupts _interrupts;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(new Duration(seconds: 1), callback);
    _stopwatch = Stopwatch();
    _stopwatch.start();
    _interrupts = Interrupts(
      onInterrupt: widget.onInterrupt,
      onResume: widget.onResume
    );
    _phoneEventService = PhoneEventService();
    _subscription = _phoneEventService.onPhoneStateChanged.listen(
        _interrupts.addPhoneEventState);
    WidgetsBinding.instance.addObserver(this);
  }


  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.reset();
    _subscription.cancel();
    _phoneEventService = null;
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
    _interrupts.addAppLifecycleState(state);
  }
}
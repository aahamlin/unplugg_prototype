import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/core/interrupts.dart';
import 'package:unplugg_prototype/core/services/phone_event/phone_event_service.dart';
import 'timer_text.dart';

class SessionTimer extends StatefulWidget {
  final SessionStateBloc bloc;
  final Session session;

  SessionTimer({
    Key key,
    @required this.session,
    @required this.bloc,
  })  : assert(bloc != null),
        assert(session != null),
        super(key: key);

  @override
  _SessionTimerState createState() => _SessionTimerState();
}

class _SessionTimerState extends State<SessionTimer>
    with WidgetsBindingObserver, Interrupts {
  Timer _timer;
  Stopwatch _stopwatch;
  PhoneEventService _phoneEventService;
  StreamSubscription<PhoneState> _subscription;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(new Duration(seconds: 1), callback);
    _stopwatch = Stopwatch();
    _stopwatch.start();
    _phoneEventService = PhoneEventService();
    _subscription =
        _phoneEventService.onPhoneStateChanged.listen(this.addPhoneEventState);
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
    if (timeRemaining.isNegative) {
      _timer.cancel();
      _stopwatch.stop();
      widget.bloc.complete(widget.session);
    }
    setState(() {});
  }

  Duration get timeRemaining {
    return widget.session.duration - _stopwatch.elapsed;
//    return widget.session.endTime.difference(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return TimerText(duration: timeRemaining);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.addAppLifecycleState(state);
  }

  @override
  void onInterrupt(InterruptEvent event) {
    if (event.failImmediate) {
      widget.bloc.fail(widget.session);
    } else {
      widget.bloc.interrupt(widget.session);
    }
    setState(() {});
  }

  @override
  void onResume() {
    widget.bloc.resume(widget.session);
    setState(() {});
  }
}

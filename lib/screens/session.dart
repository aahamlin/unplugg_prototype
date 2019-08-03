import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models.dart';
import 'package:unplugg_prototype/services/phone_event_observer.dart';
import 'package:unplugg_prototype/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/widgets/timer.dart';

class SessionPage extends StatelessWidget {

  final Duration duration;
  SessionPage({Key key, Duration this.duration}) : super(key: key);

  @override Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Session'),
      ),
      body: ProxyProvider<DBProvider, SessionModelBloc>(
        builder: (context, dbProvider, bloc) => SessionModelBloc(
          dbProvider: dbProvider,
          duration: duration,
        ),
        child: Consumer<SessionModelBloc>(
          builder: (context, bloc, child) {
            return StreamBuilder<SessionModel>(
              stream: bloc.sessionModel,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var model = snapshot.data;

                  if (model.state == SessionState.completed) {
                    return Center(
                      child: Text('You earned ${model.duration.inMinutes} moment(s).'),
                    );
                  }
                  else if (model.state == SessionState.cancelled) {
                    return Center(
                      child: Text('Sorry, you did not earn ${model.duration.inMinutes} moment(s).'),
                    );
                  }
                  else {
                    return WillPopScope(
                      onWillPop: () => _onWillPopScope(context, model, (model) => bloc.cancel(model)),
                      child: Center(
                        child: SessionTimer(
                          duration: calculateDurationSinceStartTime(model.startTime, model.duration),
                          onComplete: () => bloc.complete(model),
                          onEvent: (event) => bloc.record(model, event),
                        ),
                      ),
                    );
                  }
                }
                else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPopScope(BuildContext context, SessionModel model, Function(SessionModel) cancelCallback) async {
    return showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('End Your Unplugg Session?'),
          content: Text('You are close to earning ${model.duration.inMinutes} moments.'),
          actions: <Widget>[
            FlatButton(
                onPressed: () async {
                  Navigator.of(context).pop(false);
                },
                child: const Text('NO')
            ),
            FlatButton(
              onPressed: () async {
                await cancelCallback(model);
                Navigator.of(context).pop(true);
              },
              child: const Text('YES'),
            )
          ],
        );
      },
    );
  }
}

Duration calculateDurationSinceStartTime(DateTime startTime, Duration totalDuration) {
  var now = DateTime.now();
  assert(startTime.isBefore(now));// cannot start in the future
  var remainingDuration = totalDuration;
  if(now.isAfter(startTime)) {
    remainingDuration -= now.difference(startTime);
  }
  return remainingDuration;
}


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
  void onPhoneEvent(PhoneEvent phoneEvent) {
    widget.onEvent(Event(eventType: describeEnum(phoneEvent.name), timeStamp: phoneEvent.dateTime));
  }

  Duration get timeRemaining {
    return widget.duration - _stopwatch.elapsed;
  }

  @override
  Widget build(BuildContext context) {
    return TimerText(duration: timeRemaining);
  }
}
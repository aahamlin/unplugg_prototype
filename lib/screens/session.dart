import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/bloc/session_state_bloc.dart';

class SessionPage extends StatelessWidget {

  SessionPage({Key key}) : super(key: key);

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Session'),
      ),
      body: Consumer<SessionStateBloc>(
        builder: (context, bloc, child) {
          return StreamBuilder<SessionModel>(
            stream: bloc.session,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var model = snapshot.data;
                if (model.state == SessionState.completed) {
                  return Center(
                    child: Text('SUCCESS'),
                  );
                }
                else if (model.state == SessionState.cancelled) {
                  return Center(
                    child: Text('CANCELLED'),
                  );
                }
                else {
                  return WillPopScope(
                    onWillPop: () => _onWillPopScope(context, model),
                    child: Center(
                      child: SessionTimer(
                        duration: calculateDurationSinceStartTime(model.startTime, model.duration),
                        onComplete: () => bloc.complete(model),
                      ),
                    ),
                  );
                }
              }
              // no state, return waiting indicator
              return CircularProgressIndicator();
            },
          );
        },
      ),
    );
  }

  Future<bool> _onWillPopScope(BuildContext context, SessionModel model) async {
    return showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('End Your Unplugg Session?'),
          content: const Text('You will forfeit these moments.'),
          actions: <Widget>[
            FlatButton(
                onPressed: () async {
                  Navigator.of(context).pop(false);
                },
                child: const Text('NO')
            ),
            FlatButton(
              onPressed: () async {
                Provider.of<SessionStateBloc>(context).cancel(model);
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

class TimerTextFormatter {
  static String format(Duration duration) {
    assert(duration != null);
    int hours = duration.inHours;
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds;

    String hoursStr = (hours % 24).toString().padLeft(1, '0');
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$hoursStr.$minutesStr:$secondsStr";
  }
}

class TimerText extends StatelessWidget {
  final Duration duration;
  TimerText({Key key, Duration this.duration}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(TimerTextFormatter.format(duration),
      style: Theme.of(context).textTheme.display1.merge(TextStyle(color: Colors.green))
    );
  }
}

class SessionTimer extends StatefulWidget {
  final Duration duration;
  final Function onComplete;
  SessionTimer({Key key, Duration this.duration, Function this.onComplete}) : super(key: key);

  @override
  _SessionTimerState createState() => _SessionTimerState();


}

class _SessionTimerState extends State<SessionTimer> {

  Timer _timer;
  Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(new Duration(seconds: 1), callback);
    _stopwatch = Stopwatch();
    _stopwatch.start();

  }

  @override
  void dispose() {
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

  Duration get timeRemaining {
    return widget.duration - _stopwatch.elapsed;
  }

  @override
  Widget build(BuildContext context) {
    return TimerText(duration: timeRemaining);
  }
}
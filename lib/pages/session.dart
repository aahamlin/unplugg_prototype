import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models.dart';
import 'package:unplugg_prototype/viewmodel/session.dart';

class SessionPage extends StatelessWidget {

  final Session session;

  SessionPage({Key key, Session this.session}) : super(key: key);

  @override Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<DBProvider, SessionViewModel>(
      builder: (context, dbProvider, _) => SessionViewModel(
        dbProvider: dbProvider,
        session: session,
      ),
      child: Consumer<SessionViewModel>(
        builder: (context, model, _) {
          if (model.state == SessionState.completed) {
            return Scaffold(
                appBar: AppBar(
                  title: Text("Session"),
                ),
                body: Center(child: Text('SUCCESS')),
            );
          }
          return WillPopScope(
            onWillPop: () => _onWillPopScope(context, model),
            child: Scaffold(
              appBar: AppBar(
                title: Text("Session"),
              ),
              body: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26, width: 3.0),
                ),
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(8.0),
                child: Center(

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text('Session: ${model}'),
                      Spacer(),
                      SessionTimer(
                          duration: model.duration,
                          onSuccess: (bool) => model.setState(SessionState.completed)),
                      Container(
                        alignment: Alignment.topLeft,
                        child: ListView.builder(
                          itemCount: model.events.length,
                          itemBuilder: (context, int) {
                            return Container(
                                height: 50,
                                child: Text(
                                    'Event ${int}: ${model.events[int]}')
                            );
                          },
                          shrinkWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }


  Future<bool> _onWillPopScope(BuildContext context, SessionViewModel model) async {
    print("onWillPopScope");
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
                //Provider.of<SessionBloc>(context).deleteAll();
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
  final Function(bool) onSuccess;
  SessionTimer({Key key, Duration this.duration, Function(bool) this.onSuccess}) : super(key: key);

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
      widget.onSuccess(true);
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
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/services/phone_event_observer.dart';
//import 'package:unplugg_prototype/blocs/session_bloc.dart';
import 'package:unplugg_prototype/data/models.dart';


class SessionPage extends StatelessWidget {

  final Map<String, dynamic> config;

  SessionPage({Key key, Map<String, dynamic> this.config}) : super(key: key);

  @override Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<DBProvider, SessionViewModel>(
      builder: (context, dbProvider, _) => SessionViewModel(
        dbProvider: dbProvider,
        session: config['session'],
      ),
      child: Consumer<SessionViewModel>(
        builder: (context, model, _) {

//          if (model.isSuccess) {
//            Navigator.pushReplacementNamed(context, '/success');
//            return Center(child: Text('SUCCESS'));
//          }

          // todo: write a widget for the session page view that handles the success case
          return WillPopScope(
            onWillPop: () => _onWillPopScope(context, model),
            child: Scaffold(
              appBar: AppBar(
                title: Text("Session"),
              ),
              body: Center(
                child: Column(
                  children: <Widget>[
                    Text('Session: ${model.session}'),
                    Text(TimerTextFormatter.format(model.timeRemaining)),
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

class SessionViewModel extends ChangeNotifier with WidgetsBindingObserver, PhoneEventObserver {

  DBProvider _dbProvider;
  Session _session;

  // NOTE Temporary until DB refactor
  List<Event> _events = List<Event>();

  Timer _timer;
  Stopwatch _stopwatch;

  bool _success = false;

  SessionViewModel({@required DBProvider dbProvider, @required Session session}) {
    _dbProvider = dbProvider;
    _session = session;
    _timer = Timer.periodic(new Duration(seconds: 1), callback);
    _stopwatch = Stopwatch();
    _stopwatch.start();

    WidgetsBinding.instance.addObserver(this);
    PhoneEventService.instance.addObserver(this);
  }

  @override
  void dispose() {
    print("SessionViewModel disposing");

    WidgetsBinding.instance.removeObserver(this);
    PhoneEventService.instance.removeObserver(this);

    _timer.cancel();
    _stopwatch.reset();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //print('widget binding state change: ${describeEnum(state)}');
    var event = Event(eventType: describeEnum(state), timeStamp: DateTime.now());
    //_bloc.addEvent(event);
    _events.add(event);
    notifyListeners();
  }


  @override
  void onPhoneEvent(PhoneEvent phoneEvent) {
    //print('phone event: ${phoneEvent}');
    var event = Event(eventType: describeEnum(phoneEvent.name), timeStamp: phoneEvent.dateTime);
    //_bloc.addEvent(event);
    _events.add(event);
    notifyListeners();
  }

  void callback(Timer timer) {
    if (_stopwatch.elapsed >= _session.duration) {
      _timer.cancel();
      _stopwatch.stop();
      _success = true;
    }
    notifyListeners();
  }

  Session get session => _session;
  List<Event> get events => _events;
  bool get isSuccess => _success;

  Duration get timeRemaining {
    var remaining =  _session.duration - _stopwatch.elapsed;
    return remaining;
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

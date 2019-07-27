import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unplugg_prototype/services/phone_event_observer.dart';
import 'package:unplugg_prototype/blocs/session_bloc.dart';
import 'package:unplugg_prototype/data/models/session.dart';


class SessionPage extends StatelessWidget {
  SessionPage({Key key, Map<String, dynamic> this.config}) : super(key: key);
  final Map<String, dynamic> config;

  Future<bool> _onWillPopScope(BuildContext context) async {
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

  @override Widget build(BuildContext context) {

    int durationMins = config['sessionDuration'] as int;

    SessionBloc bloc = Provider.of<SessionBloc>(context);
    bloc.startSession(durationMins);
    print('started session ${durationMins}');

    return WillPopScope(
        child: Container(
          child: SessionEventObserver(bloc: bloc),
        ),
        onWillPop: () => _onWillPopScope(context));
  }
}


class SessionEventObserver extends StatefulWidget {
  SessionEventObserver({Key key, @required SessionBloc this.bloc}) : super(key: key);
  final SessionBloc bloc;

  @override _SessionEventObserverState createState() => _SessionEventObserverState();
}

class _SessionEventObserverState extends State<SessionEventObserver> with WidgetsBindingObserver, PhoneEventObserver  {


  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    PhoneEventService.instance.addObserver(this);
    print('session page initialized');
  }

  @override void dispose() {
    print('session page disposing');
    WidgetsBinding.instance.removeObserver(this);
    PhoneEventService.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('widget binding state change: ${state.toString()}');
    //widget.eventBloc.newEvent(state.toString());
  }


  @override
  void onPhoneEvent(String event) {
    print('phone event: ${event}');
    //widget.eventBloc.newEvent(event);
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text("Session"),
      ),
      body: StreamBuilder<Session>(
        stream: widget.bloc.sessions, // todo: rename
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var session = snapshot.data;
            return Center(child:
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text('Session id: ${session.id}'),
                  Text('Started at ${session.startTime().toIso8601String()}'),
                  Text('Duration: ${session.duration} minutes'),
                ],
              )
            );
          }
          else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString(),
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)));
          }
          else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
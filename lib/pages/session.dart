import 'package:flutter/material.dart';
import 'package:unplugg_prototype/services/phone_event_observer.dart';

class SessionPage extends StatefulWidget {
  SessionPage({Key key}) : super(key: key);

  @override _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> with WidgetsBindingObserver, PhoneEventObserver  {


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
      body: new Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("New Session", style: Theme.of(context).textTheme.title,),
              FlatButton(
                color: Theme.of(context).buttonColor,
                child: Text("Back"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          )
        )
      ),
    );
  }
}
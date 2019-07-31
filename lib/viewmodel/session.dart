import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models.dart';

import 'package:unplugg_prototype/services/phone_event_observer.dart';
//import 'package:unplugg_prototype/blocs/session_bloc.dart';


class SessionViewModel extends ChangeNotifier with WidgetsBindingObserver, PhoneEventObserver {

  DBProvider _dbProvider;
  Session _session;

  bool _success = false;

  SessionViewModel({@required DBProvider dbProvider, @required Session session}) {
    _dbProvider = dbProvider;
    _session = session;

    WidgetsBinding.instance.addObserver(this);
    PhoneEventService.instance.addObserver(this);

    startSession();
  }

  @override
  void dispose() {
    print("SessionViewModel disposing");

    WidgetsBinding.instance.removeObserver(this);
    PhoneEventService.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //print('widget binding state change: ${describeEnum(state)}');
    var event = Event(eventType: describeEnum(state), timeStamp: DateTime.now());
    addEvent(event);
  }


  @override
  void onPhoneEvent(PhoneEvent phoneEvent) {
    //print('phone event: ${phoneEvent}');
    var event = Event(eventType: describeEnum(phoneEvent.name), timeStamp: phoneEvent.dateTime);
    addEvent(event);
  }

  void setSuccess(bool isSuccess) {
    _success = isSuccess;
    notifyListeners();
  }

  Session get session => _session;
  bool get isSuccess => _success;


  void startSession() async {
    await _dbProvider.insertSession(_session);
  }

  void addEvent(Event event) async {
    _session = await _dbProvider.insertSessionEvent(session, event);
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models.dart';

import 'package:unplugg_prototype/services/phone_event_observer.dart';
//import 'package:unplugg_prototype/blocs/session_state_bloc.dart';

enum SessionState {
  pending,
  running,
  completed,
  error,
}

class SessionService {
  final DBProvider dbProvider;
  SessionService(this.dbProvider);


  Future<Session> startSession(Session session) async {
    return await dbProvider.insertOrUpdateSession(session);
  }

  Future<Session> updateSession(Session session) async {
    return await dbProvider.insertOrUpdateSession(session);
  }

  Future<Session> addEventToSession(Session session, Event event) async {
    return await dbProvider.insertSessionEvent(session, event);
  }
}

class SessionViewModel extends ChangeNotifier with WidgetsBindingObserver, PhoneEventObserver {

  SessionService _service;
  Session _session;
  SessionState _state = SessionState.pending;

  SessionViewModel({@required DBProvider dbProvider, @required Session session}) {
    _session = session;
    _service = SessionService(dbProvider);
    WidgetsBinding.instance.addObserver(this);
    PhoneEventService.instance.addObserver(this);

    // handles returning to app from local notification
    _service.startSession(session).then((session) {
      _state = SessionState.running;
      setSession(session);
    });
  }

  void setSession(Session session) {
    _session = session;
    notifyListeners();
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
    _service.addEventToSession(_session, event).then((session) => setSession(session));
  }


  @override
  void onPhoneEvent(PhoneEvent phoneEvent) {
    //print('phone event: ${phoneEvent}');
    var event = Event(eventType: describeEnum(phoneEvent.name), timeStamp: phoneEvent.dateTime);
    _service.addEventToSession(_session, event).then((session) => setSession(session));

  }

  void setState(SessionState newState) {
    var session = _session;
    _state = newState;
    _service.updateSession(session).then((session) => setSession(session));
    notifyListeners();
  }

  Duration get duration => _session.duration;
  SessionState get state => _state;
  List<Event> get events => _session.events;

  @override
  toString() {
    return _session.toString();
  }
}

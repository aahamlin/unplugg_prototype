import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

import './bloc_provider.dart';
import '../database.dart';
import '../models/event.dart';

class EventBloc implements BlocBase {
  final _eventController = StreamController<List<Event>>.broadcast();
  //final StreamController<List<Event>> _eventController;

  // output stream
  Stream<List<Event>> get events => _eventController.stream;

  final DBProvider _db;

  EventBloc(this._db/*this._eventController*/) {
    //getEvents();
    print('constructing EventBloc with ${_eventController.toString()}');
  }

  @override
  void dispose() {
    print('event bloc dispose');
    _eventController.close();
  }

/*  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    newEvent(state.toString());
    print('print ' + state.toString());
    debugPrint('debugPrint ' + state.toString());
    log('log ' + state.toString());
//    // todo: put in main.dart, probably?
//    if (state == AppLifecycleState.paused) {
//      DBProvider.db.close();
//      print("app paused, closed db");
//    }
  }
*/

  getEvents() async {
    print('event bloc calling for all events');
    //List<Event> events = await DBProvider.db.getAllUnpluggEvents();
    List<Event> events = await _db.getAllUnpluggEvents();
    print('event bloc adding ${events.length} events to sink');
    _eventController.sink.add(events);
  }

  delete(int id) async {
    //DBProvider.db.deleteUnpluggEvent(id);
    _db.deleteUnpluggEvent(id);
    getEvents();
  }

  newEvent(String event_type) async {
    Event event = Event(
      eventType: event_type,
      timeStamp: DateTime.now(),
    );
    //DBProvider.db.newUnpluggEvent(event);
    _db.newUnpluggEvent(event);
    getEvents();
  }
/*
  _handleNewEvent(String event_type) {
    UnpluggEvent event = UnpluggEvent(
      eventType: event_type,
      timeStamp: DateTime.now(),
    );

    DBProvider.db.newUnpluggEvent(event);
    print("platform event_type: $event_type");
    getEvents();
  }

  _handleError(e) {
    UnpluggEvent event = UnpluggEvent(
      eventType: "error",
      timeStamp: DateTime.now(),
    );
    DBProvider.db.newUnpluggEvent(event);
    print("platform error: $e");
    return "error";
  }
  */
}

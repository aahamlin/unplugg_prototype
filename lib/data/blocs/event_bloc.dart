import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unplugg_prototype/data/blocs/bloc_provider.dart';
import 'package:unplugg_prototype/data/database.dart';

class EventBloc with WidgetsBindingObserver implements BlocBase {
  final _eventController = StreamController<List<EventModel>>.broadcast();

  // output stream
  Stream<List<EventModel>> get events => _eventController.stream;

  EventBloc() {
    getEvents();
  }

  @override
  void dispose() {
    _eventController.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    newEvent(state.toString());
  }

  getEvents() async {
    List<EventModel> events = await DBProvider.db.getAllUnpluggEvents();
    _eventController.sink.add(events);
  }

  delete(int id) async {
    DBProvider.db.deleteUnpluggEvent(id);
    getEvents();
  }

  newEvent(String event_type) async {
    EventModel event = EventModel(
      eventType: event_type,
      timeStamp: DateTime.now(),
    );
    DBProvider.db.newUnpluggEvent(event);
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

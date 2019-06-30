import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unplugg_prototype/data/blocs/bloc_provider.dart';
import 'package:unplugg_prototype/data/database.dart';

class EventBloc with WidgetsBindingObserver implements BlocBase {
  final _eventController = StreamController<List<UnpluggEvent>>.broadcast();

  // output stream
  Stream<List<UnpluggEvent>> get events => _eventController.stream;

  EventBloc() {
    getEvents();
  }

  @override
  void dispose() {
    _eventController.close();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _addWidgetEvent(state.toString());
  }

  getEvents() async {
    List<UnpluggEvent> events = await DBProvider.db.getAllUnpluggEvents();
    _eventController.sink.add(events);
  }

  delete(int id) async {
    DBProvider.db.deleteUnpluggEvent(id);
    getEvents();
  }

  _addWidgetEvent(String event_type) async {
    UnpluggEvent event = UnpluggEvent(
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

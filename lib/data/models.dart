import 'package:flutter/material.dart';

final String tableSession = "unplugg_session";
final String columnSessionId = "session_id";
final String columnEventFK = "event_fk";
final String columnDuration = "session_duration";

final String tableEvent = "unplugg_event";
final String columnEventId = "event_id";
final String columnEventType = "event_type";
final String columnTimestamp = "event_timestamp";

final String tableSessionEvent = "unplugg_session_event";
final String columnSessionEventId = "id";

class Session {

  int id;
  Duration duration;
  // event table
  int eventId;
  Event event;

  List<Event> events = List<Event>();

  /**
   * Transform Object to Map for Database inserts
   * return map
   */
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDuration: duration.inMilliseconds,
      columnEventFK: eventId,
    };
    if (id != null) {
      map[columnSessionId] = id;
    }
    return map;
  }

  Session({
    this.id,
    @required this.duration,
    this.eventId,
  });

  /**
   * Transform from Map to Object from Database queries
   */
  Session.fromMap(Map<String, dynamic> map) {
    id = map[columnSessionId];
    duration = new Duration(milliseconds: map[columnDuration]);
    eventId = map[columnEventFK];
    event = Event.fromMap(map);
    event.id = eventId;
  }

  DateTime get startTime {
    return event?.timeStamp;
  }

  @override
  toString() {
    return toMap().toString();
  }
}


class Event {

  int id;
  String eventType;
  DateTime timeStamp; // millisSinceEpoch

  /**
   * Transform Object to Map for Database inserts
   * return map
   */
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnEventType: eventType,
      columnTimestamp: timeStamp.millisecondsSinceEpoch
    };
    if (id != null) {
      map[columnEventId] = id;
    }
    return map;
  }

  Event({this.id, @required this.eventType, @required this.timeStamp});

  /**
   * Transform from Map to Object from Database queries
   */
  Event.fromMap(Map<String, dynamic> map) {
    id = map[columnEventId];
    eventType = map[columnEventType];
    timeStamp = DateTime.fromMillisecondsSinceEpoch(map[columnTimestamp]);
  }

  @override
  toString() {
    return toMap().toString();
  }
}

class SessionEvent {
  int id;
  int session_id;
  int event_id;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic> {
      columnSessionId: session_id,
      columnEventId: event_id
    };
    if (id != null) {
      map[columnSessionEventId] = id;
    }
    return map;
  }

  SessionEvent({this.id, @required this.session_id, @required this.event_id});

  SessionEvent.fromMap(Map<String, dynamic> map) {
    id = map[columnSessionEventId];
    session_id = map[columnSessionId];
    event_id = map[columnEventId];
  }

  @override
  toString() {
    return toMap().toString();
  }
}
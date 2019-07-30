import 'package:flutter/material.dart';

final String tableSession = "unplugg_session";
final String columnSessionId = "session_id";
final String columnEventFK = "event_fk";
final String columnDuration = "session_duration";

final String tableEvent = "unplugg_event";
final String columnEventId = "event_id";
final String columnEventType = "event_type";
final String columnTimestamp = "event_timestamp";


class Session {

  int id;
  Duration duration;
  // event table
  int eventId;
  Event event;


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

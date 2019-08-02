import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

final String tableSession = "session";
final String columnSessionId = "id";
final String columnDuration = "session_duration";
final String columnStartTimestamp = "start_timestamp";
final String columnFinishTimestamp = "finish_timestamp";
final String columnFinishReason = "finish_reason";

final String tableEvent = "event";
final String columnEventId = "id";
final String columnEventType = "event_type";
final String columnEventTimestamp = "event_timestamp";
final String columnEventSessionId = "session_id";

class Session {

  int id;
  Duration duration;
  DateTime startTime;
  DateTime finishTime;
  String finishReason;

  /**
   * Transform Object to Map for Database inserts
   * return map
   */
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDuration: duration.inMilliseconds,
      columnStartTimestamp: startTime?.millisecondsSinceEpoch,
      columnFinishTimestamp: finishTime?.millisecondsSinceEpoch,
      columnFinishReason: finishReason,
    };
    if (id != null) {
      map[columnSessionId] = id;
    }
    return map;
  }

  Session({
    this.id,
    @required this.duration,
    this.startTime,
    this.finishTime,
    this.finishReason,
  });

  /**
   * Transform from Map to Object from Database queries
   */
  Session.fromMap(Map<String, dynamic> map) {
    id = map[columnSessionId];
    duration = new Duration(milliseconds: map[columnDuration]);
    startTime = DateTime.fromMillisecondsSinceEpoch(map[columnStartTimestamp]);
    finishTime = DateTime.fromMillisecondsSinceEpoch(map[columnFinishTimestamp]);
    finishReason = map[columnFinishReason];
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
  int session_id;

  /**
   * Transform Object to Map for Database inserts
   * return map
   */
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnEventType: eventType,
      columnEventTimestamp: timeStamp.millisecondsSinceEpoch,
      columnEventSessionId: session_id,
    };
    if (id != null) {
      map[columnEventId] = id;
    }
    return map;
  }

  Event({this.id, @required this.eventType, @required this.timeStamp, this.session_id});

  /**
   * Transform from Map to Object from Database queries
   */
  Event.fromMap(Map<String, dynamic> map) {
    id = map[columnEventId];
    eventType = map[columnEventType];
    timeStamp = DateTime.fromMillisecondsSinceEpoch(map[columnEventTimestamp]);
    session_id = map[columnEventSessionId];
  }

  @override
  toString() {
    return toMap().toString();
  }
}

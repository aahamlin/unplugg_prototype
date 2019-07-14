import './event.dart';

final String tableUnpluggSession = "unplugg_session";
final String columnSessionId = "id";
final String columnEventFK = "event_id";
final String columnDuration = "session_duration";


class Session {

  int id;
  Duration duration;
  // event table
  int eventId;
  Event event;


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
    this.duration,
    this.eventId,
  });

  Session.fromMap(Map<String, dynamic> map) {
    id = map[columnSessionId];
    duration = new Duration(milliseconds: map[columnDuration]);
    eventId = map[columnEventFK];
    event = Event.fromMap(map);
    event.id = eventId;
  }
}

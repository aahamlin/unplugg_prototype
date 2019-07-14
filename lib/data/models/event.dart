final String tableUnpluggEvent = "unplugg_event";
final String columnEventId = "id";
final String columnEventType = "event_type";
final String columnTimestamp = "event_timestamp";

class Event {

  int id;
  String eventType;
  DateTime timeStamp; // millisSinceEpoch

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

  Event({this.id, this.eventType, this.timeStamp});

  Event.fromMap(Map<String, dynamic> map) {
    id = map[columnEventId];
    eventType = map[columnEventType];
    timeStamp = DateTime.fromMillisecondsSinceEpoch(map[columnTimestamp]);
  }
}

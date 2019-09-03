import 'package:flutter/foundation.dart';
import '../database_schema.dart';

enum SessionResult {
  none,
  success,
  failure,
  cancelled,
}

class Session {

  int id;
  Duration duration;
  DateTime startTime;
  SessionResult result;
  String reason;
  // todo add field to track the DateTime of the result (endSession)

  /**
   * Transform Object to Map for Database inserts
   * return map
   */
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDuration: duration.inMilliseconds,
      columnStart: startTime.millisecondsSinceEpoch,
      columnResult: result != SessionResult.none ? describeEnum(result) : null,
      columnReason: reason,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Session({
    this.id,
    @required this.duration,
    @required this.startTime,
    this.reason,
    this.result = SessionResult.none,
  });

  DateTime get endTime => startTime.add(duration);

  /**
   * Transform from Map to Object from Database queries
   */
  Session.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    duration = Duration(milliseconds: map[columnDuration]);
    startTime = DateTime.fromMillisecondsSinceEpoch(map[columnStart]);
    result = (map[columnResult] != null ?
      SessionResult.values.firstWhere((e) => describeEnum(e) == map[columnResult])
        : SessionResult.none);
    reason = map[columnReason];
  }

  @override
  toString() {
    var map = <String, dynamic>{
      columnDuration: duration.inMinutes,
      columnStart: startTime.toLocal().toString(),
      columnResult: describeEnum(result),
      columnReason: reason,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map.toString();
  }
}
import 'package:meta/meta.dart';
import 'package:logger/logger.dart';
import '../database_schema.dart';


final _logLevelInt = {
  Level.verbose: 0,
  Level.debug: 1,
  Level.info: 2,
  Level.warning: 3,
  Level.error: 4,
  Level.wtf: 5,
};

class LogEntry {

  int id;
  Level level;
  DateTime timeStamp;
  String message;
  String error;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnLevel: _logLevelInt[level],
      columnTimestamp: timeStamp.millisecondsSinceEpoch,
      columnMessage: message,
      columnError: error,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  LogEntry({
    this.id,
    this.level,
    this.timeStamp,
    this.message,
    this.error,
  });

  LogEntry.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    level = _logLevelInt.entries.firstWhere((e) => e.value == map[columnLevel]).key;
    timeStamp = DateTime.fromMillisecondsSinceEpoch(map[columnTimestamp]);
    message = map[columnMessage];
    error = map[columnError];
  }

  @override
  toString() {
    return toMap().toString();
  }
}
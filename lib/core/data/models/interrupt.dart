import 'package:meta/meta.dart';
import '../database_schema.dart';

class Interrupt {

  int id;
  int session_fk;
  DateTime timeout;
  bool cancelled;

  /**
   * Transform Object to Map for Database inserts
   * return map
   */
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnSessionFK: session_fk,
      columnTimeout: timeout.millisecondsSinceEpoch,
      columnCancelled: cancelled? 1: 0,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Interrupt({
    this.id,
    @required this.session_fk,
    this.timeout,
    this.cancelled = false,
  });

  /**
   * Transform from Map to Object from Database queries
   */
  Interrupt.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    session_fk = map[columnSessionFK];
    timeout = DateTime.fromMillisecondsSinceEpoch(map[columnTimeout]);
    cancelled = (map[columnCancelled] == 1 ? true : false);
  }

  @override
  toString() {
    return toMap().toString();
  }
}
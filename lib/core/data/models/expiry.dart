import 'package:flutter/foundation.dart';

import '../database_schema.dart';

class Expiry {

  int id;
  int session_fk;
  DateTime expiry;
  bool cancelled;

  /**
   * Transform Object to Map for Database inserts
   * return map
   */
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnSessionFK: session_fk,
      columnExpiry: expiry.millisecondsSinceEpoch,
      columnCancelled: cancelled? 1: 0,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Expiry({
    this.id,
    @required this.session_fk,
    this.expiry,
    this.cancelled = false,
  });

  /**
   * Transform from Map to Object from Database queries
   */
  Expiry.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    session_fk = map[columnSessionFK];
    expiry = DateTime.fromMillisecondsSinceEpoch(map[columnExpiry]);
    cancelled = (map[columnCancelled] == 1 ? true : false);
  }

  @override
  toString() {
    return toMap().toString();
  }
}
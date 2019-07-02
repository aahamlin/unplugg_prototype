import 'dart:io';
import 'package:csv/csv.dart';

import 'package:unplugg_prototype/data/database.dart';

abstract class ExporterBase<T extends ModelBase> {

  List<String> header;

  void _toRow(List<dynamic> row, T t);

  List<List<dynamic>> toList(List<T> list) {
    List<List<dynamic>> rows = new List();
    rows.add(header);
    Iterator iter = list.iterator;
    while (iter.moveNext()) {
      List<dynamic> row = new List();
      _toRow(row, iter.current);
      rows.add(row);
    }
    return rows;
  }

}

class EventExporter extends ExporterBase<EventModel> {

  List<String> header = ['id', 'eventType', 'timeStamp'];

  void _toRow(List<dynamic> row, EventModel m) {
    row.add(m.id);
    row.add(m.eventType);
    row.add(m.timeStamp);
  }
}

class SessionExporter extends ExporterBase<SessionModel> {

  List<String> header = ['id', 'startTime', 'duration'];

  void _toRow(List<dynamic> row, SessionModel m) {
    row.add(m.id);
    row.add(m.startTime);
    row.add(m.duration);
  }
}
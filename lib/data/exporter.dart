import 'dart:io';
import 'package:csv/csv.dart';

import 'package:unplugg_prototype/data/database.dart';

typedef List<dynamic> ExportToRow<T>(T result);

/**
 * given a list of model objects, return a list suitable for ListToCsvConverter
 */
List<List<dynamic>> modelToList<T> (List<T> list, List<String> header, ExportToRow callback) {
  List<List<dynamic>> rows = List();
  if (header != null) {
    rows.add(header);
  }
  Iterator<T> iterator = list.iterator;
  while(iterator.moveNext()) {
    var result = iterator.current;
    rows.add(callback(result));
  }
  return rows;
}

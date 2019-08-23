import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'package:csv/csv.dart';
import 'package:unplugg_prototype/core/data/exporter.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';

void main() {

  File tmpFile = File(p.join(Directory.systemTemp.path, "test.csv"));
  List<List<dynamic>> exportResults;

  const List<String> headers = ['id', 'duration', 'start'];

  setUp(() {
    List<Session> sessions = List();
    sessions.add(Session(id: 1, duration: Duration(minutes: 5), startTime: DateTime.now()));
    sessions.add(Session(id: 2, duration: Duration(minutes: 10), startTime: DateTime.now()));

    //EventExporter eventsExporter = EventExporter();
    //exportResults = eventsExporter.toList(events);
    exportResults = modelToList<Session>(sessions, headers, (ses) {
      List result = List();
      result.add(ses.id);
      result.add(ses.duration);
      result.add(ses.startTime);
      return result;
    });
  });

  tearDown(() {
    if(tmpFile.existsSync()) {
      tmpFile.deleteSync();
    }
  });

  test('EventsExporter.toList returns ordered entries', () {
    expect(exportResults.length, 3);
    expect(exportResults[0], headers);
    expect(exportResults[1], orderedEquals([1, isA<Duration>(), isA<DateTime>()]));
    expect(exportResults[2], orderedEquals([2, isA<Duration>(), isA<DateTime>()]));
  });
  
  test('create csv format from List', () {
    var output = const ListToCsvConverter().convert(exportResults);
    expect(output, isA<String>());
  });

  test('write csv to file', () {
    var output = const ListToCsvConverter().convert(exportResults);
    tmpFile.writeAsString(output);
    tmpFile.length().then((len) {
      expect(len, isPositive);
    });
  });
}
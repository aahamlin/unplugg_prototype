import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:csv/csv.dart';

import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/exporter.dart';

void main() {

  List<List<dynamic>> exportResults;
  File tmpFile = File(p.join(Directory.systemTemp.path, "test.csv"));

  setUp(() {
    List<EventModel> events = List();
    events.add(EventModel(id: 1, timeStamp: DateTime.now(), eventType: 'locking'));
    events.add(EventModel(id: 2, timeStamp: DateTime.now(), eventType: 'unlocked'));

    EventExporter eventsExporter = EventExporter();
    exportResults = eventsExporter.toList(events);
  });

  tearDown(() {
    if(tmpFile.existsSync()) {
      tmpFile.deleteSync();
    }
  });

  test('EventsExporter.toList returns ordered entries', () {
    expect(exportResults.length, 3);
    expect(exportResults[0], ['id', 'eventType', 'timeStamp']);
    expect(exportResults[1], orderedEquals([1, 'locking', isA<DateTime>()]));
    expect(exportResults[2], orderedEquals([2, 'unlocked', isA<DateTime>()]));
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
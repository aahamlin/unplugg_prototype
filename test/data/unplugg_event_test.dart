//import 'dart:io';

import 'package:test/test.dart';
//import 'package:path/path.dart' as p;
//import 'package:sqflite/sqflite.dart';
import 'package:unplugg_prototype/data/unplugg_event.dart';

void main() {

  setUp(() async {
    // todo: use mockito to mock the database object
    //await UnpluggEventProvider.db.setDb(testDb);
    final db = await UnpluggEventProvider.db.database;
    db.execute('''
insert into unplugg_session (session_duration, session_start_time) values (60*60*1000,1561600704000);
insert into unplugg_session (session_duration, session_start_time) values (60*60*1000,1561600756000);
insert into unplugg_event (event_type, event_timestamp) values ('lock', 1561600784000);
insert into unplugg_event (event_type, event_timestamp) values ('unlock', 1561600801000);
''');
  });
  
//  tearDown(() async {
//    UnpluggEventProvider.db.close();
//    var file = new File(testDb);
//    file.exists().then((b) {
//      file.delete();
//    });
//  });

  test('.getUnpluggEvent() returns event', () async {
    var event = await UnpluggEventProvider.db.getUnpluggEvent(1);
    expect(event.eventType, equals('lock'));
    expect(event.timeStamp, equals(DateTime.fromMillisecondsSinceEpoch(1561600784000)));
  });
}
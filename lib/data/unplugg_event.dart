// Database provider
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final String tableUnpluggEvent = "unplugg_event";
final String columnId = "_id";
final String columnEventType = "event_type";
final String columnTimestamp = "event_timestamp";

class UnpluggEvent {

  int id;
  String eventType;
  DateTime timeStamp; // millisSinceEpoch

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnEventType: eventType,
      columnTimestamp: timeStamp.millisecondsSinceEpoch
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  UnpluggEvent({
    this.id,
    this.eventType,
    this.timeStamp
  });

  UnpluggEvent.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    eventType = map[columnEventType];
    timeStamp = DateTime.fromMillisecondsSinceEpoch(map[columnTimestamp]);
  }
}

class UnpluggEventProvider {
  UnpluggEventProvider._();

  static final UnpluggEventProvider db = UnpluggEventProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    _database = await initDb();
    return _database;
  }

  initDb() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "unplugg_prototype.db");
    return await openDatabase(path,
      version: 1,
      onOpen: (db) {},
      onCreate: (Database db, int version) async {
        await db.execute('''
create table $tableUnpluggEvent ( 
  $columnId integer primary key autoincrement, 
  $columnEventType text not null,
  $columnTimestamp integer not null)
''');
      });
  }

  /**
   * insert an event
   */
  Future<UnpluggEvent> newUnpluggEvent(UnpluggEvent unpluggEvent) async {
    final db = await database;
    unpluggEvent.id = await db.insert(tableUnpluggEvent, unpluggEvent.toMap());
    return unpluggEvent;
  }

  /**
   * read an event by id
   */
  Future<UnpluggEvent> getUnpluggEvent(int id) async {
    final db = await database;
    var res = await db.query(tableUnpluggEvent,
      columns: [columnId, columnEventType, columnTimestamp],
      where: '$columnId = ?',
      whereArgs: [id]);
    return res.isNotEmpty ? UnpluggEvent.fromMap(res.first) : null;
  }

  /**
   * get all events
   */
  Future<List<UnpluggEvent>> getAllUnpluggEvents() async {
    final db = await database;
    var res = await db.query(tableUnpluggEvent);
    List<UnpluggEvent> list = res.isNotEmpty ? res.map((e) => UnpluggEvent.fromMap(e)).toList() : [];
    return list;
  }

  /**
   * delete an event by id
   */
  Future<int> deleteUnpluggEvent(int id) async {
    final db = await database;
    return db.delete(tableUnpluggEvent,
      where: '$columnId = ?',
      whereArgs: [id]);
  }

  /**
   * delete all events
   */
  Future<int> deleteAll() async {
    final db = await database;
    return db.rawDelete('delete * from $tableUnpluggEvent');
  }

  /**
   * close the connection
   */
  Future close() async {
    final db = await database;
    db.close();
  }
}

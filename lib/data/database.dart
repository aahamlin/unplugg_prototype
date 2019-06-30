// Database provider
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final String tableUnpluggEvent = "unplugg_event";
final String tableUnpluggSession = "unplugg_session";

final String columnId = "_id";

final String columnEventType = "event_type";
final String columnTimestamp = "event_timestamp";

final String columnStartTime = "session_start_time";
//final String columnEndTime = "session_end_time";
final String columnDuration = "session_duration";

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

  UnpluggEvent({this.id, this.eventType, this.timeStamp});

  UnpluggEvent.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    eventType = map[columnEventType];
    timeStamp = DateTime.fromMillisecondsSinceEpoch(map[columnTimestamp]);
  }
}

class UnpluggSession {
  int id;
  DateTime startTime;

  //DateTime endTime;
  Duration duration;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnDuration: duration.inMilliseconds,
      columnStartTime: startTime.millisecondsSinceEpoch,
      //columnEndTime: endTime != null ? endTime.millisecondsSinceEpoch : 0,
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  UnpluggSession(
      {this.id,
      this.startTime,
      //this.endTime,
      this.duration});

  UnpluggSession.fromMap(Map<String, dynamic> map) {
    id = map[columnId];
    duration = new Duration(milliseconds: map[columnDuration]);
    startTime = DateTime.fromMillisecondsSinceEpoch(map[columnStartTime]);
    //endTime = map[columnEndTime] > 0 ? DateTime.fromMillisecondsSinceEpoch(map[columnEndTime]) : null;
  }
}

class DBProvider {
  DBProvider._();

  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await initDb();
    return _database;
  }

  initDb() async {
    print("initializing db");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "unplugg_prototype.db");
    return await openDatabase(path, version: 1, onOpen: (db) async {
      await db.execute('''
create table if not exists $tableUnpluggSession (
  $columnId integer primary key autoincrement,
  $columnStartTime integer not null,
  $columnDuration integer not null);
''');
    }, onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableUnpluggEvent ( 
  $columnId integer primary key autoincrement, 
  $columnEventType text not null,
  $columnTimestamp integer not null);
  
create table $tableUnpluggSession (
  $columnId integer primary key autoincrement,
  $columnStartTime integer not null,
  $columnDuration integer not null);
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
    var res =
        await db.query(tableUnpluggEvent, orderBy: "$columnTimestamp DESC");
    List<UnpluggEvent> list =
        res.isNotEmpty ? res.map((e) => UnpluggEvent.fromMap(e)).toList() : [];
    return list;
  }

  /**
   * delete an event by id
   */
  Future<int> deleteUnpluggEvent(int id) async {
    final db = await database;
    return db
        .delete(tableUnpluggEvent, where: '$columnId = ?', whereArgs: [id]);
  }

  /**
   * delete all events
   */
  Future<int> deleteAllEvents() async {
    final db = await database;
    return db.rawDelete('delete * from $tableUnpluggEvent');
  }

  /**
   * create new session
   */
  Future<UnpluggSession> newUnpluggSession(UnpluggSession session) async {
    final db = await database;
    session.id = await db.insert(tableUnpluggSession, session.toMap());
    return session;
  }

  Future<int> deleteUnpluggSession(int id) async {
    final db = await database;
    return db
        .delete(tableUnpluggSession, where: '$columnId = ?', whereArgs: [id]);
  }

  /**
   * get most current session
   */
  Future<UnpluggSession> getUnpluggSession() async {
    final db = await database;
    var table = await db
        .rawQuery("SELECT MAX($columnId) as id FROM $tableUnpluggSession");
    int id = table.first["id"];
    var res = await db.query(tableUnpluggSession,
        columns: [columnId, columnStartTime, columnDuration],
        where: '$columnId = ?',
        whereArgs: [id]);
    return res.isNotEmpty ? UnpluggSession.fromMap(res.first) : null;
  }

  Future<List<UnpluggSession>> getAllUnpluggSessions() async {
    final db = await database;
    var res =
        await db.query(tableUnpluggSession, orderBy: "$columnStartTime DESC");
    List<UnpluggSession> list = res.isNotEmpty
        ? res.map((e) => UnpluggSession.fromMap(e)).toList()
        : [];
    return list;
  }

  /**
   * close the connection
   */
  close() async {
    final db = await database;
    db.close();
  }
}

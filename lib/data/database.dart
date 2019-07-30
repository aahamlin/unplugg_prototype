// Database provider
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:unplugg_prototype/data/models.dart';

/*

  sqlite> PRAGMA foreign_keys = ON;
sqlite> create table event (
   ...> id integer primary key autoincrement,
   ...> event_type text not null,
   ...> timestamp datetime default current_timestamp);

sqlite> create table session (
   ...> id integer primary key autoincrement,
   ...> duration integer not null,
   ...> event_id integer not null,
   ...> foreign key(event_id) references event(id));

sqlite> select s.id,s.duration,e.event_type,e.timestamp from session as s inner join event as e on s.event_id = e.id;
1|60|start_session|2019-07-03 22:43:48
2|30|start_session|2019-07-04 11:05:12

sqlite> select timestamp from event where id = (select s.event_id from session as s where s.id = 2);
2019-07-04 11:05:12

sqlite> select event_type, timestamp from event where timestamp >= (select timestamp from event where id = (select s.event_id from session as s where s.id = 2));
start_session|2019-07-04 11:05:12
inactive|2019-07-04 11:10:38
paused|2019-07-04 11:10:42
locking|2019-07-04 11:10:47

 Subquery finding all events within session duration range, including session start
sqlite> select e.event_type, e.timestamp from event e, (select timestamp from event where id = (select s.event_id from session as s where s.id = 2)) ses_start where e.timestamp >= ses_start.timestamp and e.timestamp <= datetime(ses_start.timestamp, '+10 minutes');
start_session|2019-07-04 11:05:12
inactive|2019-07-04 11:10:38
paused|2019-07-04 11:10:42
locking|2019-07-04 11:10:47
   */



class DBProvider {
  //DBProvider._();

  //static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await _setupDatabase();
    return _database;
  }


  _setupDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "unplugg_prototype.db");
    return await openDatabase(path, version: 1,
        onOpen: openDB,
        onUpgrade: upgradeDB,
        onCreate: initDB);
  }

  void openDB(Database db) async {

  }

  void upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (newVersion > oldVersion) { }
  }

  void initDB(Database db, int version) async {
    print('initDB enter');

    await db.execute('''
create table $tableEvent ( 
  $columnEventId integer primary key autoincrement, 
  $columnEventType text not null,
  $columnTimestamp integer not null);
''');
    await db.execute('''
create table $tableSession (
  $columnSessionId integer primary key autoincrement,
  $columnDuration integer not null,
  $columnEventFK integer not null,
  constraint fk_event
    foreign key($columnEventFK)
    references event($columnEventId)
    on delete cascade);
''');

  }

  /**
   * insert an event
   */
  Future<Event> insertEvent(Event event) async {
    final db = await database;
    event.id = await db.insert(tableEvent, event.toMap());
    return event;
  }

  /**
   * read an event by id
   */
  Future<Event> getEvent(int id) async {
    final db = await database;
    var res = await db.query(tableEvent,
        columns: [columnEventId, columnEventType, columnTimestamp],
        where: '$columnEventId = ?',
        whereArgs: [id]);
    return res.isNotEmpty ? Event.fromMap(res.first) : null;
  }

  /**
   * get all events
   */
  Future<List<Event>> getAllEvents() async {
    final db = await database;
    var res =
        await db.query(tableEvent, orderBy: "$columnTimestamp DESC");
    List<Event> list =
        res.isNotEmpty ? res.map((e) => Event.fromMap(e)).toList() : [];
    print('db provider returning ${list.length} items');
    return list;
  }

  /**
   * delete an event by id
   */
  Future<int> deleteEvent(int id) async {
    final db = await database;
    // foreign key constraint will need to be met
    return db
        .delete(tableEvent, where: '$columnEventId = ?', whereArgs: [id]);
  }

  /**
   * delete all events
   */
  Future<int> deleteAllEvents() async {
    final db = await database;
    return db.rawDelete('DELETE FROM "$tableEvent"; VACUUM;');
  }

  /**
   * create new session
   */
  Future<Session> insertSession(Session session) async {
    final db = await database;

    Event session_event = Event(eventType: 'session', timeStamp: DateTime.now());

    await db.transaction((txn) async {
      session_event.id = await txn.insert(tableEvent, session_event.toMap());

      session.eventId = session_event.id;
      session.id = await txn.insert(tableSession, session.toMap());

      session.event = session_event;
    });

    return session;
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return db
        .delete(tableSession, where: '$columnSessionId = ?', whereArgs: [id]);
  }

  Future<int> deleteAllSessions() async {
    final db = await database;
    return db.rawDelete('DELETE FROM "$tableSession"; VACUUM;');
  }

  Future<Session> getSession(int id) async {
    //select s.id,s.duration,e.event_type,e.timestamp from session as s inner join event as e on s.event_id = e.id;

    final db = await database;
    var res = await db.rawQuery('''
select s.$columnSessionId, s.$columnDuration, s.$columnEventFK, e.$columnEventType, e.$columnTimestamp
  from $tableSession as s inner join $tableEvent as e on s.$columnEventFK = e.$columnEventId
  where s.id = ?''', [id]);

    return res.isNotEmpty ? Session.fromMap(res.first) : null;
  }

  /**
   * get most current session
   */
//  Future<SessionModel> getUnpluggSession() async {
//    final db = await database;
//    var table = await db
//        .rawQuery("SELECT MAX($columnId) as id FROM $tableUnpluggSession");
//    int id = table.first["id"];
//    var res = await db.query(tableUnpluggSession,
//        columns: [columnId, columnStartTime, columnDuration],
//        where: '$columnId = ?',
//        whereArgs: [id]);
//    return res.isNotEmpty ? SessionModel.fromMap(res.first) : null;
//  }

  Future<List<Session>> getAllSessions() async {
    final db = await database;
    var res = await db.rawQuery('''
select s.$columnSessionId, s.$columnDuration, s.$columnEventFK, e.$columnEventType, e.$columnTimestamp
  from $tableSession as s inner join $tableEvent as e on s.$columnEventFK = e.$columnEventId;''');
    List<Session> list = res.isNotEmpty
        ? res.map((e) => Session.fromMap(e)).toList()
        : [];
    return list;
  }

  /**
   * close the connection
   */
  close() async {
    final db = await database;
    print("closing database");
    db.close();
  }
}

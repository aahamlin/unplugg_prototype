// Database provider
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:unplugg_prototype/core/data/database_schema.dart';
import 'models/session.dart';
import 'models/expiry.dart';

/*
 Random SQLite Queries

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
    await db.execute(createSessionTableSQL);
    await db.execute(createRunTableSQL);
  }

  Future<Session> getSession(int id) async {
    final db = await database;

    var res = await db.query(tableSession,
        where: '$columnId = ?',
        whereArgs: [id]);

    return res.isNotEmpty ?
      Session.fromMap(res.first) : null;
  }

  Future<Session> insertSession(Session s) async {
    final db = await database;

    s.id = await db.insert(tableSession, s.toMap());
    debugPrint('inserted ${tableSession}(${s})');
    return s;
  }

  Future<Session> getCurrentSession() async {
    final db = await database;

    var res = await db.query(tableSession,
      where: '$columnResult IS NULL');

    if(res.isNotEmpty) {
      // todo: some error situations have caused this assert, investigate
      assert(res.length == 1);// if ever more than one, there is a programming error
      return Session.fromMap(res.first);
    }
    return null;
  }

  Future<void> updateSession(Session s) async {
    final db = await database;
    // session rows only update when finished
    int count = await db.update(
      tableSession, s.toMap(),
      where: '$columnId = ?',
      whereArgs: [s.id]);
    debugPrint('updated $count rows: ${tableSession}(${s})');
  }

  Future<void> deleteExpiry(int session_id) async {
    final db = await database;
    // once updated, delete the run table entries
    int count = await db.delete(tableRunExpiry,
        where: '$columnSessionFK = ?', whereArgs: [session_id]);
    debugPrint('deleted $count rows: ${tableRunExpiry}');

  }

  Future<void> updateSessionAndDeleteExpiry(Session s) async {
    await updateSession(s);
    await deleteExpiry(s.id);
  }

  Future<List<Expiry>> insertExpiryWarning(Expiry runExpiry) async {
    final db = await database;

    runExpiry.id = await db.insert(tableRunExpiry, runExpiry.toMap());
    debugPrint('inserted ${runExpiry}');

    return getExpiryWarning(runExpiry.session_fk);
  }

  Future<List<Expiry>> cancelExpiryWarning(Expiry runExpiry) async {
    final db = await database;

    int count = await db.update(tableRunExpiry,
      {columnSessionFK: runExpiry.session_fk, columnCancelled: true},
      where: '$columnSessionFK = ?', whereArgs: [runExpiry.session_fk]);
    debugPrint('updated ${count} rows: $tableRunExpiry');

    return getExpiryWarning(runExpiry.session_fk);
  }

  Future<List<Expiry>> getExpiryWarning(int session_fk) async {
    final db = await database;

    var res = await db.query(tableRunExpiry,
        where: '$columnSessionFK = ?', whereArgs: [session_fk]);

    // todo: get active expiration notices
    List<Expiry> listOfRunExpiry = res.isNotEmpty
        ? res.map((e) => Expiry.fromMap(e)).toList()
        : [];

    return listOfRunExpiry;

  }

  Future<List<Session>> getAllSessions() async {
    final db = await database;

    var res = await db.query(tableSession,
        columns: [
          columnId,
          columnDuration,
          columnStart,
          columnResult,
          columnReason,
        ]);

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

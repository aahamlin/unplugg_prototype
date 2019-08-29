// Database provider
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:async/async.dart';

import 'package:unplugg_prototype/core/data/database_schema.dart';
import 'models/session.dart';
import 'models/interrupt.dart';
import 'models/log_entry.dart';

class DBProvider {

  factory DBProvider() {
    if (instance == null) {
      instance = DBProvider._();
    }
    return instance;
  }

  DBProvider._();

//  @visibleForTesting
//  DBProvider.private(String path) {
//    _path = path;
//    _instance = this;
//  }

  static DBProvider instance;

  static Database _database;
  static String _path;

  final _setupDatabaseMemoizer = AsyncMemoizer<Database>();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _setupDatabaseMemoizer.runOnce(() async {
      return await _setupDatabase();
    });
    return _database;
  }

  Future<String> _dbMobilePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentsDirectory.path, "unplugg_prototype.db");
    return path;
  }
  _setupDatabase() async {
    String path = _path ?? await _dbMobilePath();
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
    await db.execute(createLogsTableSQL);
    await db.execute(createSessionTableSQL);
    await db.execute(createInterruptsTableSQL);
  }

  Future<int> addLogEntry(LogEntry logEntry) async {
    final db = await database;
    return await db.insert(tableLogs, logEntry.toMap());
  }

  Future<List<LogEntry>> getAllLogs() async {
    final db = await database;

    var res = await db.query(tableLogs);
    return res.isNotEmpty ?
        res.map((e) => LogEntry.fromMap(e)).toList() : [];
  }

  Future<Session> getSession(int id) async {
    final db = await database;

    var res = await db.query(tableSession,
        where: '$columnId = ?',
        whereArgs: [id]);

    return res.isNotEmpty ?
      Session.fromMap(res.first) : null;
  }

  Future<Session> beginSession(Session s) async {
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

  Future<void> endSession(Session s) async {
    final db = await database;
    int count = await db.update(
      tableSession, s.toMap(),
      where: '$columnId = ?',
      whereArgs: [s.id]);
    debugPrint('updated $count rows: ${tableSession}(${s})');

    // once updated, delete the run table entries
    count = await db.delete(tableInterrupts,
        where: '$columnSessionFK = ?', whereArgs: [s.id]);
    debugPrint('deleted $count rows: ${tableInterrupts}');
  }

  Future<int> insertInterrupt(Interrupt interrupt) async {
    final db = await database;

    interrupt.id = await db.insert(tableInterrupts, interrupt.toMap());
    debugPrint('inserted ${interrupt}');

    // update current session with count of interrupts
    int count = await getTotalInterruptCount(interrupt.session_fk);
//     await db.update(tableSession,
//        {columnInterruptCount: ++count},
//        where: '$columnId = ?', whereArgs: [interrupt.session_fk]);

    return count;
  }

  Future<void> cancelInterrupt(Interrupt interrupt) async {
    final db = await database;

    int count = await db.update(tableInterrupts,
      {columnSessionFK: interrupt.session_fk, columnCancelled: true},
      where: '$columnSessionFK = ?', whereArgs: [interrupt.session_fk]);
    debugPrint('updated ${count} rows: $tableInterrupts');
  }

  Future<int> getTotalInterruptCount(int session_fk) async {
    final db = await database;

    var res = await db.rawQuery(
        'SELECT COUNT($columnId) as count FROM $tableInterrupts WHERE $columnSessionFK = ?', [session_fk]);
    debugPrint('$res');
    return res.isNotEmpty ? res.first['count'] : 0;
  }


  Future<bool> isSessionInterrupted(Session session) async {
    final db = await database;

    var now = DateTime.now();

    var res = await db.query(tableInterrupts,
      where: '$columnSessionFK = ?', whereArgs: [session.id]);

    var sessionHasExpired = res.map((m) => Interrupt.fromMap(m))
        .any((e) => e.cancelled != true && e.timeout.isBefore(now));
    debugPrint('isSessionInterrupted: ${session} $sessionHasExpired');
    return sessionHasExpired;
  }


  Future<List<Session>> getAllSessions() async {
    final db = await database;

    var res = await db.query(tableSession);

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

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

  static DBProvider instance;

  static Database _database;

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
    String path = await _dbMobilePath();
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

  Future<Session> beginSession(Session session) async {
    final db = await database;

    session.id = await db.insert(tableSession, session.toMap());
    debugPrint('beginSession: ${tableSession}(${session})');
    return session;
  }

  // todo: this could be simply directly failing unended sessions on app startup
  Future<List<Session>> getOrphanedSessions() async {
    final db = await database;

    var res = await db.query(tableSession,
      where: '$columnResult IS NULL');

    return res.isNotEmpty ? res.map((m) => Session.fromMap(m)).toList() : [];
  }

  Future<void> endSession(Session session) async {
    final db = await database;
    int count = await db.update(
      tableSession, session.toMap(),
      where: '$columnId = ?',
      whereArgs: [session.id]);
    debugPrint('endSession: ${tableSession}(${session})');

    // cancel any outstanding interrupts
    await cancelAllInterrupts(session.id);
  }

  Future<void> insertInterrupt(Interrupt interrupt) async {
    final db = await database;

    interrupt.id = await db.insert(tableInterrupts, interrupt.toMap());
    debugPrint('insertInterrupt: $tableInterrupts(${interrupt})');
  }

  Future<int> cancelAllInterrupts(int session_id) async {
    final db = await database;

    int count = await db.update(tableInterrupts,
      {columnSessionFK: session_id, columnCancelled: true},
      where: '$columnSessionFK = ?', whereArgs: [session_id]);
    debugPrint('cancelAllInterrupts: ${count} $tableInterrupts');
    return count;
  }

  Future<int> getTotalInterruptCount(int session_fk) async {
    final db = await database;

    var res = await db.rawQuery(
        'SELECT COUNT($columnId) as count FROM $tableInterrupts WHERE $columnSessionFK = ?', [session_fk]);
    debugPrint('$res');
    return res.isNotEmpty ? res.first['count'] : 0;
  }

  Future<List<Interrupt>> getSessionInterrupts(int session_fk) async {
    final db = await database;

    var res = await db.query(tableInterrupts,
        where: '$columnSessionFK = ?',
        whereArgs: [session_fk]);
    debugPrint('getSessionInterrupts: session($session_fk) interrupt count(${res.length})');
    return res.isNotEmpty ? res.map((m) => Interrupt.fromMap(m)).toList() : [];
  }

  Future<bool> isSessionInterrupted(Session session) async {
    final db = await database;

    var now = DateTime.now();
    var endTime = session.startTime.add(session.duration);

    var res = await db.query(tableInterrupts,
      where: '$columnSessionFK = ?', whereArgs: [session.id]);

    // expiration, if active and expiration is before now and expiration before end
    var sessionHasExpired = res.map((m) => Interrupt.fromMap(m))
        .any((e) => e.cancelled != true
          && e.timeout.isBefore(endTime)
          && e.timeout.isBefore(now));
    debugPrint('isSessionInterrupted = $sessionHasExpired');
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
    debugPrint("closing database");
    db.close();
  }
}

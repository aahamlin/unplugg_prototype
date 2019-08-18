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

  factory DBProvider() => _instance;

  static final DBProvider _instance = DBProvider._private();

  static Database _database;

  final _setupDatabaseMemoizer = AsyncMemoizer<Database>();

  DBProvider._private();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _setupDatabaseMemoizer.runOnce(() async {
      return await _setupDatabase();
    });
    return _database;
  }

  _setupDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentsDirectory.path, "unplugg_prototype.db");
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
    int count = await db.delete(tableInterrupts,
        where: '$columnSessionFK = ?', whereArgs: [session_id]);
    debugPrint('deleted $count rows: ${tableInterrupts}');

  }

  Future<void> updateSessionAndDeleteExpiry(Session s) async {
    await updateSession(s);
    await deleteExpiry(s.id);
  }

  Future<List<Interrupt>> insertExpiryWarning(Interrupt runExpiry) async {
    final db = await database;

    runExpiry.id = await db.insert(tableInterrupts, runExpiry.toMap());
    debugPrint('inserted ${runExpiry}');

    return getExpiryWarning(runExpiry.session_fk);
  }

  Future<List<Interrupt>> cancelExpiryWarning(Interrupt runExpiry) async {
    final db = await database;

    int count = await db.update(tableInterrupts,
      {columnSessionFK: runExpiry.session_fk, columnCancelled: true},
      where: '$columnSessionFK = ?', whereArgs: [runExpiry.session_fk]);
    debugPrint('updated ${count} rows: $tableInterrupts');

    return getExpiryWarning(runExpiry.session_fk);
  }

  Future<List<Interrupt>> getExpiryWarning(int session_fk) async {
    final db = await database;

    var res = await db.query(tableInterrupts,
        where: '$columnSessionFK = ?', whereArgs: [session_fk]);

    // todo: get active expiration notices
    List<Interrupt> listOfRunExpiry = res.isNotEmpty
        ? res.map((e) => Interrupt.fromMap(e)).toList()
        : [];

    return listOfRunExpiry;

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

import 'dart:async';

import './bloc_base.dart';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models.dart';

class SessionBloc implements BlocBase  {
  final _sessionController = StreamController<Session>.broadcast();
  final DBProvider _db;

  // output stream
  Stream<Session> get session => _sessionController.stream;

  SessionBloc(this._db);

  @override
  void dispose() {
    _sessionController.close();
  }

  /*
  getSessions() async {
    List<Session> sessions = await _db.getAllUnpluggSessions();
    // add all existing sessions to the stream
    _sessionController.sink.add(sessions);
    print('session bloc adding ${sessions.length} session to sink');
  }

  delete(int id) async {
    _db.deleteUnpluggSession(id);
    getSessions();
  }

  deleteAll() async {
    _db.deleteAllSessions();
    getSessions();
  }*/


  Future<Session> startSession(Session session) async {
    session = await _db.insertSession(session);
    _sessionController.sink.add(session);
    return session;
  }

  void addEvent(Event event) async {
    await _db.insertEvent(event);
  }
}

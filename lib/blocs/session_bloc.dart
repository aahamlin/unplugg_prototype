import 'dart:async';

import './bloc_base.dart';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models/session.dart';

class SessionBloc implements BlocBase  {
  final _sessionController = StreamController<Session>.broadcast();
  final DBProvider _db;

  // output stream
  Stream<Session> get sessions => _sessionController.stream;

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


  Future<Session> startSession(int duration) async {
    var session = await _db.newUnpluggSession(Session(duration: Duration(minutes: duration)));
    _sessionController.sink.add(session);
    return session;
  }

}

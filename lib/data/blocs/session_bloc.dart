import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/data/blocs/bloc_provider.dart';
import 'package:unplugg_prototype/data/database.dart';
import '../models/session.dart';

class SessionBloc implements BlocBase  {
  final _sessionController = StreamController<List<Session>>.broadcast();

  // output stream
  Stream<List<Session>> get sessions => _sessionController.stream;

  SessionBloc() {
    //getSessions();
  }

  @override
  void dispose() {
    _sessionController.close();
  }

  getSessions() async {
    List<Session> sessions = await DBProvider.db.getAllUnpluggSessions();
    // add all existing sessions to the stream
    _sessionController.sink.add(sessions);
    print('session bloc adding ${sessions.length} session to sink');
  }

  delete(int id) async {
    DBProvider.db.deleteUnpluggSession(id);
    getSessions();
  }

  newSession(Session session) async {
    await DBProvider.db.newUnpluggSession(session);
    getSessions();
  }

}

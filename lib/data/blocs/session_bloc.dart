import 'dart:async';

import 'package:unplugg_prototype/data/blocs/bloc_provider.dart';
import 'package:unplugg_prototype/data/database.dart';

class SessionBloc implements BlocBase {
  final _sessionController = StreamController<List<SessionModel>>.broadcast();

  // output stream
  Stream<List<SessionModel>> get sessions => _sessionController.stream;

  SessionBloc() {
    getSessions();
  }

  @override
  void dispose() {
    _sessionController.close();
  }

  getSessions() async {
    List<SessionModel> sessions = await DBProvider.db.getAllUnpluggSessions();
    // add all existing sessions to the stream
    _sessionController.sink.add(sessions);
  }

  delete(int id) async {
    DBProvider.db.deleteUnpluggSession(id);
    getSessions();
  }

  newSession(SessionModel session) async {
    await DBProvider.db.newUnpluggSession(session);
    getSessions();
  }
}

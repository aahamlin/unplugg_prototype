import 'dart:async';

import 'package:unplugg_prototype/data/blocs/bloc_provider.dart';
import 'package:unplugg_prototype/data/database.dart';

class SessionBloc implements BlocBase {
  final _sessionController = StreamController<List<UnpluggSession>>.broadcast();

  // input stream
  StreamSink<List<UnpluggSession>> get _inSessions => _sessionController.sink;

  // output stream
  Stream<List<UnpluggSession>> get sessions => _sessionController.stream;

  // input stream for new sessions
  final _addSessionController = StreamController<UnpluggSession>.broadcast();
  StreamSink<UnpluggSession> get inAddSession => _addSessionController.sink;

  SessionBloc() {
    getSessions();

    // listen for changes to addSessionController and calls _handleAddSession
    _addSessionController.stream.listen(_handleAddSession);
  }

  @override
  void dispose() {
    _sessionController.close();
    _addSessionController.close();
  }

  getSessions() async {
    List<UnpluggSession> sessions = await DBProvider.db.getAllUnpluggSessions();
    // add all existing sessions to the stream
    _inSessions.add(sessions);
  }

  delete(int id) async {
    DBProvider.db.deleteUnpluggSession(id);
    getSessions();
  }

  _handleAddSession(UnpluggSession session) async {
    await DBProvider.db.newUnpluggSession(session);

    // add new session to stream
    // note: example called getSessions and readded everything, not sure why?
    //inAddSession.add(session);
    getSessions();
  }
}
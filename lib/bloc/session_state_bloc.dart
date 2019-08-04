import 'dart:async';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models.dart';
import 'package:unplugg_prototype/shared/session_model.dart';
import 'package:unplugg_prototype/shared/session_state.dart';

class SessionModelBloc {

  final DBProvider dbProvider;
  //SessionModel model;

  SessionModelBloc({DBProvider this.dbProvider, Duration duration}) {
    // if model is null, query for running non-expired session or set error
    // if model is pending, start new session
    if (duration == null) {
      dbProvider.findMostRecentSessionId().then((id) {
        var model = SessionModel(id: id);
        resume(model);
      }).catchError((e) => _controller.addError(e));
    }
    else {
      var model = SessionModel(duration: duration);
      start(model);
    }
  }

  void dispose() {
    _controller.close();
  }

  StreamController<SessionModel> _controller = StreamController.broadcast();

  Stream<SessionModel> get sessionModel => _controller.stream;

  void start(SessionModel model) async {
    print('starting session');
    var session = await dbProvider.insertOrUpdateSession(Session(
      duration: model.duration
    ));
    model.id = session.id;
    model.startTime = session.startTime;
    model.state = SessionState.running;
    _controller.sink.add(model);
  }

  void resume(SessionModel model) async {
    print('resuming session');
    var session = await dbProvider.getSession(model.id);
    model = SessionModel.fromSession(session);
    if (model.isExpired || model.isFinished) {
      model.state = model.finishReason == 'success' ?
        SessionState.completed : SessionState.cancelled;
    }
    else if (model.isStarted) {
      model.state = SessionState.running;
    }
    _controller.sink.add(model);
  }

  void complete(SessionModel model) async {
    var session = model.toSession();
    session.finishTime = DateTime.now();
    session.finishReason = "success";
    await dbProvider.insertOrUpdateSession(session);

    model.state = SessionState.completed;
    _controller.sink.add(model);
  }

  void cancel(SessionModel model) async {
    var session = model.toSession();
    session.finishTime = DateTime.now();
    session.finishReason = "cancelled";
    await dbProvider.insertOrUpdateSession(session);

    model.state = SessionState.cancelled;
    _controller.sink.add(model);
  }

  void record(SessionModel model, Event event) async {
    event.session_id = model.id;
    await dbProvider.insertEvent(event);
    await dbProvider.insertOrUpdateSession(model.toSession());
    // todo: if user backgrounds the app more than X times, fail their session
    _controller.sink.add(model);
  }

}
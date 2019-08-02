import 'dart:async';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models.dart';

enum SessionState {
  pending,
  running,
  completed,
  cancelled,
}

class SessionModel {
  int id;
  Duration duration;
  DateTime startTime;
  DateTime finishTime;
  String finishReason;
  SessionState state;

  SessionModel({
    this.id,
    this.duration,
    this.startTime,
    this.finishTime,
    this.finishReason,
    this.state = SessionState.pending,
  });

  Session toSession() {
     return Session(
      id: this.id,
      startTime: this.startTime,
      duration: this.duration,
      finishTime: this.finishTime,
      finishReason: this.finishReason,
    );
  }
}

class SessionModelBloc {

  final DBProvider dbProvider;

  SessionModelBloc({DBProvider this.dbProvider});

  void dispose() {
    _controller.close();
  }

  StreamController<SessionModel> _controller = StreamController.broadcast(
    onListen: () => print("listening"),
    onCancel: () => print("cancelled"),
  );

  Stream<SessionModel> get sessionModel => _controller.stream;

  void start(SessionModel model) async {
    var session = await dbProvider.insertOrUpdateSession(Session(
      duration: model.duration
    ));
    model.id = session.id;
    model.startTime = session.startTime;
    model.state = SessionState.running;
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

    List<Event> eventsDuringSession = await dbProvider.getAllSessionEvents(model.id);

    // todo: check error conditions
    print(eventsDuringSession.last);

    _controller.sink.add(model);
  }
}
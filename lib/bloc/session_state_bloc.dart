import 'dart:async';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models.dart';
import 'package:unplugg_prototype/shared/notifications.dart';

enum SessionState {
  pending,
  running,
  completed,
  cancelled,
}

class SessionModel {
  int id;
  Duration duration;
  DateTime expiry;
  DateTime startTime;
  DateTime finishTime;
  String finishReason;
  SessionState state;

  SessionModel.fromSession(Session session) {
    id = session.id;
    duration = session.duration;
    expiry = session.expiry;
    startTime = session.startTime;
    finishTime = session.finishTime;
    finishReason = session.finishReason;
  }

  SessionModel({
    this.id,
    this.duration,
    this.expiry,
    this.startTime,
    this.finishTime,
    this.finishReason,
    this.state = SessionState.pending,
  });

  Session toSession() {
     return Session(
      id: this.id,
      startTime: this.startTime,
      expiry: this.expiry,
      duration: this.duration,
      finishTime: this.finishTime,
      finishReason: this.finishReason,
    );
  }

  bool get isStarted => startTime != null;
  bool get isFinished => finishTime != null;
  bool get isExpired => expiry != null && expiry.isBefore(DateTime.now());

}

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

  StreamController<SessionModel> _controller = StreamController();

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

    var notificationManager = NotificationManager();
    var eventType = event.eventType;

    // on pause, setup notification for 2 minutes with 3 min session expiry
    if (eventType == 'inactive') {
      var warningNotificationTime = DateTime.now().add(Duration(minutes: 1));
      var sessionExpirationTime = DateTime.now().add(Duration(minutes: 3));
      var sessionNotificationDetails = SessionNotificationDetails(
          sessionId: model.id, expiry: sessionExpirationTime);

      model.expiry = sessionExpirationTime;
      await dbProvider.insertOrUpdateSession(model.toSession());

      notificationManager.showMomentsExpiringNotification(
          sessionNotificationDetails,
          warningNotificationTime);
    }

    // on locking or resumed, within time window, cancel notification, cancel expiry
    else if (eventType == 'locking' || eventType == 'resumed') {
      if(event.timeStamp.isBefore(model.expiry)) {
        notificationManager.cancelMomentsExpiringNotification();
        model.expiry = null;
        await dbProvider.insertOrUpdateSession(model.toSession());
      }
    }

    _controller.sink.add(model);
  }


}
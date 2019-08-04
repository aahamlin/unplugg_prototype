import 'package:unplugg_prototype/data/models.dart';
import 'session_state.dart';

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
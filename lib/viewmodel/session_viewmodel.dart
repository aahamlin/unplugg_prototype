

enum SessionViewState {
  running,
  cancelled,
  succeeded,
  failed,
}

class SessionViewModel {

  final int id;
  final DateTime startTime;
  final Duration duration;
  final SessionViewState state;

  SessionViewModel({
    this.id,
    this.startTime,
    this.duration,
    this.state,
  });

  @override toString() {
    return _toMap().toString();
  }

  Map<String, dynamic> _toMap() {
    var map = <String, dynamic>{
      'startTime': startTime?.millisecondsSinceEpoch,
      'duration': duration.inMinutes,
      'state': state,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}


import 'package:flutter/foundation.dart';

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
    @required this.id,
    @required this.startTime,
    @required this.duration,
    @required this.state,
  });

  @override toString() {
    return _toMap().toString();
  }

  Map<String, dynamic> _toMap() {
    var map = <String, dynamic>{
      'startTime': startTime?.millisecondsSinceEpoch,
      'duration': duration?.inMinutes,
      'state': state,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}


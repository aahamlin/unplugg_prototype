import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/core/data/models/interrupt.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';

enum SessionState {
  none,
  running,
  succeeded,
  failed,
}

class SessionStateViewModel {
  SessionState state;
  Session session;
//  List<Interrupt> interrupts;

  SessionStateViewModel({
    this.session,
//    this.interrupts,
    this.state,
  });

  SessionStateViewModel.empty() {
    this.session = null;
//    this.interrupts = null;
    this.state = SessionState.none;
  }

  @override toString() {
    return '$hashCode state:$state}';
  }
}


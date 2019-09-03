import 'dart:async';

import 'package:flutter/foundation.dart';
import 'bloc_base.dart';
import 'package:unplugg_prototype/core/shared/log_manager.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/core/data/models/interrupt.dart';
import 'package:unplugg_prototype/core/services/notifications.dart';

/**
 * Moves session through its states: None, Running, Complete, Incomplete
 */
class SessionStateBloc extends BlocBase<Session> {

  final _logger = LogManager.getLogger('SessionStateBloc');
  final DBProvider dbProvider;
  Timer _expirationTimer;
  NotificationManager notificationManager = NotificationManager();


  SessionStateBloc({this.dbProvider}) {
    // exit is currently  failure condition
    _failOrphanedSessions();
  }


  Future start({Duration duration}) async {
    _logger.i('starting session: ${duration.inMinutes} min');

    var session = await dbProvider.beginSession(
        Session(duration: duration, startTime: DateTime.now()));

    _emitSessionState(session.id);
  }


  Future cancel(final Session session) async {
    _logger.i('cancelling: ${session}');
    session.result = SessionResult.cancelled;
    session.reason = 'User cancelled';

    await dbProvider.endSession(session);
    _emitSessionState(session.id);
  }

  Future complete(final Session session) async {
    _logger.i('completing: $session');

    var isSessionInterrupted = await dbProvider.isSessionInterrupted(session);
    _logger.i('isSessionInterrupted $isSessionInterrupted');

    if (isSessionInterrupted) {
      return fail(session);
    }

    session.result = SessionResult.success;
    session.reason = 'Success';
    await dbProvider.endSession(session);
    _emitSessionState(session.id);

  }

  Future fail(final Session session, {bool notify = false}) async {
    _logger.i('failing: ${session}');

    session.result = SessionResult.failure;
    session.reason = 'User interrupted session';

    if (notify) {
      notificationManager.showSessionFailedNotification();
    }
    await dbProvider.endSession(session);
    _emitSessionState(session.id);
  }

  Future interrupt(final Session session) async {
    var expiry = Duration(seconds: 10);
    var timeout = DateTime.now().add(expiry);

    var interrupt = Interrupt(
        session_fk: session.id,
        timeout: timeout);

    await dbProvider.insertInterrupt(interrupt);

    int count = await dbProvider.getTotalInterruptCount(session.id);

    if (count > 1) {
      session.result = SessionResult.failure;
      session.reason = 'User interrupted session $count times';

      await dbProvider.endSession(session);
      notificationManager.showSessionFailedNotification();
    }
    else {
      _logger.i('scheduling expiration of session: $session');
      notificationManager.showSessionInterruptNotification();
      _expirationTimer = Timer(expiry, () async {
        // todo if not resumed then fail session
        _logger.i('session has timed out: $session');
        fail(session, notify: true);
      });
    }

    _emitSessionState(session.id);
  }

  Future resume(final Session session) async {
    debugPrint('resume $session');
    if (_expirationTimer != null) {
      _expirationTimer.cancel();
    }
    _cancelNotifications();

    var isSessionInterrupted = await dbProvider.isSessionInterrupted(session);
    _logger.i('isSessionInterrupted $isSessionInterrupted');
    if(isSessionInterrupted) {
      return fail(session);
    }
    else if (session.endTime.isBefore(DateTime.now())) {
      return complete(session);
    }

    await dbProvider.cancelAllInterrupts(session.id);
    _emitSessionState(session.id);
  }


  _cancelNotifications() {
    notificationManager.cancelMomentsExpiringNotification();
    notificationManager.cancelSessionInterruptedNotification();
  }

  Future _failOrphanedSessions() async {
    _logger.d('Scanning for running session.');
    var sessions = await dbProvider.getOrphanedSessions();
    debugPrint('getOrphanedSessions returned: $sessions');
    sessions.forEach((session) async {
      session.result = SessionResult.failure;
      session.reason = 'User exited session';
      await dbProvider.endSession(session);
    });
  }


  Future _emitSessionState(int session_id) async {
    Session session = await dbProvider.getSession(session_id);
    debugPrint('emit $session');
    add(session);
  }

}


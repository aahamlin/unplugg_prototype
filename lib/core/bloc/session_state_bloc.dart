import 'package:flutter/foundation.dart';
import '../interrupts.dart';
import 'bloc_base.dart';
import 'package:unplugg_prototype/core/shared/log_manager.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/core/data/models/interrupt.dart';
import 'package:unplugg_prototype/viewmodel/session_viewmodel.dart';
import 'package:unplugg_prototype/core/services/notifications.dart';

/**
 * Moves session through its states: None, Running, Complete, Incomplete
 */
class SessionStateBloc extends BlocBase<SessionViewModel> {

  final _logger = LogManager.getLogger('SessionStateBloc');
  final DBProvider dbProvider;

  SessionStateBloc({this.dbProvider}) {
    // exit is currently  failure condition
    //_scan();
  }


  Future start({Duration duration}) async {
    _logger.i('starting session: ${duration.inMinutes} min');
    var session = await dbProvider.beginSession(
        Session(duration: duration, startTime: DateTime.now()));

    final vm = SessionViewModel(
      id: session.id,
      startTime: session.startTime,
      duration: session.duration,
      state: SessionViewState.running,
    );

    add(vm);
    _logger.i('started ${vm}');
  }


  Future cancel(final SessionViewModel input) async {
    _logger.i('cancelling: ${input}');
    assert(input.state == SessionViewState.running);

    var session = Session(id: input.id,
        duration: input.duration,
        startTime: input.startTime,
        result: SessionResult.failure,
        reason: 'User cancelled');

    await dbProvider.endSession(session);

    final output = SessionViewModel(
      id: session.id,
      duration: session.duration,
      startTime: session.startTime,
      state: SessionViewState.cancelled,
    );

    add(output);
    _logger.i('cancelled: ${output}');
  }


  Future complete(final SessionViewModel input) async {
    _logger.i('completing: ${input}');
    assert(input.state == SessionViewState.running);

    var session = Session(id: input.id,
      duration: input.duration,
      startTime: input.startTime,
    );

    var isSessionInterrupted = await dbProvider.isSessionInterrupted(session);

    if (isSessionInterrupted) {
      session.result = SessionResult.failure;
      session.reason = 'User left session for too long';
    }
    else {
      session.result = SessionResult.success;
      session.reason = 'Success';
    }

    await dbProvider.endSession(session);

    final output = SessionViewModel(
      id: session.id,
      duration: session.duration,
      startTime: session.startTime,
      state: session.result == SessionResult.success ? SessionViewState
          .succeeded : SessionViewState.failed,
    );
    add(output);
    _logger.i('completed: ${output}');
  }

  Future fail(final SessionViewModel input) async {
    _logger.i('failing: ${input}');
    var session = Session(id: input.id,
      duration: input.duration,
      startTime: input.startTime,
    );
    session.result = SessionResult.failure;
    session.reason = 'User interrupted session';

    await dbProvider.endSession(session);

    final output = SessionViewModel(
      id: session.id,
      duration: session.duration,
      startTime: session.startTime,
      state: SessionViewState.failed,
    );

    add(output);
    _logger.i('failed: ${output}');
  }

  void interrupt(final SessionViewModel input, InterruptEvent event) async {
    bool isTooNearEndTime = false;
    var expiry = Duration(seconds: 10);
    var endTime = input.startTime.add(input.duration);
    var durationToEnd = endTime.difference(DateTime.now());
    if (durationToEnd < expiry) {
      isTooNearEndTime = true;
    }

    if (event.failImmediate || isTooNearEndTime) {
      fail(input);
    }
    else {
      var timeout = DateTime.now().add(expiry);

      var interrupt = Interrupt(
          session_fk: input.id,
          timeout: timeout);

      int interruptCount = await dbProvider.insertInterrupt(interrupt);
      _cancelInterruptNotification();
      // setup notifications
      var notificationManager = NotificationManager();
      if (interruptCount > 1) {
        notificationManager.showSessionFailedNotification();
        fail(input);
      }
      else {
        notificationManager.showSessionInterruptNotification();
      }
    }
  }

  void resume(final SessionViewModel input) async {
    _cancelInterruptNotification();
    var session = Session(id: input.id,
      duration: input.duration,
      startTime: input.startTime,
    );

    var isSessionInterrupted = await dbProvider.isSessionInterrupted(session);

    if(isSessionInterrupted) {
      fail(input);
    }
  }


  _cancelInterruptNotification() {
    _logger.d('Cancelling user notifications');
    var notificationManager = NotificationManager();
    notificationManager.cancelMomentsExpiringNotification();
    notificationManager.cancelSessionInterruptedNotification();
  }

  Future _scan() async {
    _logger.d('Scanning for current session.');
    var session = await dbProvider.getCurrentSession();
    // kick off app in running session, allow session page to complete
    if (session != null) {
      var sessionEndTime = session.startTime.add(session.duration);
      final vm = SessionViewModel(
        id: session.id,
        startTime: session.startTime,
        duration: session.duration,
        state: SessionViewState.running,
      );
      if (DateTime.now().isAfter(sessionEndTime)) {
        return complete(vm);
      }
      else {
        add(vm);
      }
    }
  }

}


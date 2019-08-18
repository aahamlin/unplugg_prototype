import 'package:flutter/foundation.dart';
import 'bloc_base.dart';
import 'package:unplugg_prototype/core/shared/log_manager.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/core/data/models/interrupt.dart';
import 'package:unplugg_prototype/viewmodel/session_viewmodel.dart';

/**
 * Moves session through its states: None, Running, Complete, Incomplete
 */
class SessionStateBloc extends BlocBase<SessionViewModel> {

  final _logger = LogManager.getLogger('SessionStateBloc');
  final DBProvider dbProvider;

  SessionStateBloc({DBProvider this.dbProvider}) {
    _scan();
  }

  Future<void> _scan() async {
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

  Future<void> start({Duration duration}) async {
    _logger.i('starting session: ${duration.inMinutes} min');
    var session = await dbProvider.insertSession(
        Session(duration:duration, startTime: DateTime.now()));

    final vm = SessionViewModel(
      id: session.id,
      startTime: session.startTime,
      duration: session.duration,
      state: SessionViewState.running,
    );

    add(vm);
    _logger.i('started ${vm}');
  }


  Future<void> cancel(final SessionViewModel input) async {
    _logger.i('cancelling: ${input}');
    assert(input.state == SessionViewState.running);

    var session = Session(id: input.id,
      duration: input.duration,
      startTime: input.startTime,
      result: SessionResult.failure,
      reason: 'User cancelled');

    await dbProvider.updateSessionAndDeleteExpiry(session);

    final output = SessionViewModel(
      id: session.id,
      duration: session.duration,
      startTime: session.startTime,
      state: SessionViewState.cancelled,
    );

    add(output);
    _logger.i('cancelled: ${output}');
  }


  Future<void> complete(final SessionViewModel input) async {
    _logger.i('completing: ${input}');
    assert(input.state == SessionViewState.running);

    var session = Session(id: input.id,
      duration: input.duration,
      startTime: input.startTime,
    );

    var sessionHasExpired = await _checkForInterruptedSession(session);

    if(sessionHasExpired) {
      session.result = SessionResult.failure;
      session.reason = 'User left session for too long';
    }
    else {
      session.result = SessionResult.success;
      session.reason = 'Success';
    }

    await dbProvider.updateSessionAndDeleteExpiry(session);

    final output = SessionViewModel(
      id: session.id,
      duration: session.duration,
      startTime: session.startTime,
      state: session.result == SessionResult.success ? SessionViewState.succeeded : SessionViewState.failed,
    );
    add(output);
    _logger.i('completed: ${output}');
  }

  Future<void> fail(final SessionViewModel input) async {
    _logger.i('failing: ${input}');
    var session = await dbProvider.getSession(input.id);
    session.result = SessionResult.failure;
    session.reason = 'User interrupted session';

    await dbProvider.updateSessionAndDeleteExpiry(session);

    final output = SessionViewModel(
      id: session.id,
      duration: session.duration,
      startTime: session.startTime,
      state: SessionViewState.failed,
    );

    add(output);
    _logger.i('failed: ${output}');
  }

  Future<int> setInterruptOnSession(SessionViewModel vm, Duration expiry) async {
    _logger.i('interrupting: ${vm}');
    var expireTime = DateTime.now().add(expiry);
    var runExpiry = Interrupt(session_fk: vm.id, timeout: expireTime);
    var expiryWarnings = await dbProvider.insertExpiryWarning(runExpiry);
    return expiryWarnings.length;
  }

  Future<void> cancelInterruptOnSession(SessionViewModel vm) async {
    _logger.i('cancelling interrupt: ${vm}');
    var runExpiry = Interrupt(session_fk: vm.id);
    var listOfInterrupts = await dbProvider.cancelExpiryWarning(runExpiry);
    if (listOfInterrupts.isNotEmpty) {
      debugPrint(
          'cancelled ${listOfInterrupts.last} of ${listOfInterrupts.length}');
    }
  }

  Future<bool> _checkForInterruptedSession(Session session) async {
    debugPrint('_checkForExpiredSession: ${session}');
    var sessionEndTime = session.startTime.add(session.duration);
    var sessionHasExpired = (await dbProvider.getExpiryWarning(session.id))
        .any((e) => e.cancelled != true && e.timeout.isBefore(sessionEndTime));
    return sessionHasExpired;
  }
}
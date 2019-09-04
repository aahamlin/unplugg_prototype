import 'dart:async';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/core/services/notifications.dart';

void main() {
  SessionStateBloc sessionStateBloc;
  DBProvider dbProvider;
  NotificationManager notificationManager;

  Session session;

  setUp(() {
    DBProvider.instance = MockDBProvider();
    dbProvider = DBProvider();
    NotificationManager.instance = MockNotificationManager();
    notificationManager = NotificationManager();

    session = Session(
        id: 1, startTime: DateTime.now(), duration: Duration(seconds: 30));

    // stub sessions behavior
    when(dbProvider.getOrphanedSessions()).thenAnswer((_) => Future.value([]));

    when(dbProvider.beginSession(any)).thenAnswer((_) => Future.value(session));

    when(dbProvider.getSessionInterrupts(any))
        .thenAnswer((_) => Future.value([]));

    when(dbProvider.getSession(any)).thenAnswer((_) => Future.value(session));

    when(dbProvider.isSessionInterrupted(any))
        .thenAnswer((_) => Future.value(false));

    sessionStateBloc = SessionStateBloc(expiry: Duration(seconds: 1));
  });

  group('fresh sessions', () {
    test('start session', () async {
      final StreamQueue<Session> queue =
          StreamQueue<Session>(sessionStateBloc.stream);

      sessionStateBloc.start(duration: Duration(seconds: 15));
      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.none));
      verify(dbProvider.beginSession(any)).called(1);
      verify(notificationManager.scheduleMomentsEarnedNotification(any, any)).called(1);
    });

    test('cancel session, if running', () async {
      final StreamQueue<Session> queue =
          StreamQueue<Session>(sessionStateBloc.stream);

      sessionStateBloc.cancel(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.cancelled));
      verify(dbProvider.endSession(captureThat(isA<Session>()))).called(1);
      verify(notificationManager.cancelMomentsEarnedNotification()).called(1);
    });

    test('complete session, successfull', () async {
      final StreamQueue<Session> queue =
          StreamQueue<Session>(sessionStateBloc.stream);

      sessionStateBloc.complete(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.success));
      verify(dbProvider.endSession(any)).called(1);
    });

    test('fail session, no notify', () async {
      final StreamQueue<Session> queue =
          StreamQueue<Session>(sessionStateBloc.stream);

      sessionStateBloc.fail(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.failure));
      verify(dbProvider.endSession(any)).called(1);
      verifyNever(notificationManager.showSessionFailedNotification());
      verify(notificationManager.cancelMomentsEarnedNotification()).called(1);
    });

    test('fail session and notify', () async {
      final StreamQueue<Session> queue =
          StreamQueue<Session>(sessionStateBloc.stream);

      sessionStateBloc.fail(session, notify: true);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.failure));
      verify(dbProvider.endSession(any)).called(1);
      verify(notificationManager.showSessionFailedNotification()).called(1);
      verify(notificationManager.cancelMomentsEarnedNotification()).called(1);
    });
  });

  group('interrupted sessions', () {
    setUp(() {});

    test('interrupt displays 1st warning', () async {
      final StreamQueue<Session> queue =
          StreamQueue<Session>(sessionStateBloc.stream);

      when(dbProvider.getTotalInterruptCount(session.id))
        .thenAnswer((_) => Future.value(1));

      sessionStateBloc.interrupt(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.none));
      verifyNever(dbProvider.endSession(any));
      verify(dbProvider.insertInterrupt(any)).called(1);
      verify(notificationManager.scheduleSessionInterruptNotification()).called(1);

      expect(sessionStateBloc.expirationTimer.isActive, isTrue);
      sessionStateBloc.expirationTimer.cancel();
    });

    test('interrupt fails on 2nd warning', () async {
      final StreamQueue<Session> queue =
      StreamQueue<Session>(sessionStateBloc.stream);

      when(dbProvider.getTotalInterruptCount(session.id))
          .thenAnswer((_) => Future.value(2));

      sessionStateBloc.interrupt(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.failure));
      verify(dbProvider.endSession(any)).called(1);
      verify(dbProvider.insertInterrupt(any)).called(1);
      verify(notificationManager.showSessionFailedNotification()).called(1);
      verifyNever(notificationManager.scheduleSessionInterruptNotification());
      verify(notificationManager.cancelMomentsEarnedNotification()).called(1);
    });

    test('interrupt fails session after expiration', () async {
      final StreamQueue<Session> queue =
      StreamQueue<Session>(sessionStateBloc.stream);

      when(dbProvider.getTotalInterruptCount(session.id))
          .thenAnswer((_) => Future.value(1));

      sessionStateBloc.interrupt(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.none));

      verify(dbProvider.insertInterrupt(any)).called(1);
      verify(notificationManager.scheduleSessionInterruptNotification()).called(1);

      expect(sessionStateBloc.expirationTimer.isActive, isTrue);

      await Future.delayed(Duration(seconds: 1));

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.failure));

      verify(dbProvider.endSession(any)).called(1);
      verify(notificationManager.showSessionFailedNotification()).called(1);
      verify(notificationManager.cancelMomentsEarnedNotification()).called(1);

    });

    test('resumed session continues', () async {
      final StreamQueue<Session> queue =
          StreamQueue<Session>(sessionStateBloc.stream);

      await sessionStateBloc.resume(session);

      verify(dbProvider
          .cancelAllInterrupts(argThat(predicate((id) => id == 1)))).called(1);
      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.none));
    });

    test('resumed session fails', () async {
      final StreamQueue<Session> queue =
          StreamQueue<Session>(sessionStateBloc.stream);

      when(dbProvider.isSessionInterrupted(any))
          .thenAnswer((_) => Future.value(true));

      await sessionStateBloc.resume(session);

      expect(await queue.next,
          predicate((Session vm) => vm.result == SessionResult.failure));
      verifyNever(dbProvider.cancelAllInterrupts(any));
    });
  });
}

class MockDBProvider extends Mock implements DBProvider {}

class MockNotificationManager extends Mock implements NotificationManager {}

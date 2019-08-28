import 'dart:async';
import 'dart:ui';

import 'package:async/async.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';

import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/viewmodel/session_viewmodel.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/core/factories.dart';

void main() {

  MockDBProvider dbProvider;
  SessionStateBloc sessionStateBloc;

  group('fresh sessions', () {

    setUp(() {
      dbProvider = MockDBProvider();
      when(dbProvider.getCurrentSession())
        .thenAnswer((_) => Future.value(null));

      sessionStateBloc = SessionStateBloc(dbProvider: dbProvider);
    });

    test('start session', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      when(dbProvider.insertSession(any))
      .thenAnswer((_) => Future.value(Session(duration: Duration(seconds:15), startTime: DateTime.now())));
      sessionStateBloc.start(duration: Duration(seconds: 15));
      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.running));
      verify(dbProvider.insertSession(any)).called(1);

    });


    test('cancel session, if running', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      var runningSessionViewModel = SessionViewModel(
          id: 1,
          state: SessionViewState.running);

      sessionStateBloc.cancel(runningSessionViewModel);

      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.cancelled));
      verify(dbProvider.updateSessionAndDeleteExpiry(any)).called(1);
    });

    test('complete session, successfull', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      var runningSessionViewModel = SessionViewModel(
          id: 1,
          state: SessionViewState.running);

      when(dbProvider.isSessionInterrupted(any))
        .thenAnswer((_) => Future.value(false));

      sessionStateBloc.complete(runningSessionViewModel);

      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.succeeded));
      verify(dbProvider.updateSessionAndDeleteExpiry(any)).called(1);
    });

    test('complete session, interrupted', () async {
      final StreamQueue<SessionViewModel> queue =
      StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      var runningSessionViewModel = SessionViewModel(
          id: 1,
          state: SessionViewState.running);

      when(dbProvider.isSessionInterrupted(any))
          .thenAnswer((_) => Future.value(true));

      sessionStateBloc.complete(runningSessionViewModel);

      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.failed));
      verify(dbProvider.updateSessionAndDeleteExpiry(any)).called(1);
    });

    test('fail session', () async {
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      var runningSessionViewModel = SessionViewModel(
          id: 1,
          state: SessionViewState.running);

      sessionStateBloc.fail(runningSessionViewModel);

      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.failed));
      verify(dbProvider.updateSessionAndDeleteExpiry(any)).called(1);
    });
  });

  group('continued sessions', ()
  {
    setUp(() {
      dbProvider = MockDBProvider();

    });

    test('resume session before end', () async {
      when(dbProvider.getCurrentSession())
          .thenAnswer((_) => Future.value(Session(
          id: 1, duration: Duration(seconds:15), startTime: DateTime.now())));

      sessionStateBloc = SessionStateBloc(dbProvider: dbProvider);
      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.running));
    });

    test('resume session after end', () async {
      when(dbProvider.getCurrentSession())
          .thenAnswer((_) => Future.value(Session(
          id: 1, duration: Duration(seconds:15), startTime: DateTime.now().subtract(Duration(seconds: 20)))));

      when(dbProvider.isSessionInterrupted(any))
          .thenAnswer((_) => Future.value(false));

      sessionStateBloc = SessionStateBloc(dbProvider: dbProvider);

      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);


      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.succeeded));
    });

    test('resume session interrupted', () async {

      when(dbProvider.getCurrentSession())
          .thenAnswer((_) => Future.value(Session(
          id: 1, duration: Duration(seconds:15), startTime: DateTime.now().subtract(Duration(seconds: 20)))));

      when(dbProvider.isSessionInterrupted(any))
          .thenAnswer((_) => Future.value(true));

      sessionStateBloc = SessionStateBloc(dbProvider: dbProvider);

      final StreamQueue<SessionViewModel> queue =
        StreamQueue<SessionViewModel>(sessionStateBloc.stream);

      expect(await queue.next,
          predicate((SessionViewModel vm) => vm.state == SessionViewState.failed));
    });
  });
}

class MockDBProvider extends Mock implements DBProvider {}

import 'package:test/test.dart';

import 'package:unplugg_prototype/data/models.dart';

void main() {

  test('Session.fromMap', () {
    var session = Session.fromMap({
      columnSessionDuration: Duration(minutes: 1).inMilliseconds,
    });

    expect(session, isA<Session>());
  });

  test('Session.fromMap with nulls', () {
    var session = Session.fromMap({
      columnSessionDuration: Duration(minutes: 1).inMilliseconds,
      columnSessionId: null,
      columnStartTimestamp: null,
      columnFinishTimestamp: null,
      columnSessionExpiry: null,
      columnFinishReason: null,
    });

    expect(session, isA<Session>());
  });
}
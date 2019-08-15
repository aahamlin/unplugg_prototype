import 'package:test/test.dart';
import 'package:unplugg_prototype/core/data/database_schema.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';

void main() {

  DateTime _dateTimeField;
  setUp(() {
    _dateTimeField = DateTime.now();
  });

  test('Session.fromMap', () {
    var session = Session.fromMap({
      columnDuration: Duration(minutes: 1).inMilliseconds,
      columnStart: _dateTimeField.millisecondsSinceEpoch,
    });

    expect(session, isA<Session>());
  });

  test('Session.fromMap with nulls', () {
    var session = Session.fromMap({
      columnDuration: Duration(minutes: 1).inMilliseconds,
      columnId: null,
      columnStart: _dateTimeField.millisecondsSinceEpoch,
      columnResult: null,
      columnReason: null,
    });

    expect(session, isA<Session>());
  });
}
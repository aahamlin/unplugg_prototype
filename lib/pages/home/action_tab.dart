import 'package:flutter/material.dart';

import 'package:unplugg_prototype/data/models.dart';

class ActionTab extends StatefulWidget {
  ActionTab({Key key}) : super(key: key);

  @override
  _ActionState createState() => _ActionState();
}

// TODO Change to a Class with Const int values
class SessionDuration {
  static const ONE = 1; // for debugging
  static const FIFTEEN = 15;
  static const THIRTY = 30;
  static const FORTYFIVE = 45;
  static const HOUR = 60;
}

class _ActionState extends State<ActionTab> {

  int _selectedDuration = SessionDuration.THIRTY;

  Widget SessionButton(BuildContext context) {
    return Container(
      child: IconButton(
        iconSize: ButtonTheme.of(context).minWidth,
        icon: ImageIcon(AssetImage('assets/logo.png')),
        color: Colors.green,
        onPressed: () async {
          Navigator.pushNamed(context, '/session', arguments: <String, dynamic> {
            'session': Session(
              duration: Duration(minutes: _selectedDuration),
            )
          });
        },
      ),
    );
  }

  /*child: Ink(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: CircleBorder(),
          ),*/


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Spacer(),
        ButtonTheme(
        minWidth: double.infinity,
        child: SessionButton(context),
        ),
        Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _SessionRadio(
              label: '1m',
              value: SessionDuration.ONE,
              groupValue: _selectedDuration,
              onChanged: (sessionDuration) {
                setState(() {
                  _selectedDuration = sessionDuration;
                });
              },
            ),
            _SessionRadio(
              label: '15m',
              value: SessionDuration.FIFTEEN,
              groupValue: _selectedDuration,
              onChanged: (sessionDuration) {
                setState(() {
                  _selectedDuration = sessionDuration;
                });
              },
            ),
            _SessionRadio(
              label: '30m',
              value: SessionDuration.THIRTY,
              groupValue: _selectedDuration,
              onChanged: (sessionDuration) {
                setState(() {
                  _selectedDuration = sessionDuration;
                });
              },
            ),
            _SessionRadio(
              label: '45m',
              value: SessionDuration.FORTYFIVE,
              groupValue: _selectedDuration,
              onChanged: (sessionDuration) {
                setState(() {
                  _selectedDuration = sessionDuration;
                });
              },
            ),
            _SessionRadio(
              label: '1h',
              value: SessionDuration.HOUR,
              groupValue: _selectedDuration,
              onChanged: (sessionDuration) {
                setState(() {
                  _selectedDuration = sessionDuration;
                });
              },
            ),
          ],
        ),
        Spacer(),
      ]
    );
  }
}

class _SessionRadio extends StatelessWidget {
  const _SessionRadio({
    @required this.label,
    @required this.value,
    @required this.groupValue,
    @required this.onChanged
  });
  final String label;
  final int value;
  final int groupValue;
  final Function onChanged;

  @override Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Radio<int>(
          value: value,
          groupValue: groupValue,
          onChanged: (int sessionDuration) {
            print("chose $sessionDuration");
            onChanged(sessionDuration);
          }
      ),
      Text(label),
    ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:unplugg_prototype/blocs/session_bloc.dart';

class ActionTab extends StatefulWidget {
  ActionTab({Key key}) : super(key: key);

  @override
  _ActionState createState() => _ActionState();
}

enum SessionDuration { fifteen, thirty, fortyfive, hour }

class _ActionState extends State<ActionTab> {

  SessionDuration _selectedDuration = SessionDuration.thirty;

  // not that we will but if we were to use this type of control,
  // results would have to be localized
  int _sessionDurationToInt(SessionDuration sessionDuration) {
    switch(sessionDuration) {
      case SessionDuration.fifteen:
        return 15;
      case SessionDuration.thirty:
        return 30;
      case SessionDuration.fortyfive:
        return 45;
      case SessionDuration.hour:
        return 60;
    }
  }

  Widget SessionButton(BuildContext context) {
    return Center(
      child: Container(
        /*child: Ink(
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: CircleBorder(),
          ),*/
          child: IconButton(
            iconSize: ButtonTheme.of(context).minWidth,
            icon: ImageIcon(AssetImage('assets/logo.png')),
            color: Colors.green,
            onPressed: () async {
              Navigator.pushNamed(context, '/session', arguments: <String, dynamic> {
                'sessionDuration': _sessionDurationToInt(_selectedDuration)
              });
            },
          ),
        /*),*/
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      //crossAxisAlignment: CrossAxisAlignment.stretch,
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
              label: '15m',
              value: SessionDuration.fifteen,
              groupValue: _selectedDuration,
              onChanged: (sessionDuration) {
                setState(() {
                  _selectedDuration = sessionDuration;
                });
              },
            ),
            _SessionRadio(
              label: '30m',
              value: SessionDuration.thirty,
              groupValue: _selectedDuration,
              onChanged: (sessionDuration) {
                setState(() {
                  _selectedDuration = sessionDuration;
                });
              },
            ),
            _SessionRadio(
              label: '45m',
              value: SessionDuration.fortyfive,
              groupValue: _selectedDuration,
              onChanged: (sessionDuration) {
                setState(() {
                  _selectedDuration = sessionDuration;
                });
              },
            ),
            _SessionRadio(
              label: '1h',
              value: SessionDuration.hour,
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
  final SessionDuration value;
  final SessionDuration groupValue;
  final Function onChanged;

  @override Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Radio<SessionDuration>(
          value: value,
          groupValue: groupValue,
          onChanged: (SessionDuration sessionDuration) {
            print("chose $sessionDuration");
            onChanged(sessionDuration);
          }
      ),
      Text(label),
    ],
    );
  }
}
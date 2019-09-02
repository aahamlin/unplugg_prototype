import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';

import '../../../router.dart';

class ActionTab extends StatefulWidget {
  ActionTab({Key key}) : super(key: key);

  @override
  _ActionState createState() => _ActionState();
}

class SessionDuration {
  static const DEBUG = 1; // for debugging
  static const FIFTEEN = 15;
  static const THIRTY = 30;
  static const FORTYFIVE = 45;
  static const HOUR = 60;
}

class _ActionState extends State<ActionTab> {
  int _selectedDuration = SessionDuration.THIRTY;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Expanded(
            child: SessionButton(context),
            flex: 3,
          ),
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: _buildRadioButtons(),
            ),
          ),
        ]);
  }

  _buildRadioButtons() {
    return <Widget>[
      _SessionRadio(
        label: '1m (debug)',
        value: SessionDuration.DEBUG,
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
    ];
  }

  Widget SessionButton(BuildContext context) {
    return Consumer<SessionStateBloc>(
      builder: (context, bloc, child) {
        return Container(
          padding: EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: InkWell(
              child:
                  ImageIcon(AssetImage('assets/logo.png'), color: Colors.green),
              onTap: () async {
                bloc.start(duration: Duration(minutes: _selectedDuration));
                Navigator.pushNamed(context, RouteNames.SESSION);
              },
            ),
          ),
        );
      },
    );
  }
}

class _SessionRadio extends StatelessWidget {
  const _SessionRadio(
      {@required this.label,
      @required this.value,
      @required this.groupValue,
      @required this.onChanged});

  final String label;
  final int value;
  final int groupValue;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Radio<int>(
            value: value,
            groupValue: groupValue,
            onChanged: (int sessionDuration) {
              onChanged(sessionDuration);
            }),
        Text(label),
      ],
    );
  }
}

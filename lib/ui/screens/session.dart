import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/router.dart';

import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/ui/widgets/session_timer.dart';
import 'package:unplugg_prototype/ui/widgets/bloc_listener.dart';
import 'package:unplugg_prototype/core/shared/log_manager.dart';

class SessionScreen extends StatelessWidget {

  final _logger = LogManager.getLogger('SessionScreen');

  SessionScreen({Key key}) : super(key: key);

  @override Widget build(BuildContext context) {
    debugPrint("BUILDING SESSION SCREEN");
    final SessionStateBloc bloc = Provider.of<SessionStateBloc>(context);
    return BlocListener(
      bloc: bloc,
      listener: (context, session) {
        if(session.result == SessionResult.failure) {
          Navigator.pushReplacementNamed(context, RouteNames.FAILURE);
        }
        else if(session.result == SessionResult.success) {
          Navigator.pushReplacementNamed(context, RouteNames.SUCCESS);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Session'),
        ),
        backgroundColor: Colors.green[400],
        body: Consumer<SessionStateBloc>(
          builder: (context, bloc, child) {
          return StreamBuilder<Session>(
              stream: bloc.stream,
              initialData: bloc.currentState,
              builder: (context, snapshot) {
                final session = snapshot.data;

                if (session == null) {
                  return Text('Session Unavailable');
                }

                return WillPopScope(
                  onWillPop: () =>
                      _onWillPopScope(context, session, (willCancel) {
                        Navigator.of(context).pop(willCancel);
                        if (willCancel) {
                          // terminate the session
                          _logger.d('User cancelled session');
                          bloc.cancel(session);
                        }
                      },
                      ),
                  child: Center(
                    child:
                    SessionTimer(
                      session: session,
                      bloc: bloc,
                    ),
                  ),
                );
              }
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPopScope(BuildContext context,
      Session session,
      Function(bool) onDismiss) async {
    return showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('End Your Unplugg Session?'),
          content: Text('You are close to earning ${session.duration.inMinutes} moments.'),//${model.duration.inMinutes}
          actions: <Widget>[
            FlatButton(
                onPressed: () async => onDismiss(false),
                child: const Text('NO')
            ),
            FlatButton(
              onPressed: () async => onDismiss(true),
              child: const Text('YES'),
            )
          ],
        );
      },
    );
  }

}


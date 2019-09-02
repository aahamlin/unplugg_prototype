import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';
import 'package:unplugg_prototype/router.dart';

import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';
//import 'package:unplugg_prototype/core/services/notifications.dart';
import 'package:unplugg_prototype/ui/widgets/session_timer.dart';
import 'package:unplugg_prototype/core/shared/utilities.dart';
import 'package:unplugg_prototype/ui/widgets/bloc_listener.dart';
import 'package:unplugg_prototype/viewmodel/session_state_viewmodel.dart';
import 'package:unplugg_prototype/core/shared/log_manager.dart';
//import 'package:unplugg_prototype/core/interrupts.dart';

class SessionScreen extends StatelessWidget {

  final _logger = LogManager.getLogger('SessionScreen');
//  final notificationManager = NotificationManager();
  final SessionStateViewModel vm;

  SessionScreen({Key key, SessionStateViewModel this.vm}) : super(key: key);

  @override Widget build(BuildContext context) {
    final SessionStateBloc bloc = Provider.of<SessionStateBloc>(context);
    return BlocListener(
      bloc: bloc,
      listener: (context, sessionState) {
        if(sessionState.state == SessionState.failed) {
          Navigator.pushReplacementNamed(context, RouteNames.FAILURE);
        }
        else if(sessionState.state == SessionState.succeeded) {
          Navigator.pushReplacementNamed(context, RouteNames.SUCCESS);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Session'),
        ),
        body: Consumer<SessionStateBloc>(
          builder: (context, bloc, child) {
          return StreamBuilder<SessionStateViewModel>(
              stream: bloc.stream,
              initialData: vm,
              builder: (context, snapshot) {
                debugPrint('updated data ${snapshot.data}');
                  if (snapshot.hasError) {
                    return _displayError(snapshot.error);
                  }

                debugPrint('session screen state: ${snapshot.data?.state}');

                if(SessionState.running == snapshot.data?.state) {
                  return _sessionPage(context, snapshot.data.session, bloc);
                }

                return Center(child: CircularProgressIndicator());
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

  Widget _sessionPage(BuildContext context, Session session, SessionStateBloc bloc) {

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
        child: SessionTimer(
          session: session,
          bloc: bloc,
        ),
      ),
    );
  }

  Widget _displayError(error) {
    return Center(
      child:Text(
        error.toString(),
        style: TextStyle(color: Colors.red),
      )
    );
  }
}


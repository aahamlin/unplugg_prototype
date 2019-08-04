import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models.dart';
import 'package:unplugg_prototype/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/shared/notifications.dart';
import 'package:unplugg_prototype/widgets/session_timer.dart';
import 'package:unplugg_prototype/shared/utilities.dart';
import 'package:unplugg_prototype/shared/session_model.dart';
import 'package:unplugg_prototype/shared/session_state.dart';

class SessionPage extends StatelessWidget {

  final Duration duration;
  SessionPage({Key key, Duration this.duration}) : super(key: key);

  @override Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Session'),
      ),
      body: ProxyProvider<DBProvider, SessionModelBloc>(
        builder: (context, dbProvider, bloc) => SessionModelBloc(
          dbProvider: dbProvider,
          duration: duration,
        ),
        child: Consumer<SessionModelBloc>(
          builder: (context, bloc, child) {
            return StreamBuilder<SessionModel>(
              stream: bloc.sessionModel,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var model = snapshot.data;

                  if (model.state == SessionState.completed) {
                    return Center(
                      child: Text('You earned ${model.duration.inMinutes} moment(s).'),
                    );
                  }
                  else if (model.state == SessionState.cancelled) {
                    return Center(
                      child: Text('Sorry, you did not earn ${model.duration.inMinutes} moment(s).'),
                    );
                  }
                  else {
                    return WillPopScope(
                      onWillPop: () => _onWillPopScope(context, model, (model) => bloc.cancel(model)),
                      child: Center(
                        child: SessionTimer(
                          duration: calculateDurationSinceStartTime(model.startTime, model.duration),
                          onComplete: () => bloc.complete(model),
                          onEvent: (event) {
                            model =_setupNotifications(model, event);
                            bloc.record(model, event);
                          },
                        ),
                      ),
                    );
                  }
                }
                else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  SessionModel _setupNotifications(SessionModel model, Event event) {

    var notificationManager = NotificationManager();
    var eventType = event.eventType;

    // on pause, setup notification for 2 minutes with 3 min session expiry
    if (eventType == 'inactive') {
      var warningNotificationTime = DateTime.now().add(Duration(seconds: 30));
      var sessionExpirationTime = DateTime.now().add(Duration(minutes: 1));

      model.expiry = sessionExpirationTime;
      //await dbProvider.insertOrUpdateSession(model.toSession());

      notificationManager.showMomentsExpiringNotification(
          sessionExpirationTime,
          warningNotificationTime);
    }

    // on locking or resumed, within time window, cancel notification, cancel expiry
    else if (eventType == 'locking' || eventType == 'resumed') {
      if(event.timeStamp.isBefore(model.expiry)) {
        notificationManager.cancelMomentsExpiringNotification();
        model.expiry = null;
        //await dbProvider.insertOrUpdateSession(model.toSession());
      }
    }

    return model;
  }

  Future<bool> _onWillPopScope(BuildContext context, SessionModel model, Function(SessionModel) cancelCallback) async {
    return showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('End Your Unplugg Session?'),
          content: Text('You are close to earning ${model.duration.inMinutes} moments.'),
          actions: <Widget>[
            FlatButton(
                onPressed: () async {
                  Navigator.of(context).pop(false);
                },
                child: const Text('NO')
            ),
            FlatButton(
              onPressed: () async {
                await cancelCallback(model);
                Navigator.of(context).pop(true);
              },
              child: const Text('YES'),
            )
          ],
        );
      },
    );
  }
}


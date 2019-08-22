import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:unplugg_prototype/router.dart';

import 'package:unplugg_prototype/core/bloc/session_state_bloc.dart';
import 'package:unplugg_prototype/core/services/notifications.dart';
import 'package:unplugg_prototype/ui/widgets/session_timer.dart';
import 'package:unplugg_prototype/core/shared/utilities.dart';
import 'package:unplugg_prototype/ui/widgets/bloc_listener.dart';
import 'package:unplugg_prototype/viewmodel/session_viewmodel.dart';
import 'package:unplugg_prototype/core/shared/log_manager.dart';

class SessionScreen extends StatelessWidget {

  final _logger = LogManager.getLogger('SessionScreen');
  final notificationManager = NotificationManager();
  final SessionViewModel vm;

  SessionScreen({Key key, SessionViewModel this.vm}) : super(key: key);

  @override Widget build(BuildContext context) {
    final SessionStateBloc sessionStateBloc = Provider.of<SessionStateBloc>(context);

    return BlocListener(
      bloc: sessionStateBloc,
      listener: (context, vm) {
        switch(vm.state) {
          case SessionViewState.succeeded:
//            _cancelExpiryNotification(sessionStateBloc, vm);
            Navigator.pushReplacementNamed(context, RouteNames.COMPLETE, arguments: vm);
            break;
          case SessionViewState.failed:
//            _cancelExpiryNotification(sessionStateBloc, vm);
            Navigator.pushReplacementNamed(context, RouteNames.INCOMPLETE, arguments: vm);
            break;
          default:
            debugPrint('Session screen: ${vm.state}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Session'),
        ),
        body: Consumer<SessionStateBloc>(
          builder: (context, bloc, child) {
          return StreamBuilder<SessionViewModel>(
              stream: bloc.stream,
              initialData: vm,
              builder: (context, snapshot) {
                if(snapshot.hasData) {
                  var vm = snapshot.data;
                  return WillPopScope(
                    onWillPop: () => _onWillPopScope(context,
                        vm, (willCancel) {
                          if (willCancel) {
                            // terminate the session
                            _logger.d('User cancelled session');
                            bloc.cancel(vm);
                          }
                          Navigator.of(context).pop(willCancel);
                      },
                    ),
                    child: Center(
                      child: SessionTimer(
                        duration: calculateDurationSinceStartTime(
                            vm.startTime,
                            vm.duration),
                        onInterrupt: (event) {
                          // todo: bloc should calculate N interrupts to failure
                          debugPrint('${event.name}');
                          bloc.fail(vm);
                        },
                        onComplete: () => bloc.complete(vm),
                      ),
                    ),
                  );
                }
                else if(snapshot.hasError){
                  return Center(
                    child:Text(snapshot.error.toString(),
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }
                else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<bool> _onWillPopScope(BuildContext context,
      SessionViewModel viewModel,
      Function(bool) onDismiss) async {
    return showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('End Your Unplugg Session?'),
          content: Text('You are close to earning ${viewModel.duration.inMinutes} moments.'),//${model.duration.inMinutes}
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

//  _setExpiryNotification(SessionStateBloc bloc, SessionViewModel vm) async {
//    var expiry = Duration(seconds: 15);
//    var notify = Duration(seconds: 3);
//
//    var endTime = vm.startTime.add(vm.duration);
//    var durationToEnd = endTime.difference(DateTime.now());
//    if (durationToEnd < expiry) {
//      expiry = durationToEnd;
//    }
//    if (durationToEnd > notify) {
//      notificationManager.showMomentsExpiringNotification(expiry, notify);
//    } else {
//      _logger.d('Less than ${notify.inSeconds} remaining, skip notification');
//    }
//
//    int count = await bloc.setInterruptOnSession(vm, expiry);
//    _logger.d('Session interrupted $count times');
//    if (count > 2) {
//      notificationManager.cancelSessionInterruptedNotification();
//      notificationManager.showSessionFailedNotification();
//      bloc.fail(vm);
//    }
//    else if (count > 1) {
//      notificationManager.cancelMomentsExpiringNotification();
//      notificationManager.showSessionInterruptNotification();
//    }
//  }
//
//  _cancelExpiryNotification(SessionStateBloc bloc, SessionViewModel vm) async {
//    _logger.d('Interrupt cancelled');
//    notificationManager.cancelMomentsExpiringNotification();
//    notificationManager.cancelSessionInterruptedNotification();
//    bloc.cancelInterruptOnSession(vm);
//  }

}


import 'package:flutter/material.dart';

import 'package:unplugg_prototype/data/blocs/bloc_provider.dart';
import 'package:unplugg_prototype/data/blocs/session_bloc.dart';
import 'package:unplugg_prototype/data/models/session.dart';

class SessionsTab extends StatelessWidget {
  /*static const _eventChannel = const EventChannel('unpluggyourself.com/dp');*/
  /*_eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);*/

  @override
  Widget build(BuildContext context) {

    print('session tab build triggered');
    SessionBloc sessionBloc = BlocProvider.of<SessionBloc>(context);
    sessionBloc.getSessions();

    return StreamBuilder<List<Session>>(
      stream: sessionBloc.sessions,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (BuildContext context, int index) {
                Session session = snapshot.data[index];
                int minutes = session.duration.inMinutes;

                return Dismissible(
                  key: UniqueKey(),
                  background: Container(color: Colors.red),
                  onDismissed: (direction) async {
                    await sessionBloc.delete(session.id);
                  },
                  child: ListTile(
                    title: Text("Session $minutes minutes"),
                    subtitle:
                    Text("Started at " + session.event.timeStamp.toIso8601String()),
                  ),
                );
              });
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }


}

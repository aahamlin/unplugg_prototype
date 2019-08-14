import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
//import 'package:unplugg_prototype/blocs/session_state_bloc.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';

class SessionsTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    DBProvider dbProvider = Provider.of(context);

    return FutureBuilder<List<Session>>(
      initialData: List<Session>(),
      future: dbProvider.getAllSessions(),
      builder: (context, snapshot) {
        switch(snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            return CircularProgressIndicator();
          case ConnectionState.done:
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            else {
              var sessionList = snapshot.data;

              return ListView.builder(
                  itemCount: sessionList.length,
                  itemBuilder: (context, index) {

                    var sessionEntry = sessionList[index];

                    return ListTile(
                      leading: Icon(Icons.event),
                      title: Text('Session ${sessionEntry.id}'),
                      subtitle: Text('${sessionEntry}'),
                      isThreeLine: true,
                    );
                  });
            }

        }
      },
    );
  }

  /*Widget _old_build(BuildContext context) {
    SessionBloc sessionBloc = Provider.of<SessionBloc>(context);
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
  }*/


}

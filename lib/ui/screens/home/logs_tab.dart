import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
//import 'package:unplugg_prototype/blocs/session_state_bloc.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/data/models/log_entry.dart';

class LogsTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    DBProvider dbProvider = Provider.of(context);

    return FutureBuilder<List<LogEntry>>(
      initialData: List<LogEntry>(),
      future: dbProvider.getAllLogs(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        else if (snapshot.hasData) {
          var logs = snapshot.data;
          return ListView.builder(
            itemCount: logs.length,
            itemBuilder: (context, index) {

              var logEntry = logs[index];

              var title = '${logEntry.timeStamp} ${logEntry.level}';
              var errStr = logEntry.error != null ? ' ERROR ${logEntry.error}' : '';
              var body = '${logEntry.message}$errStr';

              return Container(
                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text(title,
                      style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(body),
                  ],
                ),
              );
            });
        }
        else {
          return CircularProgressIndicator();
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

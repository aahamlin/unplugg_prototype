import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
//import 'package:unplugg_prototype/blocs/session_state_bloc.dart';
import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/models.dart';

class EventsTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    DBProvider dbProvider = Provider.of(context);

    return FutureBuilder<List<Event>>(
      initialData: List<Event>(),
      future: dbProvider.getAllEvents(),
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
              var eventList = snapshot.data;

              return ListView.builder(
                  itemCount: eventList.length,
                  itemBuilder: (context, index) {

                    var entry = eventList[index];

                    return ListTile(
                      leading: Icon(Icons.event),
                      title: Text('Event ${entry.id}'),
                      subtitle: Text('${entry.eventType} during Session ${entry.session_id}\n${entry.timeStamp.toLocal()}'),
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

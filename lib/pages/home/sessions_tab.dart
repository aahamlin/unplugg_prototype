import 'package:flutter/material.dart';

//import 'package:provider/provider.dart';
//import 'package:unplugg_prototype/blocs/session_bloc.dart';
//import 'package:unplugg_prototype/data/models.dart';

class SessionsTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    print('session tab build triggered');

    return Text(
          'Session History',
          style: Theme
              .of(context)
              .textTheme
              .title
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

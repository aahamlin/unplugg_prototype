import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
//import 'package:unplugg_prototype/blocs/session_state_bloc.dart';
import 'package:unplugg_prototype/core/data/database.dart';
import 'package:unplugg_prototype/core/data/models/session.dart';

class SessionsTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    DBProvider dbProvider = DBProvider();

    return FutureBuilder<List<Session>>(
      initialData: List<Session>(),
      future: dbProvider.getAllSessions(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        else if (snapshot.hasData) {
          var sessionList = snapshot.data;
          return ListView.builder(
            itemCount: sessionList.length,
            itemBuilder: (context, index) {

              var sessionEntry = sessionList[index];

              return ListTile(
                leading: Icon(Icons.event),
                title: Text('Session ${sessionEntry.id}'),
                subtitle: Text('$sessionEntry'),
                isThreeLine: true,
              );
            });
        }
        else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

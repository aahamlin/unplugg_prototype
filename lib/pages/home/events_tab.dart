import 'package:flutter/material.dart';

import 'package:unplugg_prototype/data/blocs/bloc_provider.dart';
import 'package:unplugg_prototype/data/blocs/event_bloc.dart';
import 'package:unplugg_prototype/data/models/event.dart';

class EventsTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    print('event tab build triggered');
    EventBloc eventBloc = BlocProvider.of<EventBloc>(context);
    eventBloc.getEvents();

    return StreamBuilder<List<Event>>(
        stream: eventBloc.events,
        //initialData: List<Event>.from([Event(eventType: "No events", timeStamp: DateTime.now())]),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  Event event = snapshot.data[index];
                  String event_type = event.eventType;
                  return Dismissible(
                    key: UniqueKey(),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) async {
                      await eventBloc.delete(event.id);
                    },
                    child: ListTile(
                      title: Text("$event_type triggered"),
                      subtitle: Text("at " + event.timeStamp.toIso8601String()),
                    ),
                  );
                });
          }
          else if (snapshot.hasError) {
            return Text(snapshot.error);
          }
          else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
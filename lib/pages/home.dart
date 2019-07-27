import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:csv/csv.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:provider/provider.dart';

import 'package:unplugg_prototype/data/database.dart';
import 'package:unplugg_prototype/data/exporter.dart';

import 'package:unplugg_prototype/blocs/session_bloc.dart';

import 'package:unplugg_prototype/pages/home/sessions_tab.dart';
import 'package:unplugg_prototype/pages/home/action_tab.dart';
import 'package:unplugg_prototype/pages/home/user_tab.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _selectedIndex = 1;

  static const TextStyle _optionStyle = TextStyle(fontWeight: FontWeight.bold);

  static List<Widget> _widgetOptions = <Widget>[
    SessionsTab(),
    ActionTab(),
    UserTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override void initState() {
    super.initState();
    print('home page initialized');
  }

  @override void dispose() {
    print('home page disposing');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DBProvider db = Provider.of<DBProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Unplugg'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              final events = await db.getAllUnpluggEvents();
              var export = modelToList(events, null, (event) {
                List result = List();
                result.add(event.id);
                result.add(event.eventType);
                result.add(event.timeStamp);
                return result;
              });
              var output = const ListToCsvConverter().convert(export);
              await Share.file('Unplugg data', 'data.csv', Utf8Encoder().convert(output), 'text/csv',
                  text: 'Data as of ' + DateTime.now().toIso8601String());
            },
          ),
          IconButton(
            icon: Icon(Icons.clear_all),
            onPressed: () async {
              return showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Delete All Events?'),
                    content: const Text('This operation is permanent and cannot be undone.'),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () async {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancel')
                      ),
                      FlatButton(
                        onPressed: () async {
                          Provider.of<SessionBloc>(context).deleteAll();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Ok'),
                      )
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.collections),
              title: Text('Sessions', style: _optionStyle),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call_to_action),
              title: Text('Unplugg', style: _optionStyle),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              title: Text('You', style: _optionStyle),
            )
          ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

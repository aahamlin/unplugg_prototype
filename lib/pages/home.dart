import 'package:flutter/material.dart';

import 'package:unplugg_prototype/data/blocs/bloc_provider.dart';
import 'package:unplugg_prototype/data/blocs/event_bloc.dart';
import 'package:unplugg_prototype/data/blocs/session_bloc.dart';

import 'package:unplugg_prototype/pages/home/events_tab.dart';
import 'package:unplugg_prototype/pages/home/sessions_tab.dart';
import 'package:unplugg_prototype/pages/home/action_tab.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {

  int _selectedIndex = 1;

  EventBloc _eventBloc = EventBloc();
  SessionBloc _sessionBloc = SessionBloc();

  static const TextStyle _optionStyle = TextStyle(fontWeight: FontWeight.bold);

  static List<Widget> _widgetOptions = <Widget>[
    SessionsTab(),
    ActionTab(),
    EventsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(state.toString());
    _eventBloc.newEvent(state.toString());
  }

  @override void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override void dispose() {
    print('home page dispose');
    WidgetsBinding.instance.removeObserver(this);
    _eventBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.title)
      ),
      body: BlocProvider(
        bloc: _eventBloc,
        child: BlocProvider(
          bloc: _sessionBloc,
          child: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ),
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
              icon: Icon(Icons.list),
              title: Text('Events', style: _optionStyle),
            )
          ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

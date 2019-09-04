import 'package:flutter/material.dart';
import 'package:unplugg_prototype/ui/screens/home/sessions_tab.dart';
import 'package:unplugg_prototype/ui/screens/home/action_tab.dart';
import 'package:unplugg_prototype/ui/screens/home/logs_tab.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int _selectedIndex = 1;
  static const TextStyle _optionStyle = TextStyle(fontWeight: FontWeight.bold);

  static List<Widget> _widgetOptions = <Widget>[
    SessionsTab(),
    ActionTab(),
    LogsTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }


  @override
  Widget build(BuildContext context) {
  // todo: display toast from VM when in success or failure state
    return Scaffold(
      appBar: AppBar(
        title: Text('Unplugg', style: TextStyle(fontFamily: 'Barista')),
      ),
      body: Center(
          child: _widgetOptions.elementAt(_selectedIndex)
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
              title: Text('Log', style: _optionStyle),
            )
          ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:unplugg_prototype/viewmodel/session_viewmodel.dart';

class IncompleteScreen extends StatelessWidget {

  IncompleteScreen({Key key, SessionViewModel vm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Failed'),
      ),
      body: Center(
        child: const Text('Session not completed!',
          style: TextStyle(color: Colors.red)),
      ),
    );
  }

}
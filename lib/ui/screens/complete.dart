import 'package:flutter/material.dart';
import 'package:unplugg_prototype/viewmodel/session_state_viewmodel.dart';

class CompleteScreen extends StatelessWidget {

  CompleteScreen({Key key, SessionStateViewModel vm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
         title: Text('Completed'),
        ),
        body: Center(
          child: const Text('Session completed successfully!'),
        ),
      );
  }

}
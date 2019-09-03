import 'package:flutter/material.dart';

class CompleteScreen extends StatelessWidget {

  CompleteScreen({Key key}) : super(key: key);

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
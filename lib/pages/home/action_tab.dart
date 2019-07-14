import 'package:flutter/material.dart';


class ActionTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Theme.of(context).buttonColor,
      child: Text("Unplugg"),
      onPressed: () => Navigator.pushNamed(context, '/session')
    );
  }
}
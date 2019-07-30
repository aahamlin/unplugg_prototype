import 'package:flutter/material.dart';


class UserTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
              'You',
              style: Theme.of(context).textTheme.title
      );
  }
}
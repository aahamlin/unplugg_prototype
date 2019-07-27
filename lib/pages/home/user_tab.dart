import 'package:flutter/material.dart';


class UserTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
            'You',
            style: Theme.of(context).textTheme.title
        ),
    );
  }
}
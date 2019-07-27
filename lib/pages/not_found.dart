import 'package:flutter/material.dart';

class NotFoundPage extends StatefulWidget {
  NotFoundPage({Key key, this.name}) : super(key: key);
  final String name;

  @override _NotFoundPageState createState() => _NotFoundPageState();
}

class _NotFoundPageState extends State<NotFoundPage> {

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Page not found', style: Theme.of(context).textTheme.title),
            Text(widget.name, style: Theme.of(context).textTheme.subtitle),
          ],
        ));
  }
}
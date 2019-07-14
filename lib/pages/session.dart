import 'package:flutter/material.dart';

class SessionPage extends StatefulWidget {
  SessionPage({Key key}) : super(key: key);

  @override _SessionPageState createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Session"),
      ),
      body: new Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("New Session", style: Theme.of(context).textTheme.title,),
              FlatButton(
                color: Theme.of(context).buttonColor,
                child: Text("Back"),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          )
        )
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:unplugg_prototype/data/unplugg_event.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unplugg Prototype',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'Unplugg'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  Widget _buildEventList(BuildContext context, AsyncSnapshot<List<UnpluggEvent>> snapshot) {
    if (snapshot.hasData) {
      return ListView.builder(
        itemCount: snapshot.data.length,
        itemBuilder: (BuildContext context, int index) {
          UnpluggEvent ue = snapshot.data[index];
          return ListTile(
            title: Text(ue.eventType),
            subtitle: Text(ue.timeStamp.toIso8601String()),
          );
        });
    }
    else {
      return Center(child: CircularProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<UnpluggEvent>>(
          future: UnpluggEventProvider.db.getAllUnpluggEvents(),
          builder: _buildEventList),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add event',
        child: Icon(Icons.add),
        onPressed: () async {
          UnpluggEvent ue = UnpluggEvent(
            eventType: "lock",
            timeStamp: DateTime.now());
          await UnpluggEventProvider.db.newUnpluggEvent(ue);
          setState(() {});
        },
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

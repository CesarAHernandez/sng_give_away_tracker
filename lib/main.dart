import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget{
  @override
  Widget build (BuildContext context){
    return new MaterialApp(
      title: "Sng GiveAwayTracker",
      home: new MyHomePage(title: 'Sng GiveAwayTracker HomePage'),
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super (key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _result = "Loading...";
  int _statusCode = 0;

  void initState() {
    _connect();
  }

  void _connect() async {
    String result = "10";
    int statusCode = 32;

  setState((){
    _result = result;
    _statusCode = statusCode;
  });
}
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("SNG Give Away Tracker"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text("$_result"),
            new Text("$_statusCode"),
          ],
        ),
      ),
    );
  }
}


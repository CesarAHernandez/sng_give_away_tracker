import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

import 'posts.dart';
//
//TODO: create a firebase database to add the posts that include Giveaway
//This is done so that i can use FCM(Firebase Cloud Messaging) to send me a notifiction
//I can extend this so that I can have a feature "On Going Give aways"
//The On going tab will have a section so that i can input a date and it can let me know when it ends
//The post will ge gotten from the firebase database
//

Future<String> readGoogleInfo() async{
  try{
    String googleInfo = await rootBundle.loadString('config/google_info.json');
    return googleInfo;
  }catch (e) {
    return e.toString();
  }
}

Future<void> main() async{
  String googleInfoRaw = await readGoogleInfo();
  Map<String,dynamic> googleInfo = json.decode(googleInfoRaw);

  final FirebaseApp app = await FirebaseApp.configure(
      name: 'postDatabase',
      options: FirebaseOptions (
          googleAppID: googleInfo['googleAppID'],
          apiKey: googleInfo['apiKey'],
          databaseURL: googleInfo['databaseURL']
      )
  );
  runApp(new MyApp(app:app));
}

class MyApp extends StatefulWidget{
  MyApp({this.app});
  final FirebaseApp app;
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp>{
  List<Post> _posts;
  //
  //postToSend is the post that is going to be sent to the database
  //
  Post postToSend;
  DatabaseReference _postRef;
  final client  =  new http.Client();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    _postRef = database.reference().child('_posts');
    refreshPosts();
}


//This is responsible to submit the post to the database
void handleSubmit(){
  _postRef.push().set(_posts[0].toJson());
}


@override
Widget build(BuildContext context){
  return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("SNG GiveAwayTracker"),
        ),
        body: FutureBuilder<List<Post>>(
          future: fetchPosts(client),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator(),);
            else if (snapshot.hasData)
              return displayPosts(snapshot);
            else
              return Center(child: Text("No Info yet"),);
          },
        ),
      )
  );
}

Future<Null> refreshPosts() async{
  List<Post> posts = await fetchPosts(client);

  setState(() {
    _posts = posts;
  });
  return null;
}
Widget displayPosts(AsyncSnapshot snapshot) {
  _posts = snapshot.data;
  return RefreshIndicator(
      onRefresh: refreshPosts,
      child: ListView.builder(
          itemCount: _posts?.length,
          itemBuilder:(context,index){
            return Container(
              color: Color.fromARGB(255, 201, 203, 202),
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.all(15.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize:  MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children:[
                        new Text(_posts[index]?.title,
                          style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                        new Text(_posts[index]?.postOwner)
                      ],
                    ),
                  ),
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                                  Icons.assignment,
                                  size: 35.0,
                                ),
                        ),

                        Text(_posts[index]?.postLocation),
                      ]
                  ),
                ],
              ),
            );
          }
      )
  );
}
}


import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'posts.dart';
import 'giveawaypostpage.dart';
//
// TODO: Update the README.md
// TODO: Make feature -> open a new screen that has all the giveaways and have an options to put 
// some text next to it so that i can manually put the end date for the giveaway
// Maybe have it message me when it is almost done
// I can extend this so that I can have a feature "On Going Give aways"
// The On going tab will have a section so that i can input a date and it can let me know when it ends
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
  //
  // GoogleInfoRaw is the String version of the google info that i want to get
  //
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
  runApp(new App(app:app));
}
class App extends StatelessWidget{
  final FirebaseApp app;
  App({this.app});

  Widget build(BuildContext context){
    return MaterialApp(
      routes: <String, WidgetBuilder> {
        GiveAwayPosts.routeName: (BuildContext context) => new GiveAwayPosts(app: app,),
      },
      home: new MyApp(app: app,),
    );
  }

}
class MyApp extends StatefulWidget{
  MyApp({this.app});
  final FirebaseApp app;
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp>{
  List<Post> _posts;
  DatabaseReference _postRef;
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final client  =  new http.Client();

  @override
  void initState() {
    super.initState();
    final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
    _postRef = database.reference().child('_posts');
    //
    //Configuration for the firebase messaging 
    //To do what when something happens
    //
    _firebaseMessaging.configure(
      onMessage: (Map<String,dynamic> message){
        print("onMessage: $message");
      },
      onResume: (Map<String,dynamic> message){
        print("onResume: $message");
      },
      onLaunch: (Map<String,dynamic> message){
        print("onLaunch: $message");
      },
    );
    // 
    // Getting the token from the user and then displaying it to the console
    // If there is no token then the assert fails
    // 
    _firebaseMessaging.getToken().then((String token){
      assert(token != null);
      //you can have setstate here 
      print("Push Messaging token: $token");
    });
    _firebaseMessaging.subscribeToTopic("GiveAway");
    // 
    // refreshes the posts when the app initialized, 
    // I do this so that the state: _post is updated
    // 
    // refreshPosts();

  }//initState

// 
//This is responsible to submit the post to the database
// 
/*
void handleSubmit(index){
  _postRef.push().set(_posts[0].toJson());
}
*/


@override
Widget build(BuildContext context){
  return Scaffold(
        appBar: AppBar(
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pushNamed(context,GiveAwayPosts.routeName),
              icon: Icon(Icons.arrow_right),
              )
          ],
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
      );
}
// 
// Refreshes the posts by recalling fetchPosts when onRefresh is called
// 
Future<Null> refreshPosts() async{
  List<Post> posts = await fetchPosts(client);
    // 
    // Test subscriptions to the giveaway for a base for testing
    // This should be dynamic or somthing 
    // 

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
                          onPressed: () => _postRef.push().set(_posts[index].toJson()),
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

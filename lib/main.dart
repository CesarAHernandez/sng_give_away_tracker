import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import 'posts.dart';
import 'drawer.dart';
import 'giveawaypostpage.dart';
//
// TODO: Update the README.md
// TODO : Feature when i tap on a post it would take me to the website on the url
//
Future<String> readGoogleInfo() async{
  try{
    String googleInfo = await rootBundle.loadString('config/google_info.json');
    return googleInfo;
  }catch (e) {
    print(e.toString());
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
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  StreamSubscription _onDestroy;
  StreamSubscription _onScrollYChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  double oldYPos;
  StreamSubscription<String> _onUrlChanged;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  // final client  =  new http.Client();

  @override
  void initState() {
    super.initState();
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

    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      print("This webpage was destroyed");
    });
    _onStateChanged = flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state){
      print('onStateChanged: ${state.type} ${state.url}');
    });
    _onScrollYChanged =
        flutterWebviewPlugin.onScrollYChanged.listen((double x) async{ 
          if(mounted){
            print('oldPos: ${oldYPos} -> ${x}');
            await Future.delayed(Duration(milliseconds: 1000));
            setState(() {
              oldYPos = x;
            });
              if(oldYPos > 0 && x == 0){
                flutterWebviewPlugin.reload();
              }
          }

    });


    void dispose(){
      _onScrollYChanged.cancel();
      _onUrlChanged.cancel();
      _onDestroy.cancel();
      flutterWebviewPlugin.dispose();
      super.dispose();
    }
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
        drawer: CreateDrawer(),
        appBar: AppBar(
          title: Text("SNG GiveAwayTracker"),
        ),
        body: FutureBuilder<List<Post>>(
          future: Post.getFrontPagePosts(),
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
  List<Post> posts = await Post.getFrontPagePosts();
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
                          // Checks to see if the url can be launch if it can it will 
                          // Otherwise it will throw
                          // onPressed: () async => await canLaunch(_posts[index]?.postLink)
                          //     ? await launch(_posts[index]?.postLink)
                          //     : throw "Could not launch URL",
                          onPressed: () async{
                            Navigator.push(context, new MaterialPageRoute(
                                            builder: (_) => new WebviewScaffold(
                                                url: _posts[index]?.postLink,
                                                withLocalUrl: true,
                                                scrollBar: true,
                                                appBar: new AppBar(
                                                  title: new Text(_posts[index]?.title),
                                                  actions: <Widget>[
                                                      new IconButton(
                                                        icon: new Icon(Icons.refresh),
                                                        tooltip: 'Refresh',
                                                        onPressed: () {
                                                          flutterWebviewPlugin.reload();
                                                        },
                                                      ),
                                                    ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }, 
                              // onPressed: () => Navigator.of(context).pushNamed('/webView'),
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


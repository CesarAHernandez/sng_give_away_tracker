import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Post>> fetchPosts(http.Client client) async{
  final response = await client.get('http://192.168.1.226/posts.json');

  return compute(parsePosts,response.body);
}

List<Post> parsePosts(String responseBody){
  final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();

  return parsed.map<Post>((json) => Post.fromJson(json)).toList();
}

class Post {
  final String postOwner, postLocationLink, postOwnerProfileLink, postLocation,
      title, postLink;

  Post({this.postOwner, this.postLocationLink, this.postOwnerProfileLink,
    this.postLocation, this.title, this.postLink});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        postOwner: json['postowner'] as String,
        postLocationLink: json['postlocationlink'] as String,
        postOwnerProfileLink: json['postownerprofilelink'] as String,
        postLocation: json['postlocation'] as String,
        title: json['title']as String,
        postLink: json['postlink'] as String
    );
  }
}
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
class MyHomePage extends StatelessWidget {
  final String title;
  var client  =  new http.Client();

  MyHomePage({Key key, this.title}) : super (key: key);


  @override
  //_MyHomePageState createState() => _MyHomePageState();
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Post>>(
        future: fetchPosts(client),
        builder: (context, snapshot){
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? PostsList(posts: snapshot.data)
              : Center(child: CircularProgressIndicator ());
        },
      )
    );
  }
}

class PostsList extends StatelessWidget {
  final List<Post> posts;

  PostsList({Key key, this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
      ),
      itemCount: posts.length,
      itemBuilder:(context,index){
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(posts[index].title),
            new Text(posts[index].postOwner),
            new Text(posts[index].postLocation),
          ],
        );
      }
    );
  }
}
/*
class _MyHomePageState extends State<MyHomePage> {
  String _result = "Loading...";
  int _statusCode = 0;

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("SNG Give Away Tracker"),
      ),
      body: new Center(
        child: new ListView(
          children: <Widget>[
            new Text("$_result"),
            new Text("$_statusCode"),
          ],
        )
      ),
    );
  }
}

*/

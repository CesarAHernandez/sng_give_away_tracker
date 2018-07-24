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
      home: new MyHomePage(title: 'SNG GiveAwayTracker HomePage'),
    );
  }
}
class MyHomePage extends StatelessWidget{
  final String title;
  final client  =  new http.Client();

  MyHomePage({Key key, this.title});


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Post>>(
        future: fetchPosts(client),
        builder: (context, snapshot){
          if (snapshot.hasError)
            return new Text('Error: ${snapshot.error}');
          else
            return snapshot.hasData ? PostsList(posts: snapshot.data) : Center(child: CircularProgressIndicator ());
        },
      )
    );
  }
}


class PostsList extends StatelessWidget {
  Future<Null> refreshPosts() async{
    return null;
  }
  final List<Post> posts;

  PostsList({Key key, this.posts}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return RefreshIndicator(
      onRefresh: refreshPosts,
      child: ListView.builder(
            itemCount: posts?.length,
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
                          new Text(posts[index].title,
                            style: TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          new Text(posts[index].postOwner)
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 35.0,
                          ),
                        Text(posts[index].postLocation),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'posts.dart';

class GiveAwayPosts extends StatefulWidget {
  static const routeName = "/giveawayposts";
  final FirebaseApp app;
  GiveAwayPosts({this.app});

  @override
  _GiveAwayPostsState createState() => _GiveAwayPostsState();
}

class _GiveAwayPostsState extends State<GiveAwayPosts> {
    List<Post> _posts = new List<Post>();
    
    @override
    void initState() {
      // TODO: implement initState

      // final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
      // FirebasePosts.getPostStream(_updatePosts).then((StreamSubscription s)=> _subscriptionPost = s);
      // FirebasePosts.getPosts().then(_updatePosts);
      // 
      super.initState();
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Give Away Posts")
        ),
        body: FutureBuilder<List<Post>>(
          // stream : FirebaseDatabase.instance.reference().child("_posts").onValue,
          future: Post.getGiveAwayPosts(),
          builder: (context, snapshot){
            if (snapshot.connectionState == ConnectionState.waiting)
              return Center(child: CircularProgressIndicator(),);
            else if (snapshot.hasData)
              return _giveAwayPosts(snapshot);
            else
              return Center(child: Text("No Info yet"),);
            }
          ),
      );
    }

    Future<Null> refreshGiveAwayPost() async {
      List<Post> posts = await Post.getGiveAwayPosts();

      setState(() {
        _posts = posts;
      });

      return null; 
    }

    Widget _giveAwayPosts(AsyncSnapshot snapshot){
      /*
      Map<dynamic,dynamic> map = snapshot.data.snapshot.value;
        for (var value in map.values.toList()){
          _posts.add(Post.fromSnapshot(value));
        }
        */
      // Post.fromSnapshot(snapshot.data.snapshot.value);
      _posts = snapshot.data;

      return RefreshIndicator(
          onRefresh: refreshGiveAwayPost,
          child: ListView.builder(
              itemCount: _posts?.length,
              itemBuilder:(context,index){
                return Container(
                  color: Color.fromARGB(255, 176, 224, 230),
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
                              onPressed: () async => await canLaunch(_posts[index]?.postLink)
                                  ? await launch(_posts[index]?.postLink)
                                  : throw "Could not launch URL",
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
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'posts.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget{
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyApp>{
  List<Post> _posts;
  final client  =  new http.Client();

@override
  void initState() {
    // TODO: implement initState
    super.initState();
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
              if(snapshot.hasError)
                print("Error: ${snapshot.error}");
              else
                return snapshot.hasData ? displayPosts(snapshot) : Center(child: CircularProgressIndicator());
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
                          Icon(
                            Icons.assignment,
                            size: 35.0,
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


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:flutter_search_bar/flutter_search_bar.dart';
import 'posts.dart';

// TODO: implement different filters(timestamp,post location,)
// TODO: search bar 

class GiveAwayPosts extends StatefulWidget {
  static const routeName = "/giveawayposts";
  final FirebaseApp app;
  GiveAwayPosts({this.app});

  @override
  _GiveAwayPostsState createState() => _GiveAwayPostsState();
}

class _GiveAwayPostsState extends State<GiveAwayPosts> {
    List<Post> _posts = new List<Post>();
    final flutterWebviewPlugin = new FlutterWebviewPlugin();
    final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
    String _filter = 'none';
    String _ordering = 'none';
    String _searchValue = '';
    SearchBar searchBar;
    @override
    void initState() {
      // TODO: implement initState

      // final FirebaseDatabase database = FirebaseDatabase(app: widget.app);
      // FirebasePosts.getPostStream(_updatePosts).then((StreamSubscription s)=> _subscriptionPost = s);
      // FirebasePosts.getPosts().then(_updatePosts);
      // 
      super.initState();
    }
    void submittedValue(String value){
      setState(() {
         _searchValue = value;
        //  _scaffoldKey.currentState.showSnackBar(new SnackBar( content: new Text("You wrote $value")));
      });
    }
    void searchChangedValue(String value){
      setState(() {
        _searchValue = value;
      });
    }
    AppBar buildAppBar(BuildContext context){
      return new AppBar(
          // title: filters(),
          flexibleSpace: new Container(
              margin: const EdgeInsets.fromLTRB(0.0, 20.0, 30.0, 0.0),
              height: 100.0,
              width: 47.0,
              child: Text('$_searchValue',
                style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                ),
            ),
          actions: [
            filters(),
            ordering(),
            /*
            new Container(
              margin: const EdgeInsets.fromLTRB(0.0, 20.0, 30.0, 0.0),
              width: 47.0,
              child: Text('$_searchValue',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                ),
            ),
            */
            searchBar.getSearchAction(context)
            ],
      );
    }
    _GiveAwayPostsState(){
      searchBar = new SearchBar(
        buildDefaultAppBar: buildAppBar,
        hintText: _searchValue,
        clearOnSubmit: false,
        onChanged: searchChangedValue,
        setState: setState,
        onSubmitted: submittedValue,
      );
    }
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        appBar: searchBar.build(context),
        body: FutureBuilder<List<Post>>(
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
    Widget filters(){
        return new Theme(
              child: new DropdownButtonHideUnderline(
                child: new DropdownButton<String>(
                value: _filter,
                items: <DropdownMenuItem<String>>[
                 new DropdownMenuItem(
                    child: new Text('None'),
                    value: 'none',
                  ),
                  new DropdownMenuItem(
                    child: new Text('Off Topic'),
                    value: 'off topic',
                  ),
                  new DropdownMenuItem(
                    child: new Text('Approved'),
                    value: 'approved',
                  ),
                  new DropdownMenuItem(
                    child: new Text('Declined'),
                    value: 'declined',
                  ),
                ], 
            onChanged: (String value) {
              setState(() => _filter = value);
            },
          ),
        ), 
      data: new ThemeData.dark(),
    );
  }

    Widget ordering(){
        return new Theme(
              child: new DropdownButtonHideUnderline(
                child: new DropdownButton<String>(
                value: _ordering,
                items: <DropdownMenuItem<String>>[
                 new DropdownMenuItem(
                    child: new Text('None'),
                    value: 'none',
                  ),
                  new DropdownMenuItem(
                    child: new Text('Newest First'),
                    value: 'newtoold',
                  ),
                  new DropdownMenuItem(
                    child: new Text('Oldest First'),
                    value: 'oldtonew',
                  ),
                ], 
            onChanged: (String value) {
              setState(() => _ordering = value);
            },
          ),
        ), 
        data: ThemeData.dark(),
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
      _posts = snapshot.data;
      // _posts = Post.organizePosts(_posts, 'timestamp');
      if(_searchValue != ''){
        _posts = Post.searchFilter(_posts, _searchValue);
      }
      if(_filter != 'none'){
        _posts = Post.categoryFilter(_posts, _filter);
      }
      if(_ordering != 'none'){
        _posts = Post.organizePosts(_posts, _ordering);
      }

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
                              icon: Icon(
                                      Icons.assignment,
                                      size: 35.0,
                                    ),
                            ),
                            Text(_posts[index]?.postLocation),
                            _posts[index]?.timeStamp != null ? Text(_posts[index]?.timeStamp) : Text("Something went wrong"),
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
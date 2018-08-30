/*
import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
Future<List<Post>> fetchPosts(http.Client client) async{

  final response = await client.get('http://192.168.1.226/posts.json');

  return compute(parsePosts,response.body);
}

List<Post> parsePosts(String responseBody){
  final parsed = json.decode(responseBody).cast<Map<String,dynamic>>();

  return parsed.map<Post>((json) => Post.fromJson(json)).toList();
}
*/

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class Post {
  final String postOwner, postLocationLink, postOwnerProfileLink, postLocation,
      title, postLink,timeStamp;

  Post({this.postOwner, this.postLocationLink, this.postOwnerProfileLink,
    this.postLocation, this.title, this.postLink, this.timeStamp});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
        postOwner: json['postowner'] as String,
        postLocationLink: json['postlocationlink'] as String,
        postOwnerProfileLink: json['postownerprofilelink'] as String,
        postLocation: json['postlocation'] as String,
        title: json['title']as String,
        postLink: json['postlink'] as String,
        timeStamp: json['timestamp'] as String
    );
    }
  factory Post.fromSnapshot(Map<dynamic,dynamic> post){
    return Post(
        postOwner: post['postowner'] as String,
        postLocationLink: post['postlocationlink'] as String,
        postOwnerProfileLink: post['postownerprofilelink'] as String, 
        postLocation: post['postlocation'] as String,
        title: post['title']as String,
        postLink: post['postlink'] as String,
        timeStamp: post['timestamp'] as String
    );
  }
  static Future<List<Post>> getGiveAwayPosts() async{
    List<Post> posts = new List<Post>();
    Completer<List<Post>> completer = new Completer<List<Post>>();
    FirebaseDatabase.instance
        .reference()
        .child("_posts")
        .once()
        .then((DataSnapshot snapshot){
          for ( var value in snapshot.value.values){
            posts.add(Post.fromSnapshot(value));
          }
         completer.complete(posts);
        });
    return completer.future;
  }
  
  static Future<List<Post>> getFrontPagePosts() async{
    List<Post> posts = new List<Post>();
    Completer<List<Post>> completer = new Completer<List<Post>>();
    FirebaseDatabase.instance
        .reference()
        .child("frontPagePosts")
        .once()
        .then((DataSnapshot snapshot){
          for (var value in snapshot.value.values)
            posts.add(Post.fromSnapshot(value));
          completer.complete(posts);
        });
      return completer.future;
  }

  toJson(){
    return{
      'title':title,
      'postowner':postOwner,
      'postlocationlink':postLocationLink,
      'postownerprofilelink':postOwnerProfileLink,
      'postlocation':postLocation,
      'postlink':postLink,
      'timestamp':timeStamp
    };
  }
  static List<Post> organizePosts(List<Post> posts, String filter){
    // TODO: Having different filters like ('abc',timestamp)
    switch (filter){
      case 'alphabeticalAsc':
        try{
          posts.sort((a, b){
            return a.title.toLowerCase().compareTo(b.title.toLowerCase()); 
          });
          return posts;

        } catch (e){
          print("There was a problem organizing the data ${e.toString()}");
          return [];
        }
        break;

      case 'timestamp':
        try{
          print("using timestapm filter");
          posts.sort((a, b){
            return a.timeStamp.toLowerCase().compareTo(b.timeStamp.toLowerCase()); 
          });
          return Post.reverse(posts);
        }catch(e){
          print("There was a problem organizing the data ${e.toString()}");
          return[];
        }
        break;

      default:
        print("Filter not found");
        return posts;
        break;

    }
  }
  static List<Post> filterLocation(List<Post> list,String filter){
    List<Post> filteredList = new List<Post>();
     if(filter.length == 0){
       return list;
     }else{
       filteredList = list.where((i) => i.postLocation.toLowerCase() == '${filter}').toList();
       if (filteredList.length == 0 ){
         // Make a toast that tells the user that the filter has no results
         return list;
       }else{
         return filteredList;
       }
     }
  }
  static List<Post> reverse(List<Post> list){
    List<Post> newList = new List<Post>();
    int listLength = list.length-1;
    for(int i=0; i<listLength;i++){
      newList.add(list[listLength - i]);
    }
    return newList;
  }
}

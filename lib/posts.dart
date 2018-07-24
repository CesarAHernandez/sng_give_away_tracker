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

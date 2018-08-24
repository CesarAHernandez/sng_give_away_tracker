import 'package:flutter/material.dart';
import 'giveawaypostpage.dart';

class CreateDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
           child: Text("OPTIONS"), 
           decoration: BoxDecoration(
             color: Colors.blue,
            ),
          ),
          ListTile(
            title: Text("Give Away Posts"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context,GiveAwayPosts.routeName);
            },
          )
        ],
      ),
    );
  }
}
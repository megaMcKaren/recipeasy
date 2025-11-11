import 'package:flutter/material.dart';
import 'post.dart';

class PostWrapper extends StatefulWidget {
  const PostWrapper(
      {super.key,
        required this.postID,
        required this.title, //require the title property to be provided
        required this.imageUrl,
        required this.description,
        required this.userID,
      });
  final String title;
  final String imageUrl;
  final String description;
  final String postID;
  final String userID;

  @override
  State<PostWrapper> createState() => _PostWrapperState();
}

class _PostWrapperState extends State<PostWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // endDrawer: Drawer(
      //   child: ListView(
      //     children: [
      //       ListTile(title: Text("List List"))
      //     ],
      //   )
      // ),
      backgroundColor: Color(0xfff6dad8),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, 'refresh');
          },
        ),
      ),
      body: ListView(children: [Post(postID: widget.postID, title: widget.title, imageUrl: widget.imageUrl, description: widget.description,userID: widget.userID, showComments: true, onBack: () {print("HAppy birthday");})]),
    );
  }
}

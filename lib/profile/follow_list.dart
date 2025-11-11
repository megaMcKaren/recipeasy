import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/firestore_utils.dart';

import 'profile.dart';

class FollowList extends StatefulWidget {
  const FollowList({super.key, required this.type, required this.data});
  final data;
  final String type;

  @override
  State<FollowList> createState() => _FollowListState();
}

class _FollowListState extends State<FollowList> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: widget.data[widget.type].length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(children: [
              Container(color: Color(0xFFFFAAAA), width: MediaQuery.of(context).size.width/2, height: 7),
              Container(height: 50, color: Colors.red, child: Center(child: Text("${widget.type[0].toUpperCase()}${widget.type.substring(1).toLowerCase()}"))),
              Container(color: Color(0xFFFFAAAA), width: MediaQuery.of(context).size.width/2, height: 7),
            ]);
          }
          final itemData = widget.data[widget.type][index-1];
          return FutureBuilder(
              future: FirestoreUtils.fetchUserData(itemData),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Failed to load."));
                }

                if (!snapshot.hasData) {
                  return Center(child: Text("error 404"));
                }

                var followingData = snapshot.data;
                if (followingData == null) {
                  return Center(child: Text("No _ found."));
                }
                return Column(
                  children: [
                    SizedBox(height:5),
                    GestureDetector(onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                  userID:
                                  itemData)));
                    },
                      child: Row(children: [
                        SizedBox(width: 5),
                        CircleAvatar(radius: 13,backgroundImage:NetworkImage(followingData["pfp"])),
                        SizedBox(width: 5),
                        Text(followingData["username"], style: GoogleFonts.robotoCondensed(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ],
                );
              }
          );
        },

        //   children: [
        // Container(color: Color(0xFFFFAAAA), width: MediaQuery.of(context).size.width/2 - 7, height: 7),
        // Container(height: 50, color: Colors.red, child: Center(child: Text("Following"))),
        // Container(color: Color(0xFFFFAAAA), width: MediaQuery.of(context).size.width/2 - 7, height: 7),
        // ]
      ),
    );
  }
}

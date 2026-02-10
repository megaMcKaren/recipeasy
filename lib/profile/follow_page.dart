import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../firestore_utils.dart';
import 'follow_list.dart';

class FollowPage extends StatefulWidget {
  const FollowPage({super.key, required this.userId, this.username = "Anonymous"});
  final String userId;
  final String username;

  @override
  State<FollowPage> createState() => _FollowPageState();
}

class _FollowPageState extends State<FollowPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          flexibleSpace: Container(color: Color(0xFFEEDDDD)),
          iconTheme: IconThemeData(color: Color(0xFF440000)),
          title: Text("${widget.username}'s Follow Page", style: GoogleFonts.robotoCondensed(fontWeight: FontWeight.w600))
      ),
      body: FutureBuilder(
          future: FirestoreUtils.fetchUserData(widget.userId),
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

            var data = snapshot.data;
            // print(data);
            if (data == null) {
              return Center(child: Text("No _ found."));
            }
            return DefaultTextStyle(
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w700, fontSize: 30, color: Color(0xFFFFDDDD), decoration: TextDecoration.none),
                child: Container(
                  color: Color(0xFFEEDDDD),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FollowList(type:"followers",data:data), // Left Side
                      Column(
                        children: [
                          Container(color: Color(0xFFFF6666), width: 7, height: MediaQuery.of(context).size.height - 118), // Mid Line
                        ],
                      ),
                      FollowList(type:"following",data:data), // Right Side
                    ],
                  ),
                ),
            );
          }
      ),
    );
  }
}

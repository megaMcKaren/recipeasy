import 'package:flutter/material.dart';
import '../profile/profile.dart';
import '../firestore_utils.dart';

class ProfilePicWidget extends StatelessWidget {
  final double picSize;
  final double textSize;
  final bool isCol; //
  final String userID;
  const ProfilePicWidget({super.key, required this.picSize, required this.textSize, required this.isCol, required this.userID});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirestoreUtils.fetchUserData(userID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }



        final data = snapshot.data;
        if (data == null) {
          return Center(child: Text("No data found."));
        }
        return Container(//userdata[]  I lost my zoom thing
          child: (isCol) ?Column(
            children: [
              GestureDetector(onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(userID: userID)));
              },child: CircleAvatar(radius: picSize, backgroundImage: NetworkImage(data["pfp"]))),
              SizedBox(height: 6),
              Text(data["username"], style: TextStyle(fontSize: textSize))
              // Use userData["pfp"/"username"] and comment["comment"]
            ],
          ): Row(
            children: [
              GestureDetector(onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ProfilePage(userID: userID)));
              },child: CircleAvatar(radius: 15, backgroundImage: NetworkImage(data["pfp"]))),
              SizedBox(width: 10),
              Text(data["username"])
              // Use userData["pfp"/"username"] and comment["comment"]
            ],
          ),
        );
      }
    );
  }
}

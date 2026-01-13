import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/firestore_utils.dart';
import 'package:social_media_app/home.dart';
import 'components/custom_button.dart';
import 'create.dart';
import 'postWrapper.dart';
import 'profile/profile.dart';
import 'components/profile_pic.dart';

final db = FirebaseFirestore.instance;

class CommentWidget extends StatelessWidget {
  final Map<String,dynamic> comment;



  const CommentWidget({super.key, required this.comment});

  Future<dynamic> loadUserData(String userId) async {
    try {
      final data = await db
          .collection('profiles') // replace with collection name
          .doc(userId).get();
      return data;
    } catch (e) {
      print("Fetching posts failed: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: loadUserData(comment["userID"]),
      builder: (context, snapshot) {
        // if statement tree checking if loading or done
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final userData = snapshot.data;
        if (userData == null) {
          return Center(child: Text("No data found."));
        }
        return Container(//userdata[]
          child: Row(
              children: [
                SizedBox(width: 7),
                GestureDetector(onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfilePage(userID: comment["userID"])));
                },child: CircleAvatar(radius: 20, backgroundImage: NetworkImage(userData["pfp"]))),
                SizedBox(width: 10),
                Text(userData["username"], style: GoogleFonts.roboto(fontSize: 20, fontWeight: FontWeight.w600)),
                Expanded(child: Align(alignment: AlignmentGeometry.topRight, child: IconButton(onPressed: () {
                  showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: "Dismiss",
                      pageBuilder: (context, anim1, anim2) {
                        return Align(
                          alignment: Alignment.center,
                          child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(50),
                                  color: Color(0xFFBB5555)),
                              width: 375,
                              height: 270,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                                  CustomButton(onPressed: () {print("EDITING");}, width: 300, height: 60, text: "Edit Comment", icon: Icons.edit),
                                CustomButton(onPressed: () {print("DELETED");}, width: 300, height: 60, text: "Delete Comment", icon: Icons.delete_forever),

                                ],
                              ),
                        ));
                      },
                  );
                }, icon: Icon(Icons.arrow_drop_down)))),
                SizedBox(width: 10),
                // Use userData["pfp"/"username"] and comment["comment"]
              ],
          ),
        );
      },
    );
  }
}

class Post extends StatefulWidget {
  Post(
      {super.key,
        required this.postID,
        required this.title, //require the title property to be provided
        required this.imageUrl,
        required this.subtitle,
        required this.userID,
        required this.showComments,
        required this.onBack,
      });
  String title;
  final String imageUrl;
  String subtitle;
  final String postID ;
  final String userID ;
  final bool showComments;
  dynamic onBack;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  late final docRef = db.collection("posts").doc(widget.postID);
  late final usersRef = db.collection("users");//.doc("")
  String commentErrorMsg = '';
  bool editing = false;
  Future<List<dynamic>> getComments() async {
    final commentData = await docRef.get();
    final data = commentData.data() as Map<String, dynamic>;
    return data["comments"];
  }

  Future<dynamic> getData() async {
    final Data = await docRef.get();
    final data = Data.data() as Map<String, dynamic>;
    return data;
  }



  // Future<List<dynamic>> getUsers() async {
  //   return usersRef.doc().get();
  // }
  void updateCommentData(String newComment) async {

    if (newComment != '') {
      if (newComment.length < 200) {
        final List<dynamic> comments = await getComments();
        comments.add({"comment": newComment, "userID": FirebaseAuth.instance.currentUser?.uid}); //comments is a list with dictionaries inside
        await docRef.update({
          "comments": comments,
        });
        // return true;
      } else {
        commentErrorMsg = 'Comment input over 200 letter limit';
        // return "overLimit";
      }
    } else {
      commentErrorMsg = 'Comment input empty';
      // return "empty";
    }
    Timer(Duration(seconds: 1), () {
      setState(() {
        commentErrorMsg = '';
      });

    });
    setState((){});
  }

  void updateLikesData() async {

    // final List<dynamic> docData = await getComments();
    await docRef.update({
      "likes": FieldValue.increment(1),
    });
    setState((){});
  }

  void updateDislikesData() async {

    // final List<dynamic> docData = await getComments();
    await docRef.update({
      "dislikes": FieldValue.increment(1),
    });
    setState((){});
  }

  final TextEditingController commentController = TextEditingController();


  @override


  Widget build(BuildContext context) {
          final TextEditingController postTitleCtr = TextEditingController(text: widget.title);
          final TextEditingController descCtr = TextEditingController(text: widget.subtitle);
          Future postFuture = FirestoreUtils.fetchPostData(widget.postID);
          return Material(
              // drawer: Drawer(child: ListView(children: [
              //   ListTile(title: Text("Haaa")),
              // ])),
              child: Container(
                decoration: BoxDecoration(color: Color(0xFFF6DAD8), border: Border(top: BorderSide(color: (!widget.showComments)?Colors.black:Colors.transparent, width: 2.1))),
                // color: Color(0xfff6dad8),
                child: FutureBuilder(
                  future: postFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot
                          .error}'));
                    }


                    final data = snapshot.data; // Get Snapshot

                    if (data == null || data.isEmpty) {
                      return Center(child: Text("No data found."));
                    }
                    return Column(
                        children: [
                          Stack(
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    SizedBox(height: 15),
                                    (!editing) ? GestureDetector(
                                      onTap: () async {
                                        if (!widget.showComments) {
                                          var result = await Navigator.push(
                                              context, MaterialPageRoute(
                                              builder: (_) =>
                                                  PostWrapper(
                                                    postID: widget.postID,
                                                    title: widget.title,
                                                    imageUrl: widget.imageUrl,
                                                    subtitle: widget
                                                        .subtitle,
                                                    userID: widget.userID,)));
                                          if (result == 'refresh') {
                                            widget.onBack();
                                          }
                                        }
                                      },
                                      child: Text(
                                          style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 25),
                                          widget.title),
                                    ) : SizedBox(
                                      width: 350,
                                      child: TextField(
                                        controller: postTitleCtr,
                                        textAlign: TextAlign.center,
                                        decoration: const InputDecoration(
                                          hintText: "Enter new title",
                                        ),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 25),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.userID ==
                                  FirebaseAuth.instance.currentUser?.uid &&
                                  widget.showComments) Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      // print("You pressed 3 dots in post.");
                                      showGeneralDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          barrierLabel: "Dismiss",
                                          pageBuilder: (context, anim1, anim2) {
                                            return Align(
                                                alignment: AlignmentGeometry
                                                    .center,
                                                child: Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(50),
                                                        color: Color(
                                                            0xFFBB5555)),
                                                    width: 375,
                                                    height: 270,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .spaceEvenly,
                                                      children: [
                                                        CustomButton(
                                                          onPressed: () async {
                                                            bool result = await Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePage(postID: widget.postID, postData: data,)));
                                                            if (result) {
                                                              setState(() {

                                                              });
                                                            }
                                                            },
                                                          width: 300,
                                                          height: 60,
                                                          text: Text("Edit Post",
                                                              style: GoogleFonts
                                                                  .robotoFlex(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 30,
                                                                  decoration: TextDecoration
                                                                      .none)),
                                                          icon: Icon(Icons.edit,
                                                              size: 50),

                                                        ),

                                                        CustomButton(
                                                          onPressed: () {
                                                            print(
                                                                "Delete this post?");
                                                            FirestoreUtils
                                                                .deletePost(
                                                                widget.postID);
                                                            Navigator
                                                                .pushAndRemoveUntil(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      _) => const HomeScreen()),
                                                                  (
                                                                  route) => false,
                                                            );
                                                          },
                                                          width: 300,
                                                          height: 60,
                                                          text: Text(
                                                              "Delete Post",
                                                              style: GoogleFonts
                                                                  .robotoFlex(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 30,
                                                                  decoration: TextDecoration
                                                                      .none)),
                                                          icon: Icon(
                                                              Icons.delete,
                                                              size: 50),
                                                        ),
                                                      ],
                                                    )));
                                          }
                                      );
                                    },
                                    icon: Icon(Icons.more_vert),
                                    iconSize: 30,
                                  ),
                                ],
                              ) else
                                SizedBox(),
                            ],
                          ),
                          // Stack for Post Title & Edit Btn.

                          SizedBox(height: 5),

                          (!editing) ? Padding(
                              padding: EdgeInsets.only(left: 20, right: 20),
                              child: Text(widget.subtitle, textAlign: TextAlign.center,)) : SizedBox(
                            width: 350,
                            child: TextField(
                              controller: descCtr,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: "Enter new subtitle",
                              ),
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 15),
                            ),
                          ),

                          SizedBox(height: 13),

                          ProfilePicWidget(picSize: 15,
                              textSize: 15,
                              isCol: true,
                              userID: widget.userID),
                          // Profile Picture of Post Creator

                          GestureDetector(onTap: () async {
                            if (!widget.showComments) {
                              var result = await Navigator.push(
                                  context, MaterialPageRoute(builder: (_) =>
                                  PostWrapper(postID: widget.postID,
                                    title: widget.title,
                                    imageUrl: widget.imageUrl,
                                    subtitle: widget.subtitle,
                                    userID: widget.userID,)));
                              if (result == 'refresh') {
                                print("did it work");
                                widget.onBack();
                              }
                            }
                          },
                              child: (widget.imageUrl.isNotEmpty)
                                  ? Padding(padding: EdgeInsets.all(25),
                                  child: Container(decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(25)),
                                      child: Image.network(widget.imageUrl)))
                                  : SizedBox(height: 15)),
                          // If viewing from outside the post...


                          (widget.showComments) ? ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: data["widgets"].length,
                            itemBuilder: (context, index) {
                              if (data["widgets"][index]["type"] == "ingredientsList") {
                                return Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Container(
                                    decoration: BoxDecoration(color: Color(0xFFFFFAFA), borderRadius: BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount: data["widgets"][index]["list"].length,
                                        itemBuilder: (context, index2) {
                                          return Align(alignment: Alignment.topLeft, child: Text("• ${data["widgets"][index]["list"][index2]}"));
                                        }
                                      ),
                                    ),
                                  ),
                                );
                              } else if (data["widgets"][index]["type"] == "imagePicker") {
                                return Padding(
                                  padding: EdgeInsets.all(20),
                                  child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(fit: BoxFit.cover, width: double.infinity, data["widgets"][index]["imageUrl"])),
                                );
                              } else if (data["widgets"][index]["type"] == "instructions") {
                                return Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Container(
                                    decoration: BoxDecoration(color: Color(0xFFFFFAFA), borderRadius: BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: ListView.builder(
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: data["widgets"][index]["list"].length,
                                          itemBuilder: (context, index2) {
                                            return Align(alignment: Alignment.topLeft, child: Text("${index + 1}. ${data["widgets"][index]["list"][index2]}"));
                                          }
                                      ),
                                    ),
                                  ),
                                );
                              } else if (data["widgets"][index]["type"] == "description") {
                                return Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Container(
                                    decoration: BoxDecoration(color: Color(0xFFFFFAFA), borderRadius: BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Text("ABC"),
                                    ),
                                  ),
                                );
                              }
                              return Align(alignment: Alignment.center, child: Text("Test"));
                            }
                          ): SizedBox(),


                          Container(
                            color: Color(0xFFFFFAFA),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(style: GoogleFonts.robotoMono(fontSize: 20,fontWeight: FontWeight.w600),data["likes"].toString()),
                                // Icon(Icons.thumb_up, color: Colors.black, size: 25),
                                IconButton(
                                  onPressed: () {
                                    updateLikesData();
                                  },
                                  icon: const Icon(Icons.thumb_up),
                                  color: Colors.black,
                                  iconSize: 24,
                                ),


                                SizedBox(width: 30),
                                Text(style: GoogleFonts.robotoMono(fontSize: 20,fontWeight: FontWeight.w600),data["dislikes"].toString()),
                                IconButton(
                                  onPressed: () {
                                    updateDislikesData();
                                  },
                                  icon: const Icon(Icons.thumb_down),
                                  color: Colors.black,
                                  iconSize: 24,
                                ),
                              ],
                            ),
                          ),
                          // Likes Section

                          SizedBox(height: 15),

                          (widget.showComments)
                              ? Column( // i changed it from lsitview
                            children: [
                              Row(mainAxisAlignment: MainAxisAlignment.center,
                                  children: [

                                    SizedBox(
                                      width: 250,
                                      child: TextField(
                                        decoration: const InputDecoration(
                                          hintText: "Enter a comment",
                                        ),
                                        controller: commentController,

                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    CustomButton(
                                      onPressed: () {
                                        updateCommentData(
                                            commentController.text);
                                      },
                                      width: 100,
                                      height: 35,
                                      text: '',
                                      icon: null,
                                      customChild: Center(child: Text("Comment",
                                          style: GoogleFonts.robotoMono())),
                                    ),
                                  ]),
                              // ListView(
                              //
                              // )

                              (commentErrorMsg.isEmpty)
                                  ? SizedBox(height: 40)
                                  : Column(
                                children: [
                                  SizedBox(height: 20),
                                  Text(commentErrorMsg),

                                ],
                              ),

                              FutureBuilder<dynamic>(
                                  future: getComments(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Center(child: Text(
                                          'Error: ${snapshot.error}'));
                                    }


                                    final comments = snapshot.data;
                                    if (comments == null ||
                                        comments.length == 0) {
                                      return Center(child: Text(
                                          "Be the first one to say something!",
                                          style: GoogleFonts.mcLaren()));
                                    }

                                    return SizedBox(height: comments.length *
                                        100.0, child: ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: comments.length,
                                      itemBuilder: (context, index) {
                                        final doc = comments[index];

                                        print(doc);

                                        return SizedBox(
                                          child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start, children: [
                                            CommentWidget(comment: doc),
                                            SizedBox(height: 7),
                                            Row(

                                                children: [
                                                  SizedBox(width: 12),
                                                  Text(doc["comment"],
                                                      style: GoogleFonts.roboto(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight
                                                              .w500),
                                                      textAlign: TextAlign
                                                          .left),

                                                ]
                                            )
                                          ]),
                                        );
                                      },
                                    ));
                                  }), // To get COMMENTS
                            ],
                          )
                              : SizedBox(),
                          // Comments Section
                        ]);
                    }
                  )
                ),
              );

  }
}

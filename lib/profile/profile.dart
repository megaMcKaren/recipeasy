import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/profile/follow_page.dart';
import '../post.dart';
import '../../firestore_utils.dart';

final db = FirebaseFirestore.instance;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.userID = "test"});

  final String userID;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // late final _userID = widget.userID;
  late final docRef = db.collection("profiles").doc(widget.userID);
  late final postRef = db.collection("posts");
  late final bool signedInUserProfile =
      FirebaseAuth.instance.currentUser!.uid == widget.userID;

  bool editing = false;
  bool editingPfp = false;

  Future<DocumentSnapshot> getUserData() {
    // print(FirebaseAuth.instance.currentUser!.uid + " am i string");
    // print(docRef);
    // print(docRef.get());
    // print("lag test");
    return docRef.get();
  }

  Future<dynamic> getUserPosts() async {
    print(await postRef.where("userID", isEqualTo: widget.userID).get());
    return await postRef.where("userID", isEqualTo: widget.userID).get();
  }

  String buttonText = "Follow";
  Future<void> updateButtonText() async{
    final newText = (await FirestoreUtils.isFollowing(FirebaseAuth.instance.currentUser!.uid, widget.userID)) ? "Unfollow" : "Follow";
    setState(() {
      buttonText = newText;
    });
  }
  void doButtonStuff () async{
    await FirestoreUtils.followUser(widget.userID, FirebaseAuth.instance.currentUser!.uid);
    await updateButtonText();

  }
  @override
  void initState() {
    super.initState();
    updateButtonText();
  }

  @override
  Widget build(BuildContext context) {
    // codeable here

    return FutureBuilder<Map<String, dynamic>?>(
        future: FirestoreUtils.fetchUserData(widget.userID),
        builder: (context, snapshot) {
          //codeable
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Failed to load."));
          }

          if (!snapshot.hasData) {
            return Center(child: Text("${widget.userID} error 404"));
          }

          var data = snapshot.data; //???

          if (data == null) {
            return Center(child: Text("${widget.userID} error 404"));
          }

          var usernameCtr = TextEditingController(text: data["username"]);

          var bioCtr = TextEditingController(text: data['bio']);

          var pfpUrlCtr = TextEditingController(text: data["pfp"]);

          bioCtr.addListener(() async {
            await db.collection("profiles").doc(widget.userID).update({
              'bio': bioCtr.text,
            });
          });

          @override
          void dispose() {
            usernameCtr.dispose();
            bioCtr.dispose();
            super.dispose();
          }

          return Scaffold(
            backgroundColor: Color(0xffdfe8ff),
            appBar: AppBar(
                flexibleSpace: Stack(children: [
                  // Image.network(data["bgImg"]),
                  Center(child: Image.network(data["bgImg"])),
                  Center(child: Container(color: Color(0x55000000), width: 1000, height: 1000)),

                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    (editing)
                        ? Text("editing mode",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ))
                        : SizedBox(),
                    SizedBox(width: 5)
                  ]),
                  Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          (!editingPfp) ? GestureDetector(
                            onTap: () {
                              editingPfp = !editingPfp;
                              setState(() {

                              });
                              print("$editingPfp <-- bool editingPfp in profile.dart");
                            },
                            child:  CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(data["pfp"]),
                                onBackgroundImageError: (exception, stackTrace) {
                                  print('Image load failed: $exception');
                                }))
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 94),
                              SizedBox(
                                  width: 240,
                                  child: TextField(
                                    controller: pfpUrlCtr,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                        iconColor: Colors.red, hintText: "Enter image URL"),
                                  ),
                                ),
                              IconButton(
                                onPressed: () async {
                                  setState(() {
                                    editingPfp = !editingPfp;
                                  });
                                  if (!editingPfp) {
                                    await db
                                        .collection("profiles")
                                        .doc(widget.userID)
                                        .update({
                                      'pfp': pfpUrlCtr.text,
                                    });
                                  }
                                },
                                icon: const Icon(Icons.check),
                                color: Colors.white,
                                iconSize: 22,
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    editingPfp = !editingPfp;
                                  });

                                },
                                icon: const Icon(Icons.delete),
                                color: Colors.white,
                                iconSize: 22,
                              ),
                            ],
                          ),

                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(width: 41),
                                (!editing)
                                    ? Text(data["username"],
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ))
                                    : IntrinsicWidth(
                                    child: TextField(
                                      controller: usernameCtr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      decoration: InputDecoration(
                                        enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide
                                                .none // White when not focused
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.white,
                                              width: 2), // White when focused
                                        ),
                                      ),
                                    )),
                                (signedInUserProfile)
                                    ? Padding(
                                  //home: (signedIn) ? HomeScreen() : SignUp(),
                                  padding: const EdgeInsets.only(top: 4),
                                  child: IconButton(
                                    onPressed: () async {
                                      print("changing mode");
                                      setState(() {
                                        editing = !editing;
                                      });
                                      if (!editing) {
                                        await db
                                            .collection("profiles")
                                            .doc(widget.userID)
                                            .update({
                                          'username': usernameCtr.text,
                                        });
                                      }
                                    },
                                    icon: (!editing)
                                        ? const Icon(Icons.edit)
                                        : const Icon(Icons.check),
                                    color: Colors.white,
                                    iconSize: 22,
                                  ),
                                )
                                    : SizedBox(width: 41)
                              ])
                        ]),
                  ),
                ]),
                centerTitle: true,
                toolbarHeight: 180,
                automaticallyImplyLeading: false,
                leading: Padding(
                  padding: EdgeInsets.only(bottom: 140),
                  child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigator.push(
                        // context,
                        // MaterialPageRoute(
                        //     builder: (context) => const HomeScreen()));
                      },
                      icon: const Icon(Icons.arrow_back)),
                )),
            body: Column(children: [
              SizedBox(height: 25),
              FutureBuilder(
                future: FirestoreUtils.fetchUserData(FirebaseAuth.instance.currentUser!.uid),
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

                  // var data = snapshot.data!.data() as Map<String, dynamic>; //???\
                  var myData = snapshot.data;
                  return Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    SizedBox(),
                    GestureDetector(onTap: () {
                      Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => FollowPage(userId: widget.userID, username: data["username"])));
                    }, child: Text("${data['followers'].length} Followers")),
                    GestureDetector(onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => FollowPage(userId: widget.userID)));
                    },child: Text("${data['following'].length} Following")),
                    (!signedInUserProfile) ? ElevatedButton(onPressed: () => doButtonStuff(), child: Text(buttonText)) : SizedBox(),
                    // GestureDetector(onTap: () async {
                    //   print("tap");
                    //   if (!signedInUserProfile) {
                    //     await db.collection("profiles").doc(widget.userID).update({
                    //       'followers': data['followers'] + 1,
                    //     });
                    //     await db.collection("profiles").doc(FirebaseAuth.instance.currentUser!.uid).update({
                    //       'following': my_data!['following'] + 1,
                    //     });
                    //     setState((){});
                    //   }
                    //
                    // }, child: Text("${data['followers']} Followers",
                    //     style:
                    //     TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Roboto')),),
                    // // Text("${data['followers']} Followers",
                    // //     style:
                    // //     TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    // GestureDetector(onTap: () {
                    //   print("tap");
                    // }, child: Text("${data['following']} Following",
                    //     style:
                    //     TextStyle(fontSize: 15, fontWeight: FontWeight.w600, fontFamily: 'Roboto')),),
                    // // Text("${data['following']} Following",
                    // //     style:
                    // //     TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    // // Text("${data['friends']} Friends",
                    // //     style:
                    // //     TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ]);
                }
              ),
              SizedBox(height: 15),
              Container(
                  width: 300,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.black,
                  )),
              SizedBox(height: 15),
              Text("This is my bio:"), //  ${data['bio']}
              (signedInUserProfile)
                  ? TextField(
                  textAlign: TextAlign.center,
                  // maxLines: null,
                  // keyboardType: TextInputType.multiline,
                  controller: bioCtr)
                  : Text(data["bio"],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18)),
              // ElevatedButton(
              //     onPressed: () {
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //               builder: (context) => const HomeScreen()));
              //     },
              //     child: Text("Home"))
              // Text("here goes profiles"),//what?!!!!!!!!!
              FutureBuilder(future: getUserPosts(), builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text("Failed to load."));
                }

                if (!snapshot.hasData) {
                  return Center(child: Text("error 404"));
                }

                var querySnapshot = snapshot.data;
                print(querySnapshot);
                if (querySnapshot == null || querySnapshot.docs.isEmpty) {
                  return Center(child: Text("No posts found."));
                }
                return Expanded(
                  child:
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      itemCount: querySnapshot.docs.length,
                      itemBuilder: (context, index) {
                        final post = querySnapshot.docs[index];
                        final postData = post.data() as Map<String, dynamic>;
                        return GestureDetector(onTap: () {
                          print(postData);
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) =>
                                Scaffold(
                                  backgroundColor: Color(0xfff6dad8),
                                  appBar: AppBar(),
                                  body:
                                ListView(
                                  children: [
                                    Post(postID: post.id,title: postData['title'],imageUrl: postData['url'],description: postData['description'],userID: postData['userID'],showComments: true, onBack: () {},),
                                  ],
                                ),
                                )
                          ));
                          },child: Image.network(postData["url"],fit: BoxFit.fitHeight));
                      },

                    ),
                );


              })
            ]),
          );
        });
  }
}

// Row(children: [
//             Column(children: [
//               Text("500 Followers.\n500 Following\n100 Friends"),
//               Text("Insert bio here...")
//             ]),
//             ElevatedButton(
//                 child: Text("Refresh"), onPressed: () => getUserData()),
//           ]),

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'profile/profile.dart';
import 'post.dart';
import 'sign_in.dart';
import 'create.dart';
import 'search/search.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>  with RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // the remote":)"

  // late Future<dynamic> postsFuture;

  Future<dynamic> loadAllPosts() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance.collection('posts').get();

      List<Map<String, dynamic>> posts = [];

      for (var doc in data.docs) {
        final a = doc.data();
        a['id'] = doc.id;
        posts.add(a);
      }

      posts.sort((a,b){
        return b['dateCreated'].toDate().compareTo(a['dateCreated'].toDate());
      });



      // final doc = querySnapshot.docs[index];
      //
      // final data = doc.data() as Map<String, dynamic>;

      return posts;
    } catch (e) {
      print("Fetching all posts failed: $e");
      return null;
    }
  }

  void reload() {
    setState(() {
      // postsFuture = loadAllPosts();
    });
  }

  @override
  void initState() {
    super.initState();
    // print("INITIALIZED AGAIN FOR HOME.DART");
    // postsFuture = loadAllPosts();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        leading: Builder(builder: (context) {
          return Row(children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ]);
        }),
      ),
        key: _scaffoldKey,
        drawer: Drawer(
            width: 150,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const SizedBox(
                    height: 10,
                  ),
                  title: const Text(""),
                ),
                ListTile(
                  leading: const SizedBox(
                    width: 35,
                    child: Icon(Icons.person_pin),
                  ),
                  title: const Text("Profile"),
                  onTap: () {
                    if (FirebaseAuth.instance.currentUser != null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePage(
                                  userID:
                                  FirebaseAuth.instance.currentUser!.uid)));
                    } else {}
                  },
                ),
                ListTile(
                  leading: const SizedBox(
                    width: 35,
                    child: Icon(Icons.door_front_door),
                  ),
                  title: const Text("Logout"),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SignIn()));
                  },
                ),
                ListTile(
                  leading: const SizedBox(
                    width: 35,
                    child: Icon(Icons.build_circle),
                  ),
                  title: const Text("Testing"),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfilePage(userID: "test")));
                  },
                ),
                ListTile(
                  leading: const SizedBox(
                    width: 35,
                    child: Icon(Icons.add_circle),
                  ),
                  title: const Text("Create"),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreatePage()));
                    _scaffoldKey.currentState?.closeDrawer();
                  },
                ),
                ListTile(
                  leading: const SizedBox(
                    width: 35,
                    child: Icon(Icons.search),
                  ),
                  title: const Text("Search"),
                  onTap: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SearchPage()));
                    _scaffoldKey.currentState?.closeDrawer();
                  },
                ),
                // ListTile(
                //   leading: const SizedBox(
                //     width: 35,
                //     child: Icon(Icons.post_add),
                //   ),
                //   title: const Text("Post Testing"),
                //   onTap: () {
                //     Navigator.push(context,
                //         MaterialPageRoute(builder: (context) => const Post(
                //           postID: "mC1CZ9GHkWu6ea61766C",
                //           title: "Check out this flappy bird!",
                //           imageUrl: "https://i.ibb.co/XZ66K5Qb/e6a9ddd1799f.jpg",
                //           description: "Flappy bird takes flight #flappybird #birds #flappy #fun",
                //
                //           showComments: true,
                //           // continue with the other properties you defined in the Post class
                //         )));
                //     _scaffoldKey.currentState?.closeDrawer();
                //   },
                // ),
              ],
            )),
        body: RefreshIndicator(
          onRefresh: () async => setState((){}),
          child: Stack(children: [
            // ListView(children: [SizedBox(height: 40), Post(), Post()]),
            FutureBuilder<dynamic>(
                future: loadAllPosts(),//postsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final querySnapshot = snapshot.data;
                  if (querySnapshot == null || querySnapshot.isEmpty) {
                    return Center(child: Text("No posts found."));
                  }
                  print("Hello world!");

                  return ListView.builder(
                    itemCount: querySnapshot.length,
                    itemBuilder: (context, index) {
                      final data = querySnapshot[index];

                      // final data = doc.data() as Map<String, dynamic>;
                      // print(doc.id);
                      // print(data);
                      return Post(
                        postID: data['id'],
                        title: data['title'],
                        imageUrl: (data['url'] == "") ? "" : data['url'],

                        subtitle: data['subtitle'],

                        userID: data['userID'],
                        showComments: false,
                        onBack: reload,
                        // continue with the other properties you defined in the Post class
                      );
                    },
                  );
                }),
            // IconButton(
            //   icon: Icon(Icons.menu),
            //   onPressed: () {
            //     _scaffoldKey.currentState?.openDrawer();
            //     print("openup");
            //   },
            // ),
          ]),
        ));
  }
}

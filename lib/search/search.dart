import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:social_media_app/components/custom_button.dart';
import '../post.dart';
import '../profile/profile.dart';
import '../constants/tags.dart';

final db = FirebaseFirestore.instance;



class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  List<bool> tagStates = List.generate(Tags.tags.length, (int index) => false);

  final TextEditingController searchController = TextEditingController();

  String searchKey = "pi";

  db.collection("posts")
      .where("name", isGreaterThanOrEqualTo: searchKey)
      .where("name", isLessThanOrEqualTo: searchKey + '\uf8ff')
      .get()
      .then(
  (querySnapshot) {
    for (var docSnapshot in querySnapshot.docs) {
    print('${docSnapshot.id} => ${docSnapshot.data()}');
    }
    },
    onError: (e) => print("Error completing: $e"),
  );


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

      return posts;
    } catch (e) {
      print("Fetching all posts failed: $e");
      return null;
    }
  }

  void reload() {
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Search"),
        ),
        body: RefreshIndicator(
          onRefresh: () async => setState((){}),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: TextField(controller: searchController, decoration: InputDecoration(hintText: "Search up a recipe!", border: OutlineInputBorder(borderRadius: BorderRadius.circular(50))), textAlign: TextAlign.left)),
                    IconButton(onPressed: () {print(searchController.text);}, icon: Icon(Icons.search, size: 20)),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Filters", style: GoogleFonts.fanwoodText(fontSize: 20)),
                  IconButton(onPressed: () {
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
                                          0xFFFAFAFA)),
                                  width: 375,
                                  height: 405,
                                  child: GridView.builder(
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                    itemCount: tagStates.length,
                                    itemBuilder: (context, index) {
                                      final tag = tagStates;
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: (tagStates[index]) ? Colors.red: Colors.blue), onPressed: () {

                                          setState(() {
                                            tagStates[index] = !tagStates[index];
                                          });
                                        }, child: Text(style: GoogleFonts.alumniSans(fontSize: 20), Tags.tags[index])),
                                      );
                                    },

                                  ),
                              )
                          );
                        }
                    );
                  }, icon: Icon(Icons.filter_list)),
                ],
              ),
              // Row(children: [
              //   CustomButton(onPressed: onPressed, width: width, height: height, text: text, icon: icon)
              // ]),
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

                    return Expanded(
                      child: ListView.builder(
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
                      ),
                    );
                  }),
            ],
          )
        ));
  }
}

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

  late List<Map<String, dynamic>> posts;

  bool isLoading = true;

  List<bool> tagStates = List.generate(Tags.tags.length, (int index) => false);

  final TextEditingController searchController = TextEditingController();

  void filterByKeyword(String keyword) async {

  }

  void searchFirestore(String searchKey) async {
    // searchKey = searchKey.toLowerCase();
    QuerySnapshot abc = await db.collection("posts")
      .where("title", isGreaterThanOrEqualTo: searchKey)
      .where("title", isLessThanOrEqualTo: '$searchKey\uf8ff')
      .get();

    final data = abc.docs.map(
      (doc) {
        final a = doc.data() as Map<String, dynamic>;
        a['id'] = doc.id;
        return a;
      }
    ).toList();
    setState(() {
      posts = data;
    });
  }




  Future<dynamic> loadAllPosts() async {
    try {
      setState(() {
        isLoading = true;
      });
      final QuerySnapshot<Map<String, dynamic>> data = await FirebaseFirestore.instance.collection('posts').get();

      List<Map<String, dynamic>> postList = [];

      for (var doc in data.docs) {
        final a = doc.data();
        a['id'] = doc.id;
        postList.add(a);
      }

      postList.sort((a,b){
        return b['dateCreated'].toDate().compareTo(a['dateCreated'].toDate());
      });

      setState(() {
        posts = postList;
        isLoading = false;
      });
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
    loadAllPosts();
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
                    IconButton(onPressed: () {
                      print(searchController.text);
                      searchFirestore(searchController.text);
                    }, icon: Icon(Icons.search, size: 20)),
                  ],
                ),
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Filters", style: GoogleFonts.fanwoodText(fontSize: 20)),
                  IconButton(onPressed: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        barrierLabel: "Dismiss",
                        builder: (context) {
                          return StatefulBuilder(
                            builder: (context, StateSetter setState) {
                              return Align(
                                  alignment: AlignmentGeometry
                                      .center,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: Color(0xFFFAFAFA)
                                    ),
                                    width: 375,
                                    height: 405,
                                    child: SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: GridView.builder(
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                                        itemCount: tagStates.length,
                                        itemBuilder: (context, index) {
                                          final tag = tagStates;
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CustomButton(
                                                width: 80,
                                                height: 40,
                                                text: Text(style: GoogleFonts.alumniSans(fontSize: 20), Tags.tags[index]),
                                                icon: null,
                                                backgroundColor: (tagStates[index]) ? Colors.indigo: Colors.blue,
                                                onPressed: () {
                                                  setState(() {
                                                    tagStates[index] = !tagStates[index];
                                                  });
                                            }),
                                          );
                                        },

                                      ),
                                    ),
                                  )
                              );
                            },
                          );
                        }
                    );
                  }, icon: Icon(Icons.filter_list)),
                ],
              ),
              // Row(children: [
              //   CustomButton(onPressed: onPressed, width: width, height: height, text: text, icon: icon)
              // ]),
              (!isLoading) ? Expanded(
                child: ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final data = posts[index];

                    // final data = doc.data() as Map<String, dynamic>;
                    // print(doc.id);
                    print(data);



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
              ) : Padding(
                padding: const EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ],
          )
        ));
  }
}

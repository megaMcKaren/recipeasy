import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:socialmediaapp/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'components/custom_button.dart';
import 'components/widget_tile.dart';
import 'constants/imgPicker.dart';
import 'constants/tags.dart';
import 'firestore_utils.dart';
import 'home.dart';
import 'widget_selection.dart';

class CreatePage extends StatefulWidget {
  CreatePage({super.key, this.postID = "", this.postData = const {},});
  String postID;
  Map<String, dynamic> postData;

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {


  final db = FirebaseFirestore.instance;

  final titleController = TextEditingController();
  final subtitleController = TextEditingController();


  List<WidgetTile> addedWidgets = [];

  String postTitle = "";
  String postUrl = "";

  List<bool> tagStates = List.generate(Tags.tags.length, (int index) => false);

  void deleteAddedWidget(int index) {

    addedWidgets.removeAt(index);
    setState(() {

    });
    for (int i = index; i<addedWidgets.length; i++) {
      addedWidgets[i].index -= 1;
    }
    setState(() { });
  }

  void returnUpdatedWidgets() async{ // called when Add Widgets + is pressed
    final widgets = await Navigator.push(context, MaterialPageRoute(builder: (context) => WidgetSelector(startingCart: addedWidgets, delete: deleteAddedWidget)));
    setState(() {
      addedWidgets = widgets;
    });
    setState(() {
    });
  }



  void pickImg() async {

    try {
      var pickedImg = await ImgPicker.imgPick.pickImage(source: ImageSource.gallery);

      if (pickedImg != null) {
        final String imageUrl = await FirestoreUtils.uploadImgToDb(pickedImg);

        setState((){
          postUrl = imageUrl;
          print("CHANGED");
          // imageFile = pickedImg;
          // print(imageFile);
        });
      }
    } catch (error) {
      print("pickImg: $error");
    }
  }

  void CreatePost(dynamic goTo) async {
    try {
      List<String> tags = [];
      for (int i = 0; i < tagStates.length; i++) {
        if (tagStates[i]) {
          tags.add(Tags.tags[i]);
        }
      }

      List<String> keywords = [];

      keywords.addAll(titleController.text.toLowerCase().split(' '));
      keywords.addAll(subtitleController.text.toLowerCase().split(' '));
      print(addedWidgets);
      final postData = <String, dynamic>{
        "dateCreated": DateTime.now(),
        "title": titleController.text,
        "url": postUrl, // placeholder since not used
        "userID": FirebaseAuth.instance.currentUser!.uid,
        "subtitle": subtitleController.text,
        "likes": 0,
        "dislikes": 0,
        "comments": [],
        "widgets": FirestoreUtils.widgetTilesToMaps(addedWidgets),
        "keywords": keywords,
        "tags": tags,
      };
      if (!(goTo == null)) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => goTo),
              (route) => false,
        );
      }

      await db.collection("posts").doc().set(postData);
    } catch (error) {
      print("Error creating post $error");
      print(addedWidgets[0].type);
      print(addedWidgets[0].data);
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.postData.isNotEmpty) {
      titleController.text = widget.postData["title"];
      subtitleController.text = widget.postData["subtitle"];
      postUrl = widget.postData["url"];
      addedWidgets = FirestoreUtils.mapListToWidgetTiles(widget.postData["widgets"], deleteAddedWidget);
    }

  }

  @override
  Widget build(BuildContext context) {
    titleController.addListener(() {
      setState(() {
        postTitle = titleController.text;
      });
    });
    return Material(
      color: Color(0xFFEEEEFF),
      child: SingleChildScrollView(
        child: Column(children: [
          SizedBox(height: 87.5),
          Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 15, top: 15),
                      child: CustomButton(
                          onPressed: () {
                            Navigator.pop(context, true);
                          },
                          width: 40,
                          height: 30,
                          text: SizedBox(),
                          icon: Icon(Icons.arrow_back, size: 23),
                          backgroundColor: Color(0xFFE0E0FF),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox(
                      width: 260,
                      child: TextField(
                        controller: titleController,
                        onChanged: (input) {
                          setState(() {});
                        },
                        textAlign: TextAlign.center,
                        style: GoogleFonts.habibi(fontSize: 21),
                        decoration: const InputDecoration(

                          hintText: "Recipe Name",
                        ),
                      ),
                    ),
                  ),
                ]
              ),
          const SizedBox(height: 10),

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

          Padding(padding: EdgeInsets.only(left: 30, right: 30, top: 30), child: Container(
              decoration: BoxDecoration(color: Color(0xFFFDFBFF), borderRadius: BorderRadius.circular(25)),
              width: (postUrl.isEmpty) ? 380: null,
              height: (postUrl.isEmpty) ? 390: null,
              child: Align(
                  alignment: AlignmentGeometry.topCenter,
                  child: (postUrl.isEmpty)
                      ? Column(
                      children: [
                        SizedBox(height: 20),
                        Text(style: GoogleFonts.robotoSlab(fontWeight: FontWeight.w600), "Thumbnail"),
                        SizedBox(height: 20),
                        GestureDetector(onTap: () => pickImg(),//CreatePage.pickImg,
                          child: Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: Color(0xFFD1D1EF)),
                              // onPressed: () {print("Image Picker");},
                              width: 300, height: 300,
                              child: Icon(Icons.add_circle, size: 67, color: Colors.white)
                          ),
                        ),
                      ]
                  ) : CupertinoContextMenu(actions: <Widget>[
                    Align(
                      alignment: AlignmentGeometry.center,
                      child: CupertinoContextMenuAction(
                        onPressed: () {

                          Navigator.pop(context);
                        },
                        isDestructiveAction: true,
                        trailingIcon: CupertinoIcons.delete,
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                      child: GestureDetector(onTap: () => pickImg(), child: ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.network((postUrl.isEmpty) ? widget.postData["url"] : postUrl))))
              )
          )),

          SizedBox(height: 20),

          SizedBox(
                width: 330,
                child: TextField(
                  controller: subtitleController,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  maxLength: 37,
                  style: GoogleFonts.aBeeZee(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: "Enter subtitle",
                    border: OutlineInputBorder(),
                  ),
                ),
              ), // TextField for Subtitle

          ListView.builder(
                  padding: EdgeInsets.zero, // <_+AYH_)IHpode
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: addedWidgets.length,
                  itemBuilder: (context, index) {
                    // print("$addedWidgets + $index vexillology");
                    return addedWidgets[index];

                  }
              ),

          SizedBox(height: 20),

          CustomButton(
                onPressed: returnUpdatedWidgets,
                width: 230,
                height: 40,
                text: Text("Add Widgets", style: GoogleFonts.robotoFlex(fontSize: 20, fontWeight: FontWeight.w600)),
                icon: Icon(Icons.add),
                backgroundColor: Color(0xFFE0E0FF),

              ),

          SizedBox(height: 20),

          (widget.postData.isEmpty) ? CustomButton(
                onPressed: (postTitle != "")
                    ? () {
                  CreatePost(HomeScreen());
                  print("HELLO?! CREATE?");
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const HomeScreen()),
                  //       (route) => false,
                  // );
                }
                    : null,
                width: 230,
                height: 40,
                text: Text("Upload Recipe", style: GoogleFonts.robotoFlex(fontSize: 20, fontWeight: FontWeight.w600)), //Text(text, style: GoogleFonts.robotoFlex(color: Colors.black, fontSize: 30, decoration: TextDecoration.none))
                icon: Icon(Icons.upload_file),
                backgroundColor: Color(0xFFE0E0FF),

              ) : CustomButton(
                onPressed: () {
                  FirestoreUtils.updatePostData({"url": postUrl, "title": titleController.text,"subtitle": subtitleController.text,"widgets": FirestoreUtils.widgetTilesToMaps(addedWidgets),}, widget.postID);


                  Navigator.pop(context, true);
                  Navigator.of(context).pop();
                },
                width: 230,
                height: 40,
                text: Text("Update Recipe", style: GoogleFonts.robotoFlex(fontSize: 20, fontWeight: FontWeight.w600)), //Text(text, style: GoogleFonts.robotoFlex(color: Colors.black, fontSize: 30, decoration: TextDecoration.none))
                icon: Icon(Icons.update),
                backgroundColor: Color(0xFFE0E0FF),

              ),

          SizedBox(height: 75),

        ]),
      ));

  }
}

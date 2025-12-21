import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'package:socialmediaapp/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'components/custom_button.dart';
import 'components/widget_tile.dart';
import 'firestore_utils.dart';
import 'home.dart';
import 'widget_selection.dart';

class CreatePage extends StatefulWidget {
  CreatePage({super.key, this.postID = "", this.postData = const {}});
  String postID;
  Map<String, dynamic> postData;

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {


  final db = FirebaseFirestore.instance;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  List<WidgetTile> addedWidgets = [];

  String postTitle = "";

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

  void CreatePost(dynamic goTo) async {
    try {
      final postData = <String, dynamic>{
        "dateCreated": DateTime.now(),
        "title": titleController.text,
        "url": "", // placeholder since not used
        "userID": FirebaseAuth.instance.currentUser!.uid,
        "description": descriptionController.text,
        "likes": 0,
        "dislikes": 0,
        "comments": [],
        "widgets": FirestoreUtils.widgetTilesToMaps(addedWidgets),
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
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.postData.isNotEmpty) {
      titleController.text = widget.postData["title"];
      descriptionController.text = widget.postData["description"];
      // print("${widget.postData["widgets"]}");
      addedWidgets = FirestoreUtils.mapListToWidgetTiles(widget.postData["widgets"], deleteAddedWidget);
    }

  }

  @override
  Widget build(BuildContext context) {
    // final titleController = TextEditingController(text: widget.title);
    // final descriptionController = TextEditingController(text: widget.desc);
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
                            Navigator.pop(context);
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

              const SizedBox(height: 20),

              SizedBox(
                width: 330,
                child: TextField(
                  controller: descriptionController,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: GoogleFonts.aBeeZee(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: "Enter description",
                    border: OutlineInputBorder(),
                  ),
                ),
              ), // TextField for Description

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

              CustomButton(
                onPressed: (postTitle != "")
                    ? () {
                  CreatePost(HomeScreen());
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

              ),

              SizedBox(height: 15),

            ]),
      ));

  }
}

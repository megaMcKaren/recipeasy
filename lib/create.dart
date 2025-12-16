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
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {


  final db = FirebaseFirestore.instance;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  List<WidgetTile> addedWidgets = [];

  String postTitle = "";
  XFile? imageFile;
  ImagePicker imagePicker = ImagePicker();
  String imageUrl = "";

  void deleteAddedWidget(int index) {
    print("$index AH");

    addedWidgets.removeAt(index);
    setState(() {

    });
    for (int i = index; i<addedWidgets.length; i++) {
      print(i);
      addedWidgets[i].index -= 1;
    }
    setState(() { });
  }

  void returnUpdatedWidgets() async{ // called when Add Widgets + is pressed
    print("Test add widget");
    final widgets = await Navigator.push(context, MaterialPageRoute(builder: (context) => WidgetSelector(startingCart: addedWidgets, delete: deleteAddedWidget)));
    setState(() {
      addedWidgets = widgets;
    });
    setState(() {
    });
  }



  // static Future<String> uploadImgToDb(XFile file) async {
  //   try {
  //     // Converts image into "bytes", a way of representing information
  //     // final bytes = await file.readAsBytes();
  //     // // Convert to base64, which is a more compact string of information
  //     // final base64Image = base64Encode(bytes);
  //
  //     // Define the website we want to send to, while also giving them our API key (password)
  //     // Make sure to replace the API key with yours in the link below
  //     final uri = Uri.parse(
  //         "http://129.146.24.130/alex/api/upload");
  //     const password = "alex";
  //     // Send "request", telling imgBB we want to upload the attached image
  //     // final response = await http.post(
  //     //   uri,
  //     //   body: {
  //     //     "image": base64Image,
  //     //   },
  //     // );
  //     final request = http.MultipartRequest("POST",uri);
  //     request.headers["Authorization"] = "Bearer $password";
  //     print("File path: ${file.path}");
  //
  //     final multipartfile = await http.MultipartFile.fromPath("file", file.path);
  //     request.files.add(multipartfile);
  //
  //     final streamedresponse = await request.send();
  //     final response = await http.Response.fromStream(streamedresponse);
  //
  //     // Check if the request was successful, code 200 means it's all good! (anything that starts with 400 is usually an error)
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       // final returnedImageUrl = data['data']['url'];
  //       final returnedImageUrl = data['url'];
  //       print(returnedImageUrl);
  //       return returnedImageUrl;
  //
  //     } else {
  //       print("Error uploading: ${response.statusCode} ${response.body}");
  //     }
  //   } catch (error) {
  //     print("error for put link $error");
  //   }
  //   return "";
  // }

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
                    print("$addedWidgets + $index vexillology");
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

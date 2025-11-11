import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// import 'package:socialmediaapp/home.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final db = FirebaseFirestore.instance;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  String postTitle = "";
  XFile? imageFile;
  ImagePicker imagePicker = ImagePicker();
  String imageUrl = "";
  void pickImg() async {
    try {
      var pickedImg = await imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedImg != null) {
        // uploadImgToDb(pickedImg);

        setState((){
          imageFile = pickedImg;
        });
      }
    } catch (error) {
      print("pickImg: $error");
    }
  }

  Future<String> uploadImgToDb(XFile file) async {
    try {
      // Converts image into "bytes", a way of representing information
      // final bytes = await file.readAsBytes();
      // // Convert to base64, which is a more compact string of information
      // final base64Image = base64Encode(bytes);

      // Define the website we want to send to, while also giving them our API key (password)
      // Make sure to replace the API key with yours in the link below
      final uri = Uri.parse(
          "http://129.146.24.130/alex/api/upload");
      const password = "alex";
      // Send "request", telling imgBB we want to upload the attached image
      // final response = await http.post(
      //   uri,
      //   body: {
      //     "image": base64Image,
      //   },
      // );
      final request = http.MultipartRequest("POST",uri);
      request.headers["Authorization"] = "Bearer $password";
      print("File path: ${file.path}");

      final multipartfile = await http.MultipartFile.fromPath("file", file.path);
      request.files.add(multipartfile);

      final streamedresponse = await request.send();
      final response = await http.Response.fromStream(streamedresponse);

      // Check if the request was successful, code 200 means it's all good! (anything that starts with 400 is usually an error)
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // final returnedImageUrl = data['data']['url'];
        final returnedImageUrl = data['url'];
        print(returnedImageUrl);
        return returnedImageUrl;

      } else {
        print("Error uploading: ${response.statusCode} ${response.body}");
      }
    } catch (error) {
      print("error for put link $error");
    }
    return "";
  }

  void CreatePost(dynamic goTo) async {
    try {
      final postData = <String, dynamic>{
        "dateCreated": DateTime.now(),
        "title": titleController.text,
        "url": await uploadImgToDb(imageFile!),
        "userID": FirebaseAuth.instance.currentUser!.uid,
        "description": descriptionController.text,
        "likes": 0,
        "dislikes": 0,
        "comments": [],
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
    titleController.addListener(() {
      setState(() {
        postTitle = titleController.text;
      });
    });
    return Material(
      child: Container(
          child: ListView(children: [
            ElevatedButton(
              child: const Text("go back"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 340,
              child: TextField(
                controller: titleController,
                onChanged: (input) {
                  setState(() {});
                },
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: "Post Title",
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 340,
              child: TextField(
                controller: descriptionController,
                textAlign: TextAlign.center,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Enter description",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                pickImg();
                print("pick");
              },
              child: (imageFile == null)
                  ? Container(
                  width: 340,
                  height: 340,
                  color: Color(0xffb4b4b4),
                  child: Icon(
                    size: 67,
                    Icons.add_circle,
                    color: Colors.white,
                  ))
                  : Image.file(File(imageFile!.path)),
            ),
            ElevatedButton(
                onPressed: (postTitle != "" && !(imageFile == null))
                    ? () {
                  CreatePost(HomeScreen());
                  // Navigator.pushAndRemoveUntil(
                  //   context,
                  //   MaterialPageRoute(builder: (_) => const HomeScreen()),
                  //       (route) => false,
                  // );
                }
                    : null,
                child: Text("Create post"))
          ])),
    );
  }
}

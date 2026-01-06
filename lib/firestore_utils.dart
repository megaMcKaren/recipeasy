import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'components/widget_tile.dart';

class FirestoreUtils {
  static final _db = FirebaseFirestore.instance;

  static Future<void> deletePost(String postID) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postID)
          .delete();

      print('Post $postID deleted successfully.');
    } catch (e) {
      print('Error deleting post: $e');
    }
  }

  // Fetch post data using a post ID
  static Future<Map<String, dynamic>?> fetchPostData(String postId) async {
    try {
      final postSnap = await _db.collection('posts').doc(postId).get();

      if (!postSnap.exists) return null;
      return postSnap.data();
    } catch (e) {
      print('Error fetching post: $e');
      return null;
    }
  }

  // Fetch user data using a user ID
  static Future<Map<String, dynamic>?> fetchUserData(String userId) async {
    try {
      final userSnap = await _db.collection('profiles').doc(userId).get();

      if (!userSnap.exists) return null;
      return userSnap.data();
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static void updatePostData(dynamic newData, String postId,) async {
    try {
      final postSnap = _db.collection('posts').doc(postId);

      // if (!userSnap.exists) return null;
      // return userSnap.data();
      postSnap.update(newData);

    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static Map<String, dynamic> widgetTileToMap(WidgetTile widgetTile) {
    final data = widgetTile.data;
    switch(widgetTile.data["type"]) {
      case WidgetTileType.imagePicker : widgetTile.data["type"] = "imagePicker";
      case WidgetTileType.ingredientsList: widgetTile.data["type"] = "ingredientsList";
    }
    final input = data;
    print(input);
    return input;
  }

  static WidgetTile mapToWidgetTile(Map<String, dynamic> map, int mapIndex, Function delete) {
    WidgetTileType type = WidgetTileType.none;
    switch(map["type"]) {
      case "imagePicker" : type = WidgetTileType.imagePicker;
      case "ingredientsList" : type = WidgetTileType.ingredientsList;
    }
    return WidgetTile(type: type, delete: delete, index: mapIndex, data: map);
  }

  static List<Map<String, dynamic>>  widgetTilesToMaps(List<WidgetTile> widgetTiles) {
    List<Map<String, dynamic>> result = [];
    for (WidgetTile widgetTile in widgetTiles) {
      result.add(widgetTileToMap(widgetTile));
    }
    print(result);
    return result;
  }

  static List<WidgetTile> mapListToWidgetTiles(List<dynamic> widgets, Function delete) {
    List<WidgetTile> result = [];
    for (int i = 0; i<widgets.length; i++) {
      result.add(mapToWidgetTile(widgets[i], i, delete));
    }
    return result;
  }

  static void updateUserData(dynamic newData, String userId, String fieldName, {bool addArray = false,bool removeArray = false}) async {
    try {
      final userSnap = _db.collection('profiles').doc(userId);

      // if (!userSnap.exists) return null;
      // return userSnap.data();
      if (!addArray && !removeArray) {
        userSnap.update({fieldName: newData,});
      } else if (addArray){
        userSnap.update({fieldName: FieldValue.arrayUnion([newData])});
      } else if (removeArray){
        userSnap.update({fieldName: FieldValue.arrayRemove([newData])});
      }

    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> fetchPostCreatorData(String postId) async {
    try {
      final postSnap = await _db.collection('posts').doc(postId).get();

      if (!postSnap.exists) return null;
      // return postSnap.data();
      final postData = postSnap.data();
      final userID = postData!["userID"];
      return await fetchUserData(userID);
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  static Future<bool> isFollowing(String followerID, String followingID) async {
    final profileData = await fetchUserData(followingID);
    return profileData!['followers'].contains(followerID);
  }

  static Future<void> followUser(String profileID, String userID) async {

    if (!await isFollowing(userID, profileID)) {
      updateUserData(userID,profileID,"followers",addArray:true);
      updateUserData(profileID,userID,"following",addArray:true);
    } else {
      updateUserData(userID,profileID,"followers",removeArray:true);
      updateUserData(profileID,userID,"following",removeArray:true);
    }
  }


  static Future<String> uploadImgToDb(XFile file) async {
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
}
import 'package:cloud_firestore/cloud_firestore.dart';

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
}
// Then you could combine them like this in your main code:
//
// final postData = await FirestoreUtils.fetchPostData(postId);
// final userId = postData?['userID'];
//
// if (userId != null) {
// final userData = await FirestoreUtils.fetchUserData(userId);
// final username = userData?['username'];
// final profilePic = userData?['profilePictureUrl'];
// }
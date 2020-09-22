import "dart:io";

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SearchService {
  Future getUserByUserName(String phone) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("phone", isEqualTo: phone)
        .get();
  }

  Future getUserByEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
  }

  Future getUserByUserPhone(String number) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("phoneNumber", isEqualTo: number)
        .get();
  }

  creatChatRoom(String roomid, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(roomid)
        .set(chatRoomMap)
        .catchError((onError) {
      print(onError);
    });
  }

  startConversation(String email, String roomID) {
    List<String> users = [email, FirebaseAuth.instance.currentUser.email];
 Map<String, bool> annonymous = {
      email: false,
      FirebaseAuth.instance.currentUser.email: false
    };
    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "chatroomid": roomID,
      "timestamp": DateTime.now().toString(),
      "annomynus":annonymous
    };
    creatChatRoom(roomID, chatRoomMap);
  }

  addConversationMessages(
      String roomid, Map<String, dynamic> messageMap) async {
    DocumentReference documentReference = await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(roomid)
        .collection("chats")
        .add(messageMap)
        .catchError((e) {
      print(e);
    });
  }

  Stream<User> islogedIn() {
    return FirebaseAuth.instance.authStateChanges();
  }

  Stream getConversationMessages(String roomid) {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(roomid)
        .collection("chats")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Stream getlast(String roomid) {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(roomid)
        .collection("chats")
        .orderBy("timestamp")
        .snapshots();
  }

  Stream getRecentChats(String myemail) {
    return FirebaseFirestore.instance
        .collection("ChatRoom")
        .orderBy("timestamp", descending: true)
        .where("users", arrayContains: myemail)
        .snapshots();
  }

  updateChatDate(String roomid) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(roomid)
        .update({"timestamp": DateTime.now().toString()});
  }

  Future getAllChats() async {
    return await FirebaseFirestore.instance.collection("users").get();
  }

  Future<void> addUserImage(String userid, String userImage) async {
    await FirebaseFirestore.instance.collection("users").doc(userid).update(
      {"userImage": userImage},
    ).catchError((onError) {
      print(onError);
    });
  }

  addBackGroundToUser(String userid, String backgroundImage) {
    FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .update({"backgroundImage": backgroundImage}).catchError((e) {
      print(e);
    });
  }

  updateUsername(String userid, String newname) {
    FirebaseFirestore.instance.collection("users").doc(userid).update({
      "username": newname,
    }).catchError((e) {
      print(e);
    });
  }

  Future<void> updateUserPicture(File myfile) async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("userImages")
        .child("${FirebaseAuth.instance.currentUser.email}.jpg");

    final StorageUploadTask task = ref.putFile(myfile);
    var imageurl = await (await task.onComplete).ref.getDownloadURL();

    FirebaseAuth.instance.currentUser
        .updateProfile(photoURL: imageurl)
        .then((value) =>
            addUserImage(FirebaseAuth.instance.currentUser.uid, imageurl))
        .catchError((onError) {
      print(onError);
    });
  }
}

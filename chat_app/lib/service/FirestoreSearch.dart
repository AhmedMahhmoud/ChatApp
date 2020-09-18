import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SearchService {
  Future getUserByUserName(String name) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: name)
        .get();
  }

  Future getUserByEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("email", isEqualTo: email)
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

  addConversationMessages(String roomid, messageMap) async {
    await FirebaseFirestore.instance
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
        .orderBy("timestamp")
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
    updateUsername(String userid,String newname){
   FirebaseFirestore.instance
        .collection("users")
        .doc(userid)
        .update({"username": newname}).catchError((e) {
      print(e);
    });
    }
}

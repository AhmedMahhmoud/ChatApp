import 'dart:ui';

import 'package:chat_app/Views/Home.dart';

import 'package:chat_app/service/FirestoreSearch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  final String chaterImage;
  final String roomiD;
  final String chatername;
  ChatScreen({this.roomiD, this.chatername, this.chaterImage});
  sendddMessageOnline() {
    messages = {
      "message": sendmessage.text,
      "sentBy": FirebaseAuth.instance.currentUser.email,
      "timestamp": DateTime.now().toString(),
      "isliked": false,
    };
    if (sendmessage.text.isNotEmpty) {
      return searchService.addConversationMessages(roomiD, messages);
    }
  }

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

var enteredMessage = "";
SearchService searchService = SearchService();
Map<String, dynamic> messages = {};
TextEditingController sendmessage = new TextEditingController();

class _ChatScreenState extends State<ChatScreen> {
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.13,
        shadowColor: Colors.white,
        title: Row(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 10,
            ),
            Container(
                width: MediaQuery.of(context).size.width / 5.5,
                height: MediaQuery.of(context).size.height / 9.1,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: NetworkImage(widget.chaterImage != null
                        ? widget.chaterImage
                        : "https://pickaface.net/gallery/avatar/20151205_194059_2696_Chat.png"),
                  ),
                )),
            SizedBox(
              width: 15,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  child: Text(
                    widget.chatername,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1),
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                FittedBox(
                  child: Text(
                    "Online",
                    style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                )
              ],
            ),
            Spacer(),
            IconButton(
              icon: Icon(Icons.home),
              iconSize: 30,
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Home(),
                    ));
              },
            )
          ],
        ),
      ),
      // automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          color: Color(0xff101D25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamBuilder(
                stream: searchService.getConversationMessages(widget.roomiD),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (context, index) {
                          QueryDocumentSnapshot querySnapshot =
                              snapshot.data.docs[index];

                          return MessageTile(
                              snapshot.data.docs[index].data()['message'],
                              snapshot.data.docs[index].data()["sentBy"] ==
                                  FirebaseAuth.instance.currentUser.email,
                              snapshot.data.docs[index].data()["isliked"],
                              widget.roomiD,
                              querySnapshot.id);
                        },
                      ),
                    );
                  }
                  return Container();
                },
              ),
              Container(
                height: MediaQuery.of(context).size.height / 7.4,
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      size: 30,
                      color: Colors.pink,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (value) {
                          setState(() {
                            enteredMessage = value;
                          });
                        },
                        controller: sendmessage,
                        decoration: InputDecoration(
                            disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide(color: Colors.grey),
                            ),
                            hintText: "Type something here ..",
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontStyle: FontStyle.italic)),
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                    enteredMessage.trim().isEmpty
                        ? Container()
                        : GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              widget.sendddMessageOnline();
                              searchService.updateChatDate(widget.roomiD);
                              setState(() {
                                sendmessage.clear();
                                enteredMessage = "";
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.only(left: 20),
                              child: Center(
                                child: Icon(
                                  Icons.send,
                                  size: 30,
                                  color: Colors.pink,
                                ),
                              ),
                            ),
                          )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MessageTile extends StatefulWidget {
  final String message;
  final bool isMe;
  bool isVisible = false;
  final String roomid;
  String querySnapshot;
  MessageTile(
      this.message, this.isMe, this.isVisible, this.roomid, this.querySnapshot);

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: widget.isMe ? Alignment.topLeft : Alignment.topRight,
      child: InkWell(
        onDoubleTap: () async {
          print(!widget.isVisible);
          await FirebaseFirestore.instance
              .collection("ChatRoom")
              .doc(widget.roomid)
              .collection("chats")
              .doc(widget.querySnapshot)
              .update({"isliked": !widget.isVisible}).catchError((onError) {
            print(onError);
          });
        },
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10, left: 5, top: 4),
              decoration: BoxDecoration(
                  gradient: !widget.isMe
                      ? LinearGradient(
                          colors: [Colors.blue[700], Colors.blue[600]],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)
                      : LinearGradient(
                          colors: [Colors.teal, Colors.deepPurpleAccent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                  borderRadius: widget.isMe
                      ? BorderRadius.only(
                          bottomRight: Radius.circular(25),
                          topLeft: Radius.circular(35),
                          // topRight: Radius.circular(35)
                        )
                      : BorderRadius.only(
                          bottomLeft: Radius.circular(25),
                          //topLeft: Radius.circular(35),
                          topRight: Radius.circular(35)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 1,
                        offset: Offset(1, 2),
                        color: Colors.teal),
                  ]),
              child: Text(
                widget.message,
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.start,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Visibility(
                visible: widget.isVisible,
                child: Container(
                  child: Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: 20,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

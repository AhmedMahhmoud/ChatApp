import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/scheduler.dart';
import 'package:random_string/random_string.dart';
import 'package:chat_app/Views/Home.dart';

import 'package:chat_app/service/FirestoreSearch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  @override
  final String chaterImage;
  final String roomiD;
  final String chatername;
  bool annomynus;
  ChatScreen({this.roomiD, this.chatername, this.chaterImage, this.annomynus});
  sendddMessageOnline(String type, String text) {
    messages = {
      "message": text,
      "sentBy": FirebaseAuth.instance.currentUser.email,
      "timestamp": DateTime.now().toString(),
      "isliked": false,
      "type": type,
    };
    if (type == "text") {
      if (sendmessage.text.isNotEmpty) {
        return searchService.addConversationMessages(roomiD, messages);
      }
    }
    return searchService.addConversationMessages(roomiD, messages);
  }

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

ScrollController _controller = ScrollController();
var enteredMessage = "";
File _myfile;
var firstHeart = false;
var secondHeart = false;
var revealnow = false;
SearchService searchService = SearchService();
Map<String, dynamic> messages = {};
TextEditingController sendmessage = new TextEditingController();

class _ChatScreenState extends State<ChatScreen> {
  Widget build(BuildContext context) {
    String myEmail = FirebaseAuth.instance.currentUser.email;
    String temp = widget.roomiD.replaceAll(myEmail, "");
    String finalString = temp.replaceAll("_", "");

    GetImageAndUploadIt() async {
      try {
        final selectedImage =
            await ImagePicker().getImage(source: ImageSource.gallery);
        setState(() {
          _myfile = File(selectedImage.path);
        });

        StorageReference ref = FirebaseStorage.instance
            .ref()
            .child("userImages")
            .child("${randomString(9)}.jpg");
        StorageUploadTask task = ref.putFile(_myfile);
        var imageurl =
            await (await task.onComplete).ref.getDownloadURL().catchError((e) {
          print(e);
        });
        widget.sendddMessageOnline("image", imageurl);
      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.13,
          shadowColor: Colors.white,
          title: widget.annomynus
              ? Row(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        width: MediaQuery.of(context).size.width / 4,
                        height: MediaQuery.of(context).size.height / 11,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: widget.chaterImage != null
                                  ? NetworkImage(widget.chaterImage)
                                  : AssetImage("lib/assets/f.png")),
                        ),
                      ),
                    ),
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
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Your identity is hidden",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 26),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          "Chater identity is hidden",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width / 26),
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            GestureDetector(
                              onTap: () async {
                                setState(() {
                                  secondHeart = true;
                                });
                                await FirebaseFirestore.instance
                                    .collection("ChatRoom")
                                    .doc(widget.roomiD)
                                    .set({
                                  "annomynus": {myEmail: true}
                                }, SetOptions(merge: true));
                              },
                              child: Icon(
                                secondHeart
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: Colors.pink,
                                size: 30,
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection("ChatRoom")
                                  .doc(widget.roomiD)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                try {
                                  if (snapshot.data.data()['annomynus']
                                              ['$myEmail'] ==
                                          true &&
                                      snapshot.data.data()['annomynus']
                                              ['$finalString'] ==
                                          true) {
                                    {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            widget.annomynus = true;
                                          });
                                        },
                                        child: Text(
                                          "Tap here to reveal",
                                          style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  26),
                                        ),
                                      );
                                    }
                                  } else if (snapshot.data.data()['annomynus']
                                              ['$myEmail'] ==
                                          true &&
                                      snapshot.data.data()['annomynus']
                                              ['$finalString'] ==
                                          false) {
                                    return Text(
                                      "Waiting the other side .",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              32.7),
                                    );
                                  } else if (snapshot.data.data()['annomynus']
                                              ['$myEmail'] ==
                                          false &&
                                      snapshot.data.data()['annomynus']
                                              ['$finalString'] ==
                                          true) {
                                    return Text(
                                      "Click now to reveal !",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              32.7),
                                    );
                                  }
                                } catch (e) {
                                  print(e);
                                }
                                return Text(
                                  "",
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              32.7),
                                );
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            backgroundColor: Colors.black,
                            context: context,
                            builder: (context) {
                              return SingleChildScrollView(
                                child: Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: [
                                        Colors.white,
                                        Colors.teal[200]
                                      ]),
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(40),
                                          topRight: Radius.circular(40))),
                                  padding: EdgeInsets.all(15),
                                  height: 400,
                                  child: Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Text(
                                            "It is pretty simple .. Chat anonymously works like that : At first No body knows the other but .. if you both agreed on showing your phone number to each other (By pressing the Love icon)then the identity will be reveald !",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          Container(
                                            height: 400,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                image: DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image: NetworkImage(
                                                        "https://ceblog.s3.amazonaws.com/wp-content/uploads/2018/09/10131158/live-chat-4.jpg"))),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                      },
                      child: Column(
                        children: [
                          Container(
                            child: Icon(
                              Icons.help,
                              size: 30,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ));
                            },
                            child: Icon(
                              Icons.home,
                              size: 40,
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                )),
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
                  try {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: ListView.builder(
                          reverse: true,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          controller: _controller,
                          itemCount: snapshot.data.docs.length,
                          itemBuilder: (context, index) {
                            QueryDocumentSnapshot querySnapshot =
                                snapshot.data.docs[index];

                            return MessageTile(
                              datetime:
                                  snapshot.data.docs[index].data()['timestamp'],
                              isMe:
                                  snapshot.data.docs[index].data()["sentBy"] ==
                                      FirebaseAuth.instance.currentUser.email,
                              isVisible:
                                  snapshot.data.docs[index].data()["isliked"],
                              message:
                                  snapshot.data.docs[index].data()['message'],
                              querySnapshot: querySnapshot.id,
                              roomid: widget.roomiD,
                              messageType:
                                  snapshot.data.docs[index].data()['type'],
                            );
                          },
                        ),
                      );
                    }
                  } catch (e) {
                    print(e);
                  }
                  return Container();
                },
              ),
              Container(
                height: MediaQuery.of(context).size.height / 7.4,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        GetImageAndUploadIt();
                      },
                      child: Icon(
                        Icons.image,
                        size: 30,
                        color: Colors.pink,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: TextField(
                        onTap: () => Timer(
                            Duration(milliseconds: 122),
                            () => _controller
                                .jumpTo(_controller.position.minScrollExtent)),
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
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    enteredMessage.trim().isEmpty
                        ? Container()
                        : GestureDetector(
                            onTap: () async {
                              FocusScope.of(context).unfocus();
                              widget.sendddMessageOnline(
                                  "text", sendmessage.text);
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
  String datetime;
  String messageType;
  MessageTile(
      {this.message,
      this.isMe,
      this.isVisible,
      this.roomid,
      this.messageType,
      this.querySnapshot,
      this.datetime});

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
          if (widget.isMe != true) {
            await FirebaseFirestore.instance
                .collection("ChatRoom")
                .doc(widget.roomid)
                .collection("chats")
                .doc(widget.querySnapshot)
                .update({"isliked": !widget.isVisible}).catchError((onError) {
              print(onError);
            });
          }
        },
        child: Stack(
          children: [
            Container(
              padding: widget.messageType == "text"
                  ? EdgeInsets.all(16)
                  : EdgeInsets.only(left: 0),
              margin: widget.messageType == "text"
                  ? EdgeInsets.only(bottom: 10, left: 5, top: 4)
                  : EdgeInsets.all(5),
              decoration: widget.messageType == "text"
                  ? BoxDecoration(
                      gradient: !widget.isMe
                          ? LinearGradient(
                              colors: [Colors.grey[500], Colors.teal[600]],
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
                        ])
                  : BoxDecoration(),
              child: widget.messageType == "text"
                  ? Text(
                      widget.message,
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.start,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        widget.message,
                        height: 200,
                      ),
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
            ),
            Visibility(
              visible: widget.isVisible,
              child: Positioned(
                bottom: 1,
                child: Text(
                    DateFormat("jm").format(DateTime.parse(widget.datetime)),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}

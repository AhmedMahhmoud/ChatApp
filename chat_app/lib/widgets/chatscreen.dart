import 'package:chat_app/Views/Home.dart';

import 'package:chat_app/service/FirestoreSearch.dart';

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
Map<String, String> messages = {};
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
                width: MediaQuery.of(context).size.width/5.5,
                
                height: MediaQuery.of(context).size.height/9.1,
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
                          return MessageTile(
                            snapshot.data.docs[index].data()['message'],
                            snapshot.data.docs[index].data()["sentBy"] ==
                                FirebaseAuth.instance.currentUser.email,
                          );
                        },
                      ),
                    );
                  }
                  return Container();
                },
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                height: 50,
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
                        style: TextStyle(color: Colors.white),
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

class MessageTile extends StatelessWidget {
  final String message;
  final bool isMe;
  MessageTile(this.message, this.isMe);
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.topLeft : Alignment.topRight,
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.only(bottom: 10, left: 5, top: 4),
        decoration: BoxDecoration(
            gradient: !isMe
                ? LinearGradient(
                    colors: [Colors.blue[700], Colors.blue[600]],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter)
                : LinearGradient(
                    colors: [Colors.teal, Colors.deepPurpleAccent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
            borderRadius: isMe
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
                  blurRadius: 1, offset: Offset(1, 2), color: Colors.teal),
            ]),
        child: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

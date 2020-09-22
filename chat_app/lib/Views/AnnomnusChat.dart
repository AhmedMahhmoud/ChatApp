import 'package:chat_app/Views/chatscreen.dart';
import 'package:chat_app/service/FirestoreSearch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Home.dart';

class AnnomnusChat extends StatefulWidget {
  @override
  _AnnomnusChatState createState() => _AnnomnusChatState();
}


SearchService searchService = new SearchService();

class _AnnomnusChatState extends State<AnnomnusChat> {
  SearchService searchService = new SearchService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: FutureBuilder(
        future: searchService.getAllChats(),
        builder: (context, snapshot) {
          // QueryDocumentSnapshot querySnapshot = snapshot.data.docs[0];

          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data.docs.length,
              itemBuilder: (context, index) {
                if (snapshot.data.docs[index].data()['email'] !=
                    FirebaseAuth.instance.currentUser.email) {
                  return Container(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 80,
                                height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(snapshot
                                          .data.docs[index]
                                          .data()['userImage'])),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 30,
                            ),
                            GestureDetector(
                              onTap: () async {
                                await searchService.startConversation(
                                    snapshot.data.docs[index].data()['email'],
                                    getchatID(
                                        FirebaseAuth.instance.currentUser.email,
                                        snapshot.data.docs[index]
                                            .data()['email']));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                        chaterImage: snapshot.data.docs[index]
                                            .data()['userImage'],
                                        chatername: snapshot.data.docs[index]
                                            .data()['username'],
                                        roomiD: getchatID(
                                            FirebaseAuth
                                                .instance.currentUser.email,
                                            snapshot.data.docs[index]
                                                .data()['email']),
                                        annomynus: false),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    gradient: LinearGradient(colors: [
                                      Colors.grey,
                                      Colors.teal[700],
                                      Colors.grey[500]
                                    ])),
                                child: Text(
                                  "Chat Anonymously NOW!",
                                  style: TextStyle(color: Colors.white),
                                ),
                                padding: EdgeInsets.all(10),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                }
                return Text("");
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}

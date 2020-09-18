import 'package:chat_app/Views/Home.dart';
import 'package:chat_app/Views/UserData.dart';
import 'package:chat_app/Views/drawer.dart';
import 'package:chat_app/service/FirestoreSearch.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'Views/logo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
 
  SearchService searchService=new SearchService();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme:
          ThemeData(primaryColor: Color(0xff101D25), fontFamily: "Montserrat"),
      home: StreamBuilder(
        stream: (searchService.islogedIn()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Home();
          }

          return HomeLogo();
        },
      ),
    );
  }
}

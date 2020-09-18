import 'dart:async';

import 'package:chat_app/Views/UserData.dart';
import 'package:chat_app/service/FirestoreSearch.dart';
import 'package:chat_app/widgets/showToast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ThemeExambles extends StatefulWidget {
  @override
  _ThemeExamblesState createState() => _ThemeExamblesState();
}

class _ThemeExamblesState extends State<ThemeExambles> {
  @override
  void initState() {
    isDone = false; // TODO: implement initState
    super.initState();
  }

  @override
  SearchService searchService = new SearchService();
  List<ThemeAdd> mylist = [
    ThemeAdd(
        id: "1",
        themename: "Snowy ",
        themeImage: AssetImage("lib/assets/1.jpg")),
    ThemeAdd(
      id: "2",
      themename: "Rainy ",
      themeImage: AssetImage("lib/assets/2.jpg"),
    ),
    ThemeAdd(
      id: "3",
      themename: "Nature ",
      themeImage: AssetImage("lib/assets/3.jpg"),
    ),
    ThemeAdd(
      id: "4",
      themename: "Trees ",
      themeImage: AssetImage("lib/assets/4.jpg"),
    )
  ];
  int selectedIndex;
  _onSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  var isDone = false;

  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Visibility(
          visible: isDone == false ? true : false,
          child: FloatingActionButton(
            onPressed: () {
              if (selectedIndex == null) {
                showToast("Please pick a wallpaper first");
              } else {
                setState(() {
                  isDone = true;
                });
                searchService.addBackGroundToUser(
                    FirebaseAuth.instance.currentUser.uid,
                    mylist[selectedIndex].themeImage.toString());
              }
            },
            backgroundColor: Colors.teal[600],
            child: Icon(Icons.check),
          ),
        ),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Pick a wallpaper"),
        ),
        body: isDone
            ? Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserData(),
                            settings: RouteSettings()));
                  },
                  child: Lottie.network(
                      "https://assets3.lottiefiles.com/packages/lf20_uvPY2t.json",
                      repeat: false),
                ),
              )
            : ListView.builder(
                itemCount: mylist.length,
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      InkWell(
                        onTap: () {
                          _onSelected(index);
                        },
                        child: Container(
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: (mylist[index].themeImage))),
                        ),
                      ),
                      Container(
                        child: Container(
                            margin: EdgeInsets.all(5),
                            child: Text(
                              mylist[index].themename,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  letterSpacing: 1,
                                  fontWeight: FontWeight.w700),
                            )),
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        color: selectedIndex != null && selectedIndex == index
                            ? Colors.green.withOpacity(0.3)
                            : Colors.black45.withOpacity(0.2),
                      )
                    ],
                  );
                },
              ));
  }
}

class ThemeAdd {
  String id;
  String themename;
  AssetImage themeImage;
  ThemeAdd({this.themeImage, this.themename, this.id});
}

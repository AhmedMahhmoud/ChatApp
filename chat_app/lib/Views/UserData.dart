import 'dart:io';
import 'dart:async';
import 'package:chat_app/Views/search_screen.dart';
import 'package:chat_app/widgets/ProfileClipper.dart';
import 'package:chat_app/widgets/showToast.dart';
import 'package:chat_app/widgets/themelist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import "package:flutter/material.dart";
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import 'Home.dart';

class UserData extends StatefulWidget {
  @override
  _UserDataState createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  File myfile;
  PickedFile myPickedfile;

  var isImageLoading = false;
  var changeName = false;
  var isVisible = false;
  var isloading = false;

  String imageUrl = FirebaseAuth.instance.currentUser.photoURL;
  TextEditingController textEditingController = new TextEditingController();

  @override
  void initState() {
    changeName = false;

    isVisible = false;
    textEditingController.clear();
    // TODO: implement initState
    super.initState();
  }

  Future getImageFromPhone() async {
    myPickedfile = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      myfile = File(myPickedfile.path);
    });
  }

  Future getBackGroundImage() async {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser.uid).get();
  }

  Future<void> updateUserPicture() async {
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child("userImages")
        .child("${FirebaseAuth.instance.currentUser.email}.jpg");

    final StorageUploadTask task = ref.putFile(myfile);
    var imageurl = await (await task.onComplete).ref.getDownloadURL();

    FirebaseAuth.instance.currentUser
        .updateProfile(photoURL: imageurl)
        .then((value) {
          setState(() {
            imageUrl = imageurl;
            isImageLoading = false;
          });
        })
        .then((value) => searchService.addUserImage(
            FirebaseAuth.instance.currentUser.uid, imageurl))
        .catchError((onError) {
          print(onError);
          showToast("Error occured !");
        });
  }

  String userName = FirebaseAuth.instance.currentUser.displayName;
  String userMail = FirebaseAuth.instance.currentUser.email;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() {
          changeName = false;
        });
      },
      child: Scaffold(
        floatingActionButton: Visibility(
          visible: isVisible,
          child: FloatingActionButton(
            onPressed: () async {
              setState(() {
                isloading = true;
              });
              await FirebaseAuth.instance.currentUser
                  .updateProfile(
                    displayName: textEditingController.text,
                  )
                  .then((value) => showToast("Username updated successfully"))
                  .then((value) => searchService.updateUsername(
                      FirebaseAuth.instance.currentUser.uid,
                      textEditingController.text))
                  .catchError((onError) {
                showToast("Update failed..");
              });

              FocusScope.of(context).unfocus();
              setState(() {
                isloading = false;
                changeName = false;
                isVisible = false;
              });
            },
            child: isloading ? CircularProgressIndicator() : Icon(Icons.save),
            backgroundColor: Color(0xff101D25),
          ),
        ),
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Profile"),
        ),
        body: Stack(
          children: [
            Container(),
            ClipPath(
              clipper: MyCustomClipper(),
              child: FutureBuilder(
                  future: searchService.getUserByEmail(userMail),
                  builder: (context, snapshot) {
                    String backgroundImage =
                        snapshot.data.docs[0].data()['backgroundImage'];

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasData && snapshot.data.docs.length > 0) {
                      return Container(
                        height: MediaQuery.of(context).size.height / 2.6,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage(
                              backgroundImage.substring(
                                  32, backgroundImage.length - 2),
                            ),
                          ),
                        ),
                      );
                    }

                    return Container();
                  }),
            ),
            SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: isImageLoading
                        ? Center(
                            child: Container(
                            width: MediaQuery.of(context).size.width / 1.9,
                            height: MediaQuery.of(context).size.height / 1.9,
                            child: Lottie.network(
                                "https://assets10.lottiefiles.com/packages/lf20_YrS71w.json"),
                          ))
                        : Container(
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.12),
                            width: MediaQuery.of(context).size.width / 2.4,
                            height: MediaQuery.of(context).size.height / 3.9,
                            child: imageUrl != null
                                ? CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(
                                      imageUrl,
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.white,
                                    backgroundImage: NetworkImage(
                                      "https://cdn.iconscout.com/icon/free/png-512/flutter-2038877-1720090.png",
                                    ),
                                  )),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 6.3,
                    child: Card(
                      color: Colors.white,
                      shadowColor: Colors.blue[600],
                      elevation: 10,
                      margin: EdgeInsets.all(20),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 30,
                              color: Color(0xff101D25),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(left: 10),
                                child: TextField(
                                  onChanged: (value) {
                                    print(value);
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        isVisible = true;
                                      });
                                    }
                                    if (value.isEmpty) {
                                      setState(() {
                                        isVisible = false;
                                      });
                                    }
                                  },
                                  controller: textEditingController,
                                  enabled: changeName,
                                  decoration: InputDecoration(
                                      hintText: userName,
                                      hintStyle: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 1,
                                        color: Color(0xff101D25),
                                      )),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                setState(() {
                                  changeName = true;
                                });
                              },
                              color: Color(0xff101D25),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height / 6.3,
                    child: Card(
                      color: Colors.white,
                      shadowColor: Colors.blue[600],
                      elevation: 10,
                      margin: EdgeInsets.all(20),
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email,
                              size: 30,
                              color: Color(0xff101D25),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              userMail,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1,
                                color: Color(0xff101D25),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        spreadRadius: 2,
                        blurRadius: 5,
                        color: Colors.black,
                      )
                    ], shape: BoxShape.circle, color: Color(0xff101D25)),
                    child: IconButton(
                      icon: Icon(
                        Icons.home,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Home(),
                            ));
                      },
                    ),
                  )
                ],
              ),
            ),
            Positioned(
                bottom: MediaQuery.of(context).size.height / 2.1,
                child: IconButton(
                  tooltip: "Add theme",
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThemeExambles(),
                        ));
                  },
                  icon: Icon(
                    Icons.color_lens,
                    size: 30,
                    color: Colors.white,
                  ),
                )),
            Positioned(
              bottom: MediaQuery.of(context).size.height * 0.5,
              right: MediaQuery.of(context).size.height / 4.9,
              child: CircleAvatar(
                backgroundColor: Color(0xff101D25),
                child: IconButton(
                  color: Color(0xff101D25),
                  icon: Center(
                      child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  )),
                  onPressed: () async {
                    setState(() {
                      isImageLoading = true;
                    });
                    await getImageFromPhone();
                    updateUserPicture();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Stack(
//                 children: [

//                   Positioned(
//                     right: MediaQuery.of(context).size.width * 0.3,
//                     bottom: MediaQuery.of(context).size.width * 0.0,
//                     child: CircleAvatar(
//                       backgroundColor: Colors.teal[700],
//                       child: IconButton(
//                         highlightColor: Colors.teal,
//                         color: Colors.teal,
//                         icon: Center(
//                             child: Icon(
//                           Icons.camera_alt,
//                           color: Colors.white,
//                         )),
//                         onPressed: () {},
//                       ),
//                     ),
//                   )
//                 ],
//               ),

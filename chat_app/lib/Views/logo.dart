import 'dart:io';

import 'package:chat_app/Views/Home.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../widgets/clipper.dart';

class HomeLogo extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeLogo> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final formkey = GlobalKey<FormState>();
  Map<String, String> _authmap = {
    'email': "",
    'password': "",
    'name': "",
  };
  void showErrorDiaglog(String title, String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: [
                FlatButton(
                  child: Text('Okay'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  final _auth = FirebaseAuth.instance;
  String _email;
  String _password;
  String _displayName;
  bool _obsecure = false;
  var isloading = false;
  @override
  @override
  Future signUp() async {
    try {
      final UserCredential user = await _auth
          .createUserWithEmailAndPassword(
              email: _authmap['email'].trim(),
              password: _authmap['password'].trim())
          .catchError((e) {
        if (e.toString().contains("already in use by another account"))
          showErrorDiaglog(
              "Register Failed", "The email address is already in use");
        else
          showErrorDiaglog(
              "Register Failed", "Something went wrong please try again later");
      });
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.user.uid)
          .set({
        "username": _authmap['name'].trim(),
        "email": _authmap['email'].trim(),
      });
    } catch (e) {
      print(e);
    }
    _auth.currentUser
        .updateProfile(displayName: _authmap['name'].trim())
        .then((value) => showErrorDiaglog(
            "Congratulations", "Account is created successfully !"))
        .catchError((e) {
      print(e);
    });
  }

  void saveForm(String screen) async {
    print(screen);
    if (!formkey.currentState.validate()) {
      return;
    }

    if (screen == "REGISTER") {
      formkey.currentState.save();

      try {
        signUp();
      } catch (e) {
        throw e;
      }

      // await widget.auth.SignUp(_authmap['email'], _authmap['password']);
    } else if (screen == "LOGIN") {
      formkey.currentState.save();
      try {
        final UserCredential user = await _auth.signInWithEmailAndPassword(
            email: _authmap['email'].trim(),
            password: _authmap['password'].trim());

        if (user != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Home(),
              ));
        } else {
          showErrorDiaglog("Error occured", "Failed to login");
        }
      } catch (error) {
        const errorMessage =
            'Could not authenticate you. Please try again later.';
        return showErrorDiaglog("Error occured", errorMessage);
      }

      // await widget.auth.SignIn(_authmap['email'], _authmap['password']);
    }
  }

  Widget build(BuildContext context) {
    Color primary = Theme.of(context).primaryColor;
    void initState() {
      super.initState();
    }

    //GO logo widget
    Widget logo() {
      return Padding(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.040),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 220,
          child: Stack(
            children: <Widget>[
              Positioned(
                  child: Container(
                child: Align(
                  child: Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: Colors.white),
                    width: 150,
                    height: 150,
                  ),
                ),
                height: 154,
              )),
              Positioned(
                child: Container(
                    height: 154,
                    child: Align(
                      child: Text(
                        "CHAT",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )),
              ),
              Positioned(
                child: Container(
                    height: 400,
                    child: Align(
                      child: Text(
                        "APP",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          fontStyle: FontStyle.italic,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    )),
              ),
              Positioned(
                width: MediaQuery.of(context).size.width * 0.15,
                height: MediaQuery.of(context).size.width * 0.15,
                bottom: MediaQuery.of(context).size.height * 0.046,
                right: MediaQuery.of(context).size.width * 0.22,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                ),
              ),
              Positioned(
                width: MediaQuery.of(context).size.width * 0.08,
                height: MediaQuery.of(context).size.width * 0.08,
                bottom: 0,
                right: MediaQuery.of(context).size.width * 0.32,
                child: Container(
                  decoration: BoxDecoration(
                      shape: BoxShape.circle, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    //input widget
    Widget _input(Icon icon, String hint, bool obsecure) {
      return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        child: TextFormField(
          onSaved: (newValue) {
            if (hint == "EMAIL") {
              _authmap['email'] = newValue.trim();
            } else if (hint == "PASSWORD") {
              _authmap['password'] = newValue.trim();
            } else if (hint == "DISPLAY NAME") {
              _authmap["name"] = newValue.trim();
            }
          },
          validator: (value) {
            if (hint == "EMAIL") {
              if (!value.contains("@") || !value.contains(".com")) {
                return "Pleaser insert a valid Email !";
              }
              if (value.isEmpty) {
                return "Please enter an Email !";
              }
            } else if (hint == "PASSWORD") {
              if (value.isEmpty) {
                return "Password is required ";
              }
              if (value.length < 4) {
                return "Password is too short ";
              }
            } else {
              if (value.isEmpty) {
                return "Enter a username";
              }
            }
          },
          obscureText: obsecure,
          style: TextStyle(
            fontSize: 15,
            fontFamily: "Montserrat",
          ),
          decoration: InputDecoration(
              hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.black54),
              hintText: hint,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 3,
                ),
              ),
              prefixIcon: Padding(
                child: IconTheme(
                  data: IconThemeData(color: Colors.teal),
                  child: icon,
                ),
                padding: EdgeInsets.only(left: 30, right: 10),
              )),
        ),
      );
    }

    //button widget
    Widget _button(String text, Color splashColor, Color highlightColor,
        Color fillColor, Color textColor, void function()) {
      return RaisedButton(
        highlightElevation: 0.0,
        splashColor: splashColor,
        highlightColor: highlightColor,
        elevation: 0.0,
        color: fillColor,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(20.0)),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: textColor, fontSize: 20),
        ),
        onPressed: () {
          function();
        },
      );
    }

    //login and register fuctions

    void _loginSheet() {
      _scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Colors.teal),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Form(
              key: formkey,
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.close,
                            size: 40.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: CircleAvatar(
                                backgroundColor: Colors.teal,
                                radius: 70,
                                child: Text(
                                  "L",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 20, top: 60),
                              child: _input(
                                  Icon(
                                    Icons.email,
                                    size: 25,
                                  ),
                                  "EMAIL",
                                  // _emailController,
                                  false),
                            ),
                            Padding(
                              padding: EdgeInsets.only(bottom: 20),
                              child: _input(
                                  Icon(
                                    Icons.lock,
                                    size: 25,
                                  ),
                                  "PASSWORD",
                                  true),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: isloading
                                  ? Center(
                                      child: CircularProgressIndicator(
                                        backgroundColor: Colors.red,
                                      ),
                                    )
                                  : Container(
                                      child: _button("LOGIN", Colors.white,
                                          primary, primary, Colors.white, () {
                                        saveForm("LOGIN");
                                      }),
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                height: MediaQuery.of(context).size.height / 1.1,
                color: Colors.white,
              ),
            ),
          ),
        );
      });
    }

    void _registerSheet() {
      _scaffoldKey.currentState.showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Form(
              key: formkey,
              child: Container(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.close,
                            size: 40.0,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        height: 50,
                        width: 50,
                      ),
                      SingleChildScrollView(
                        child: Column(children: <Widget>[
                          Center(
                            child: CircleAvatar(
                              backgroundColor: Colors.teal,
                              radius: 70,
                              child: Text(
                                "R",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 20,
                              top: 60,
                            ),
                            child: _input(Icon(Icons.account_circle),
                                "DISPLAY NAME", false),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: 20,
                            ),
                            child: _input(Icon(Icons.email), "EMAIL", false),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: _input(Icon(Icons.lock), "PASSWORD", true),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom),
                            child: Container(
                              child: _button("REGISTER", Colors.white, primary,
                                  primary, Colors.white, () {
                                saveForm("REGISTER");
                              }),
                              height: 50,
                              width: MediaQuery.of(context).size.width,
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ]),
                      ),
                    ],
                  ),
                ),
                height: MediaQuery.of(context).size.height / 1.1,
                color: Colors.white,
              ),
            ),
          ),
        );
      });
    }

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.teal[700],
        body: Container(
          child: Column(
            children: <Widget>[
              logo(),
              Padding(
                child: Container(
                  child: _button("LOGIN", primary, Colors.white, Colors.white,
                      primary, _loginSheet),
                  height: 50,
                ),
                padding: EdgeInsets.only(top: 80, left: 20, right: 20),
              ),
              Padding(
                child: Container(
                  child: OutlineButton(
                    highlightedBorderColor: Colors.white,
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                    splashColor: Colors.white,
                    color: Colors.teal[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(30.0),
                    ),
                    child: Text(
                      "REGISTER",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20),
                    ),
                    onPressed: () {
                      _registerSheet();
                    },
                  ),
                  height: 50,
                ),
                padding: EdgeInsets.only(top: 10, left: 20, right: 20),
              ),
              Expanded(
                child: Align(
                  child: ClipPath(
                    child: Container(
                      color: Colors.white,
                      height: 300,
                    ),
                    clipper: BottomWaveClipper(),
                  ),
                  alignment: Alignment.bottomCenter,
                ),
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.stretch,
          ),
        ));
  }
}

import 'package:chat_app/Views/UserData.dart';
import 'package:chat_app/Views/search_screen.dart';
import 'package:chat_app/service/FirestoreSearch.dart';
import 'package:chat_app/widgets/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Home extends StatefulWidget {
  @override
  _UserDataState createState() => _UserDataState();
}

class _UserDataState extends State<Home> with SingleTickerProviderStateMixin {
  SearchService searchService = new SearchService();
  bool isCollapsed = true;

  double screenWidth, screenHeight;
  final Duration duration = const Duration(milliseconds: 300);
  AnimationController _controller;
  Animation<double> _scaleAnimation;
  Animation<double> _menuScaleAnimation;
  Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: duration);
    _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(_controller);
    _menuScaleAnimation =
        Tween<double>(begin: 0.5, end: 1).animate(_controller);
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String getUserImage(String image) {
      String tempImage = image;
      return tempImage;
    }

    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal[700],
        onPressed: () {
          setState(() {
            if (isCollapsed)
              _controller.forward();
            else
              _controller.reverse();

            isCollapsed = !isCollapsed;
          });
        },
        child: Icon(
          Icons.menu,
        ),
      ),
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            setState(() {
              if (isCollapsed)
                _controller.forward();
              else
                _controller.reverse();

              isCollapsed = !isCollapsed;
            });
          },
          child: Row(
            children: [
              Text("Chat app"),
              SizedBox(
                width: 4,
              ),
              Icon(Icons.chat),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              items: [
                DropdownMenuItem(
                    value: "Logout",
                    child: Container(
                      child: Row(
                        children: [
                          Icon(Icons.exit_to_app),
                          SizedBox(
                            width: 8,
                          ),
                          Text("Logout")
                        ],
                      ),
                    ))
              ],
              onChanged: (value) {
                if (value == "Logout") {
                  FirebaseAuth.instance.signOut();
                }
              },
            ),
          )
        ],
      ),
      backgroundColor: Color(0xff101D25),
      body: Stack(
        children: [menu(context), dashboard(context)],
      ),
    );
  }

  Widget dashboard(context) {
    return AnimatedPositioned(
      duration: duration,
      top: 0,
      bottom: 0,
      left: isCollapsed ? 0 : 0.6 * screenWidth,
      right: isCollapsed ? 0 : -0.2 * screenWidth,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          animationDuration: duration,
          elevation: 8,
          color: Color(0xff101D25),
          child: StreamBuilder(
            stream: searchService
                .getRecentChats(FirebaseAuth.instance.currentUser.email),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (context, index) {
                    return RecentChatsTile(
                        snapshot.data.docs[index].data()['chatroomid'],
                        searchService);
                  },
                );
              }
              return Container();
            },
          ),
        ),
      ),
    );
  }

////MENUU/////////
  Widget menu(context) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _menuScaleAnimation,
        child: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 200,
                  height: 200,
                  child: Lottie.network(
                      "https://assets2.lottiefiles.com/packages/lf20_SLZG2B.json"),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserData(),
                        ));
                  },
                  child: Text("Update Profile",
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(),
                        ));
                  },
                  child: Text("Search",
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    print(FirebaseAuth.instance.currentUser.photoURL);
                  },
                  child: Text("Chat Anonymously ",
                      style: TextStyle(color: Colors.white, fontSize: 22)),
                ),
                SizedBox(height: 10),
                Text("Log Out",
                    style: TextStyle(color: Colors.white, fontSize: 22)),
                SizedBox(height: 10),
                // Text("Branches",
                //     style: TextStyle(color: Colors.white, fontSize: 22)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecentChatsTile extends StatelessWidget {
  String recentPerson;

  SearchService searchService;
  RecentChatsTile(this.recentPerson, this.searchService);

  @override
  Widget build(BuildContext context) {
    String temp =
        recentPerson.replaceAll(FirebaseAuth.instance.currentUser.email, "");
    String finalString = temp.replaceAll("_", "");

    return FutureBuilder(
      future: searchService.getUserByEmail(finalString),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Lottie.asset("lib/assets/29311-chat-loader.json"),
          ));
        }

        if (snapshot.hasData && snapshot.data.docs.length > 0) {
          return GestureDetector(
            onTap: () {
              final String firstemail = FirebaseAuth.instance.currentUser.email;

              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                        roomiD: getchatID(firstemail, finalString),
                        chatername: snapshot.data.docs[0].data()['username'],
                        chaterImage: snapshot.data.docs[0].data()['userImage']),
                  ));
            },
            child: Container(
              padding: EdgeInsets.only(left: 10, top: 10),
              child: Column(
                children: [
                  Row(
                    
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 5,
                        height: MediaQuery.of(context).size.height / 12,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                snapshot.data.docs[0].data()['userImage'] !=
                                        null
                                    ? snapshot.data.docs[0]
                                        .data()['userImage']
                                    : "https://cdn.iconscout.com/icon/free/png-512/flutter-2038877-1720090.png",
                              ),
                            )),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data.docs[0].data()['username'],
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontStyle: FontStyle.italic),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          StreamBuilder<QuerySnapshot>(
                            builder: (context, snapshot) {
                              if (snapshot.hasData &&
                                  snapshot.data.docs.length > 0) {
                                return (Text(
                                  snapshot.data
                                      .docs[snapshot.data.docs.length - 1]
                                      .data()['message'],
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white.withOpacity(0.4)),
                                ));
                              }
                              return Text(
                                "No chats here yet, Say hi .",
                                style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.white.withOpacity(0.4)),
                              );
                            },
                            stream: searchService.getlast(getchatID(
                                FirebaseAuth.instance.currentUser.email,
                                finalString)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: MediaQuery.of(context).size.width / 1.2,
                    child: Divider(
                      height: 3,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  )
                ],
              ),
            ),
          );
        }

        return Text("");
      },
    );
  }
}

getchatID(String firstUser, String secondUser) {
  if (firstUser.substring(0, 1).codeUnitAt(0) >
      secondUser.substring(0, 1).codeUnitAt(0)) {
    return "$secondUser\_$firstUser";
  } else {
    return "$firstUser\_$secondUser";
  }
}

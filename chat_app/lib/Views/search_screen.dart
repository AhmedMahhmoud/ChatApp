import 'package:chat_app/service/FirestoreSearch.dart';
import 'package:chat_app/widgets/chatscreen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'Home.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

SearchService searchService = new SearchService();
TextEditingController searchEditingController = TextEditingController();
startConversation(String email) {
  List<String> users = [email, FirebaseAuth.instance.currentUser.email];
  Map<String, dynamic> chatRoomMap = {
    "users": users,
    "chatroomid": getchatID(email, FirebaseAuth.instance.currentUser.email),
    "timestamp": DateTime.now().toString()
  };
  searchService.creatChatRoom(
      getchatID(FirebaseAuth.instance.currentUser.email, email), chatRoomMap);
}

getchatID(String firstUser, String secondUser) {
  if (firstUser.substring(0, 1).codeUnitAt(0) >
      secondUser.substring(0, 1).codeUnitAt(0)) {
    return "$secondUser\_$firstUser";
  } else {
    return "$firstUser\_$secondUser";
  }
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    searchEditingController.clear();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.tealAccent[700], Colors.teal],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
              borderRadius: BorderRadius.circular(30)),
          child: FloatingActionButton(
            backgroundColor: Colors.teal,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ));
            },
            child: Icon(Icons.arrow_back_ios),
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        appBar: AppBar(
          actions: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: TextField(
                          controller: searchEditingController,
                          autofocus: true,
                          style: TextStyle(
                              fontSize: 17,
                              color: Colors.white,
                              letterSpacing: 1),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                  color: Colors.white,
                                  letterSpacing: 2,
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic),
                              hintText: "Search by username")),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 5,
                    ),
                    child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xff7A797B),
                        child: Lottie.network(
                          "https://assets9.lottiefiles.com/private_files/lf30_qYOC8H.json",
                        )),
                  )
                ],
              ),
            )
          ],
        ),
        body: FutureBuilder(
          future: searchService.getUserByUserName(searchEditingController.text),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Container(
                  height: 300,
                  width: 300,
                  child: Lottie.network(
                    "https://assets3.lottiefiles.com/packages/lf20_Stt1R6.json",
                  ),
                ),
              );
            } else {
              if (snapshot != null && searchEditingController.text.isNotEmpty)
               
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return SearchTile(
                    username: snapshot.data.docs[index].data()['username'],
                    emaill: snapshot.data.docs[index].data()['email'],
                    userImage: snapshot.data.docs[index].data()['userImage'],
                  );
                },
              );
            }
            return Container();
          },
        ));
  }
}

class SearchTile extends StatelessWidget {
  final String username, emaill, userImage;
  SearchTile({this.username, this.emaill, this.userImage});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 6,
            height: MediaQuery.of(context).size.height / 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: NetworkImage(userImage != null
                    ? userImage
                    : "https://pickaface.net/gallery/avatar/20151205_194059_2696_Chat.png"),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                username,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic,
                    color: Colors.white),
              ),
              SizedBox(
                height: 4,
              ),
              Text(
                emaill,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontStyle: FontStyle.italic),
              )
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: () async {
              await startConversation(emaill);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      roomiD: getchatID(
                        FirebaseAuth.instance.currentUser.email,emaill ),
                      chatername: username,
                      chaterImage: userImage,
                    ),
                  ));
            },
            child: Container(
              height: 40,
              width: 100,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Colors.tealAccent[700], Colors.teal],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter),
                  borderRadius: BorderRadius.circular(20)),
              child: Center(
                child: Text(
                  "Message",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

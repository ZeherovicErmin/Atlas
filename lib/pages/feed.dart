import 'package:atlas/components/feed_post.dart';
import 'package:atlas/components/productHouser.dart';
import 'package:atlas/helper/helper_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Feed extends ConsumerWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final textController = TextEditingController();
    final usersCollection = FirebaseFirestore.instance.collection("Users");

    void postMessage() {
      //only post if there is something in the textfield
      if (textController.text.isNotEmpty) {
        FirebaseFirestore.instance.collection("User Posts").add({
          'UserEmail': currentUser.email,
          'Message': textController.text,
          'TimeStamp': Timestamp.now(),
          'Likes': [],
        });
      }

      //clear the textfield
      textController.clear();
    }

    //Gets the user's username
    Stream<String> fetchUsername({String? email}) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        return FirebaseFirestore.instance
            .collection("Users")
            .doc(email)
            .snapshots()
            .map((snapshot) {
          final userData = snapshot.data() as Map<String, dynamic>;
          return userData['username']?.toString() ?? '';
        });
      }
      return Stream.value('');
    }

    /*
    //Holds the opposite theme color for the text
    final themeColor = lightDarkTheme ? Colors.white : Colors.black;
    final themeColor2 = lightDarkTheme ? Color.fromARGB(255, 18, 18, 18) : Colors.white;
    */

    return Scaffold(
      backgroundColor: const Color.fromARGB(
          255, 232, 229, 229), //Home page for when a user logs in
      appBar: AppBar(
        title: const Center(
          child: Text(
            "F e e d",
            style:
                TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 136, 204),
      ),

      body: Center(
        child: Column(
          children: [
            //The Feed
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection("User Posts")
                    .orderBy("TimeStamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          //get the message
                          final post = snapshot.data!.docs[index];
                          return StreamBuilder<String>(
                            stream: fetchUsername(email: post['UserEmail']),
                            builder: (context, usernameSnapshot) {
                              if (usernameSnapshot.hasData) {
                                return FeedPost(
                                  message: post['Message'],
                                  user: usernameSnapshot.data!,
                                  postId: post.id,
                                  likes: List<String>.from(post['Likes'] ?? []),
                                  time: formatDate(post['TimeStamp']),
                                  email: post['UserEmail'],
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error:${snapshot.error}'),
                                );
                              }

                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          );
                        });
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error:${snapshot.error}'),
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),

            //post message
            Container(
              padding: const EdgeInsets.all(15.0),
              margin: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                borderRadius: BorderRadius.circular(8), // Rounded corners
              ),
              child: Row(
                children: [
                  //textfield
                  Expanded(
                      child: TextField(
                    maxLength: 150,
                    controller: textController,
                    decoration:
                        const InputDecoration(hintText: "Share your progress!"),
                    obscureText: false,
                  )),
                  //post button
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(
                      Icons.arrow_circle_up,
                      color: Color.fromARGB(255, 0, 136, 204),
                    ),
                  )
                ],
              ),
            ),

            StreamBuilder<String>(
                stream: fetchUsername(email: currentUser.email),
                builder: (context, usernameSnapshot) {
                  if (usernameSnapshot.hasData) {
                    return Text(
                      "Logged in as ${usernameSnapshot.data.toString().trim()}",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 0, 136, 204),
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}

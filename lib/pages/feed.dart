import 'package:atlas/components/feed_post.dart';
import 'package:atlas/helper/helper_method.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Feed extends ConsumerWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final textController = TextEditingController();

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

    /*
    //Holds the opposite theme color for the text
    final themeColor = lightDarkTheme ? Colors.white : Colors.black;
    final themeColor2 =
        lightDarkTheme ? Color.fromARGB(255, 18, 18, 18) : Colors.white;

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
                    .collection("BarPosts")
                    .orderBy(
                      "TimeStamp",
                      descending: false,
                    )
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        //get the message
                        final post = snapshot.data!.docs[index];
                        return FeedPost(
                          message: post['Message'],
                          user: post['UserEmail'],
                          postId: post.id,
                          //barcodeData: post['barcodeData'],
                          likes: List<String>.from(post['Likes'] ?? []),
                          time: formatDate(post['TimeStamp']),
                        );
                      },
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

            //logged in as
            Text(
              "Logged in as ${currentUser.email!}",
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 136, 204),
              ),
            ),

            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}

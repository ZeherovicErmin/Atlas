//Atlas Fitness App CSC 4996
import 'package:atlas/components/feed_post.dart';
import 'package:atlas/components/my_textfield.dart';
import 'package:atlas/main.dart';
import 'package:atlas/pages/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class FitCenter extends ConsumerWidget {
  const FitCenter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final usersCollection = FirebaseFirestore.instance.collection("Users");
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 90, 117, 255),
            Color.fromARGB(255, 161, 195, 250),
          ],
        ),
      ),
      child: DefaultTabController(
        initialIndex: 1,
        length: 4,
        child: Scaffold(
          //Home page for when a user logs in
          appBar: AppBar(
            title: const Text(
              "F i t n e s s C e n t e r",
              style: TextStyle(
                  fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color.fromARGB(255, 38, 97, 185),
            bottom: const TabBar(
              tabs: [
                Tab(text: "Discover"),
                Tab(text: "My Workouts"),
                Tab(text: "Progress"),
                Tab(text: "Feed"),
              ],
            ),
          ),

          body: TabBarView(
            children: [
              const Center(
                // Content for the Discover Page
                child: Text("Tab 1"),
              ),
              const Center(
                child: Text("Tab 2"),
              ),
              const Center(
                child: Text("Tab 3"),
              ),
              //ADDED USER POSTS TO THIS PAGE FOR TESTING
              Column(
                children: [
                  //The Feed
                  Expanded(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection("User Posts")
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
                                likes: List<String>.from(post['Likes'] ?? []),
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
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: Row(
                      children: [
                        //textfield
                        Expanded(
                            child: MyTextField(
                          controller: textController,
                          hintText: "Share your progress!",
                          obscureText: false,
                        )),
                        //post button
                        IconButton(
                          onPressed: postMessage,
                          icon: const Icon(Icons.arrow_circle_up),
                        )
                      ],
                    ),
                  ),

                  //logged in as
                  Text(
                    "Logged in as ${currentUser.email!}",
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(
                    height: 50,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

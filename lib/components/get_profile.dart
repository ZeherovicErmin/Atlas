import 'package:atlas/components/feed_post.dart';
import 'package:atlas/components/text_box.dart';
import 'package:atlas/components/text_box2.dart';
import 'package:atlas/helper/time_stamp.dart';
import 'package:atlas/pages/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class GetProfile extends StatelessWidget {
  final String username;
  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 1));
  }

  const GetProfile({Key? key, required this.username}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Recieved username: $username');
    final currentUser = FirebaseAuth.instance.currentUser!;
    final usersCollection = FirebaseFirestore.instance.collection("Users");

    PreferredSize userProfileAppBar(BuildContext context, String title) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 0, 136, 204),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ],
          title: Text(
            title,
            style: const TextStyle(
                fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    Future<void> editField(String field) async {
      TextEditingController username = TextEditingController();

      String? newValue = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black,
          title: Text(
            "Edit $field",
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: username,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: const TextStyle(color: Colors.white),
            ),
          ),
          actions: [
            // Cancel button
            TextButton(
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),

            // Save button
            TextButton(
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () => Navigator.of(context).pop(username.text),
            ),
          ],
        ),
      );

      // Update in Firestore
      if (newValue != null && newValue.trim().isNotEmpty) {
        // Only update if there is something in the text field
        await usersCollection.doc(currentUser.email).update({field: newValue});
      }
    }

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

    return Scaffold(
      //backgroundColor: themeColor2,
      appBar: userProfileAppBar(context, 'User Profile: $username'),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .where("username", isEqualTo: username)
            .snapshots(),
        builder: (context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Return a widget for loading state
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Text(
                'User data not found for username: $username.'); // Return a widget when no data is found
          }

          final userData = snapshot.data!.docs.first.data();
          // ignore: unnecessary_null_comparison
          if (userData != null) {
            //starts the user profile page
            return LiquidPullToRefresh(
              onRefresh: _handleRefresh,
              height: 100,
              backgroundColor: Colors.deepPurple[200],
              showChildOpacityTransition: false,
              animSpeedFactor: 1,
              child: ListView(
                children: [
                  const SizedBox(height: 50),

                  //Profile Picture
                  Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(username)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return const Icon(
                                  color: Colors.white,
                                  CupertinoIcons.profile_circled,
                                  size: 72);
                            }
                            final userData =
                                snapshot.data!.data() as Map<String, dynamic>?;
                            final profilePicUrl =
                                userData?['profilePicture'] as String?;
                            return CircleAvatar(
                              radius: 64,
                              backgroundImage: profilePicUrl != null
                                  ? NetworkImage(profilePicUrl)
                                  : null,
                              child: profilePicUrl == null
                                  ? const Icon(CupertinoIcons.profile_circled,
                                      size: 72)
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  //Username
                  StreamBuilder<String>(
                    stream: fetchUsername(email: currentUser.email),
                    builder: (context, usernameSnapshot) {
                      if (usernameSnapshot.hasData) {
                        return Text(
                          usernameSnapshot.data.toString().trim(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // User details
                  ExpansionTile(
                    title: const Text(
                      'My Details',
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    collapsedIconColor: Colors.blue,
                    iconColor: Colors.white,
                    children: [
                      // Username
                      MyTextBox2(
                        text: userData['username']?.toString() ?? '',
                        sectionName: 'Username',
                      ),

                      // Bio
                      MyTextBox2(
                        text: userData['bio']?.toString() ?? '',
                        sectionName: 'Bio',
                      ),
                    ],
                  ),

                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: const Text(
                            'My Posts',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          collapsedIconColor: Colors.blue,
                          iconColor: Colors.white,
                          children: [
                            FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection("Users")
                                  .where('username', isEqualTo: username)
                                  .limit(1)
                                  .get()
                                  .then((snapshot) {
                                if (snapshot.docs.isNotEmpty) {
                                  return snapshot.docs.first;
                                } else {
                                  throw Exception('User not found');
                                }
                              }),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }

                                if (snapshot.hasError) {
                                  return Center(
                                    child: Text('Error: ${snapshot.error}'),
                                  );
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return const Center(
                                    child: Text('User not found.'),
                                  );
                                }

                                final userDoc = snapshot.data!;
                                final userEmail = userDoc['UserEmail'];

                                return FutureBuilder<QuerySnapshot>(
                                  future: FirebaseFirestore.instance
                                      .collection("User Posts")
                                      .where('UserEmail', isEqualTo: userEmail)
                                      .get(),
                                  builder: (context, postsSnapshot) {
                                    if (postsSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }

                                    if (postsSnapshot.hasError) {
                                      return Center(
                                        child: Text(
                                            'Error: ${postsSnapshot.error}'),
                                      );
                                    }

                                    final postsDocs = postsSnapshot.data!.docs;

                                    if (postsDocs.isEmpty) {
                                      return const Center(
                                        child: Text('No posts found.'),
                                      );
                                    }

                                    return SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.6,
                                      child: ListView.builder(
                                        itemCount: postsDocs.length,
                                        itemBuilder: (context, index) {
                                          final post = postsDocs[index];
                                          final barcodeDataDynamic =
                                              post['barcodeData'];
                                          Map<String, dynamic> barcodeDataMap =
                                              barcodeDataDynamic
                                                  as Map<String, dynamic>;
                                          if (barcodeDataMap.isNotEmpty) {
                                            barcodeDataMap = barcodeDataDynamic;
                                          } else {
                                            print(
                                                'Unexpected type for barcodeData: ${barcodeDataDynamic.runtimeType}');
                                          }
                                          return StreamBuilder<String>(
                                            stream: fetchUsername(
                                              email: post['UserEmail'],
                                            ),
                                            builder:
                                                (context, usernameSnapshot) {
                                              if (usernameSnapshot.hasData) {
                                                return FeedPost(
                                                  message: post['Message'],
                                                  user: usernameSnapshot.data!,
                                                  postId: post.id,
                                                  barcodeData: barcodeDataMap,
                                                  likes: List<String>.from(
                                                      post['Likes'] ?? []),
                                                  time: formatDate(
                                                      post['TimeStamp']),
                                                  email: post['UserEmail'],
                                                  exerciseName:
                                                      post['ExerciseName'] ??
                                                          '',
                                                  exerciseType:
                                                      post['ExerciseType'] ??
                                                          '',
                                                  muscle:
                                                      post['ExerciseMuscle'] ??
                                                          '',
                                                  equipment: post[
                                                          'ExerciseEquipment'] ??
                                                      '',
                                                  difficulty: post[
                                                          'ExerciseDifficulty'] ??
                                                      '',
                                                  instructions: post[
                                                          'ExerciseInstructions'] ??
                                                      '',
                                                  imageUrl: post['postImage'],
                                                );
                                              } else if (snapshot.hasError) {
                                                return Center(
                                                  child: Text(
                                                      'Error:${snapshot.error}'),
                                                );
                                              }

                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            // Handle the case where userData is null
            return const Center(
              child: Text('User data is null.'),
            );
          }
        },
      ),
    );
  }
}

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

    Stream<String> fetchUsername({String? email}) {
      if (email != null && email.isNotEmpty) {
        return FirebaseFirestore.instance
            .collection("Users")
            .doc(email)
            .snapshots()
            .map((snapshot) {
          final userData = snapshot.data() as Map<String, dynamic>?;
          return userData?['username']?.toString() ?? 'Unknown Username';
        });
      }
      return Stream.value('Unknown Username');
    }

    return Scaffold(
      //backgroundColor: themeColor2,
      appBar: userProfileAppBar(context, ''),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(username)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Loading state
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Error handling
          }

          // if (!snapshot.hasData || snapshot.data?.data() == null) {
          //   return const Text('User data not found for username: $username');
          // }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          if (userData == null) {
            return const Center(child: Text('User data is null.'));
          }

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
                    stream: fetchUsername(email: username),
                    builder: (context, usernameSnapshot) {
                      if (usernameSnapshot.hasData &&
                          usernameSnapshot.data!.isNotEmpty) {
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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(
                            left: 26.0), // Adjust the padding as needed
                        child: Text(
                          'My Details',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight:
                                  FontWeight.bold, // Makes the text bold
                              fontSize: 18),
                        ),
                      ),

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

                      const SizedBox(height: 10),
                    ],
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

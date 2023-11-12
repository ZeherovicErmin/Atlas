import 'dart:typed_data';

import 'package:atlas/components/feed_post.dart';
import 'package:atlas/components/text_box.dart';
import 'package:atlas/helper/time_stamp.dart';
import 'package:atlas/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atlas/main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:atlas/pages/settings_page.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import 'package:loading_animation_widget/loading_animation_widget.dart';
//import 'image'

// Riverpod Provider
final profilePictureProvider = StateProvider<Uint8List?>((ref) => null);

final profilePictureUrlProvider = FutureProvider<String?>((ref) async {
  try {
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    return doc['profilePicture'] as String?;
  } catch (e) {
    print('Error $e');
    return null;
  }
});

class UserProfile extends ConsumerWidget {
  const UserProfile({Key? key}) : super(key: key);

  Future<void> _handleRefresh() async {
    return await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final usersCollection = FirebaseFirestore.instance.collection("Users");
    final currentIndex = ref.watch(selectedIndexProvider);
    final image = ref.watch(profilePictureProvider.notifier);
    final profilePictureUrl = ref.watch(profilePictureUrlProvider);
    //Saves the state of dark mode being on or off
    final lightDarkTheme = ref.watch(themeProvider);

    //Holds the opposite theme color for the text
    final themeColor = lightDarkTheme ? Colors.white : Colors.black;
    final themeColor2 =
        lightDarkTheme ? Color.fromARGB(255, 18, 18, 18) : Colors.white;

    void saveProfile(Uint8List imageBytes) async {
      //holds the Uint8List of pfp provider
      //final imageBytes = ref.watch(profilePictureProvider.notifier).state;

      try {
        //initializing storing a picture to database
        final FirebaseStorage storage = FirebaseStorage.instance;
        // Stores filename in db
        final String fileName =
            "${FirebaseAuth.instance.currentUser!.email}_profilePicture.jpg";
        print('test');
        // uploads image of imageBytes to firebase storage
        final UploadTask uploadTask = storage
            .ref()
            .child('profilePictures/$fileName')
            .putData(imageBytes!);
        // Waits for the Task of uploading profile picture to complete
        final TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() => null);
        final String downloadURL = await taskSnapshot.ref.getDownloadURL();

        try {
          //uploads DownloadURL to a firestore collection named profilePictures
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(FirebaseAuth.instance.currentUser!.email)
              .update({"profilePicture": downloadURL});
          print('UploadTask Complete. Download URL: $downloadURL');
        } catch (e) {
          print("Error: $e");
        }
      } catch (e) {
        print("Error: $e");
      }
    }

// Awaits user input to select an Image
    void selectImage() async {
      // Use the ImagePicker plugin to open the device's gallery to pick an image.
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      //Image.file(pickedFile as File,width: 400,height: 300,);
      // Check if an image was picked.
      if (pickedFile != null) {
        // Read the image file as bytes.
        final imageBytes = await pickedFile.readAsBytes();

        // Update the profilePictureProvider state with the selected image as Uint8List.
        ref.read(profilePictureProvider.notifier).state =
            Uint8List.fromList(imageBytes);
        saveProfile(Uint8List.fromList(imageBytes));
      }
    }

    //Signs the user out when called
    void signOut() {
      FirebaseAuth.instance.signOut();
      runApp(
        ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: LoginPage(),
            routes: {'/home': (context) => LoginPage()},
          ),
        ),
      );
    }

    //Shows the settings page when called
    void showSettings(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(signOutProvider);
                    Navigator.of(context).pushReplacementNamed('/settings');
                  },
                  child: const Text("Sign out Button"),
                ),
              ],
            ),
          );
        },
      );
    }

    //App bar for the user profile page
    PreferredSize userProfileAppBar(
        BuildContext context, WidgetRef ref, String title) {
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

    // Edit field
    Future<void> editField(String field) async {
      TextEditingController username = TextEditingController();

      String? newValue = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: themeColor2,
          title: Text(
            "Edit $field",
            style: TextStyle(color: themeColor),
          ),
          content: TextField(
            controller: username,
            autofocus: true,
            style: TextStyle(color: themeColor),
            decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: TextStyle(color: themeColor),
            ),
          ),
          actions: [
            // Cancel button
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(color: themeColor),
              ),
              onPressed: () => Navigator.pop(context),
            ),

            // Save button
            TextButton(
              child: Text(
                'Save',
                style: TextStyle(color: themeColor),
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

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;

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

    return Scaffold(
      backgroundColor: themeColor2,
      appBar: userProfileAppBar(context, ref, 'U s e r'),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('User data not found.'),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

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
                        child: profilePictureUrl.when(
                          data: (url) {
                            if (url != null && url.isNotEmpty) {
                              return CircleAvatar(
                                radius: 64,
                                backgroundImage: NetworkImage(url),
                              );
                            }
                            return image.state != null
                                ? CircleAvatar(
                                    radius: 64,
                                    backgroundImage: image.state != null
                                        ? MemoryImage(image.state!)
                                        : null,
                                  )
                                : Icon(
                                    color: themeColor,
                                    CupertinoIcons.profile_circled,
                                    size: 72,
                                  );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (e, stack) => const Icon(
                              CupertinoIcons.profile_circled,
                              size: 72),
                        ),
                      ),
                      Positioned(
                        bottom: -10,
                        left: 240,
                        child: IconButton(
                          color: themeColor,
                          // onPressed, opens Image Picker
                          onPressed: selectImage,
                          icon: const Icon(Icons.add_a_photo),
                        ),
                      )
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
                          style: TextStyle(
                            color: themeColor,
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
                    title: Text(
                      'My Details',
                      style: TextStyle(
                        color: themeColor,
                      ),
                    ),
                    children: [
                      // Username
                      MyTextBox(
                        text: userData['username']?.toString() ?? '',
                        sectionName: 'Username',
                        onPressed: () => editField('username'),
                      ),

                      // Bio
                      MyTextBox(
                        text: userData['bio']?.toString() ?? '',
                        sectionName: 'Bio',
                        onPressed: () => editField('bio'),
                      ),
                    ],
                  ),

                  
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ExpansionTile(
                          title: Text(
                            'My Posts',
                            style: TextStyle(
                              color: themeColor,
                            ),
                          ),
                          children: [
                            FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection("User Posts")
                                  .where('UserEmail',
                                      isEqualTo: currentUser.email)
                                  .get(),
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
                                    child: Text('No posts found.'),
                                  );
                                }

                                return SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.6, // Adjust the height
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      final post = snapshot.data!.docs[index];
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
                                            email: post['UserEmail']),
                                        builder: (context, usernameSnapshot) {
                                          if (usernameSnapshot.hasData) {
                                            return FeedPost(
                                              message: post['Message'],
                                              user: usernameSnapshot.data!,
                                              postId: post.id,
                                              barcodeData: barcodeDataMap,
                                              likes: List<String>.from(
                                                  post['Likes'] ?? []),
                                              time:
                                                  formatDate(post['TimeStamp']),
                                              email: post['UserEmail'],
                                              exerciseName:
                                                  post['ExerciseName'] ?? '',
                                              exerciseType:
                                                  post['ExerciseType'] ?? '',
                                              muscle:
                                                  post['ExerciseMuscle'] ?? '',
                                              equipment:
                                                  post['ExerciseEquipment'] ??
                                                      '',
                                              difficulty:
                                                  post['ExerciseDifficulty'] ??
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
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                      );
                                    },
                                  ),
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

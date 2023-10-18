import 'package:atlas/components/my_textfield.dart';
import 'package:atlas/components/text_box.dart';
import 'package:atlas/pages/constants.dart';
import 'package:atlas/pages/login_page.dart';
import 'package:atlas/pages/settings_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atlas/main.dart';
import "package:cupertino_icons/cupertino_icons.dart";
import 'package:image_picker/image_picker.dart';
import 'package:atlas/pages/settings_page.dart';

// Riverpod Provider
final profilePictureProvider = StateProvider<Uint8List?>((ref) => null);

class UserProfile extends ConsumerWidget {
  const UserProfile({Key? key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final usersCollection = FirebaseFirestore.instance.collection("Users");
    final currentIndex = ref.watch(selectedIndexProvider);
    final image = ref.watch(profilePictureProvider.notifier);

    //Saves the state of dark mode being on or off
    final lightDarkTheme = ref.watch(themeProvider);

    //Holds the opposite theme color for the text
    final themeColor = lightDarkTheme ? Colors.white : Colors.black;

  //Signs the user out when called
  void signOut() {
    FirebaseAuth.instance.signOut();
    runApp(
      ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: LoginPage(),
          routes: {
            '/home': (context) => LoginPage(),
          },
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
            content: Column (
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                //Signout button
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(signOutProvider);
                    // After succesful logout redirect to logout page
                    Navigator.of(context).pushReplacementNamed('/settings');
                  },
                  child: const Text (
                    "Sign out Button"
                  )
                ),
              ]
            ),
          );
        }
      );
    }

  //Shows the settings page when called
  //Saving for later because it works
  /*
  void showSettings(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Settings'),
            content: Column (
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                //Signout button
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(signOutProvider);
                    // After succesful logout redirect to logout page
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: const Text (
                    "Sign out Button"
                  )
                ),
              ]
            ),
          );
        }
      );
    }
    */

  // Awaits for user input to select an Image
  // Awaits for user input to select an Image
  // Awaits user input to select an Image
  void selectImage() async {
    // Use the ImagePicker plugin to open the device's gallery to pick an image.
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    // Check if an image was picked.
    if (pickedFile != null) {
      // Read the image file as bytes.
      final imageBytes = await pickedFile.readAsBytes();

      // Update the profilePictureProvider state with the selected image as Uint8List.
      ref.read(profilePictureProvider.notifier).state = Uint8List.fromList(imageBytes);
    }
  }

  //Saves the profile
  void saveProfile() async {
    final imageBytes = image.state;
    if (imageBytes != null) {
      try {
        await FirebaseFirestore.instance
            .collection("profilePictures")
            .doc(currentUser.email)
            .set({"profilePicture": imageBytes});
      } catch (e) {
        print("Error: $e");
      }
    }
  }

  //App bar for the user profile page
  PreferredSize userProfileAppBar(BuildContext context, WidgetRef ref, String title) {
    return PreferredSize (
      preferredSize: const Size.fromHeight(70),
      child: AppBar (
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 90, 86, 86),
        actions: [
          //Settings icon button
          IconButton (
          icon: const Icon(Icons.settings),
          onPressed: () {
              Navigator.push (
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
          title: Text(
            title,
            style: const TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
            )
          )
      );
  }

  // Edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit $field",
          style: TextStyle(color: themeColor),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(
              color: const Color.fromARGB(
                  255, 0, 0, 0)), // Change text color to white
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.black),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // Cancel button
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[700]),
            ),
            onPressed: () => Navigator.pop(context),
          ),

          // Save button
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.grey[700]),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    // Update in Firestore
    if (newValue.trim().isNotEmpty) {
      // Only update if there is something in the text field
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 229, 229),
      appBar: userProfileAppBar(context, ref, 'U s e r  P r o f i l e'),
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
            return Center(
              child: const Text('User data not found.'),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData != null) {
            return ListView(
              children: [
                const SizedBox(height: 50),

                //Profile pic
                Stack(
                  children: [
                    Align(
                      alignment: Alignment.center, // Center the icon
                      child: image.state != null
                          ? CircleAvatar(
                              radius: 64,
                              backgroundImage: MemoryImage(image.state!),
                            )
                          : const Icon(
                              CupertinoIcons.profile_circled,
                              size: 72,
                            ),
                    ),
                    Positioned(
                      bottom: -10,
                      left: 80,
                      child: IconButton(
                        // onPressed, opens Image Picker
                        onPressed: selectImage,
                        icon: const Icon(Icons.add_a_photo),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 10),

                //User email
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),

                const SizedBox(height: 50),

                //User details
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),

                //Username
                MyTextBox(
                  text: userData?['username']?.toString() ??
                      '', // Safely access username
                  sectionName: 'Username',
                  onPressed: () => editField('username'),
                ),

                //Bio
                MyTextBox(
                  text: userData?['bio']?.toString() ?? '', // Safely access bio
                  sectionName: 'Bio',
                  onPressed: () => editField('bio'),
                ),

                const SizedBox(height: 50),

                //User posts
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Posts',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
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

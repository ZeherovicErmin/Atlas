import 'package:atlas/components/my_textfield.dart';
import 'package:atlas/components/text_box.dart';
import 'package:atlas/pages/barcode_log_page.dart';
import 'package:atlas/pages/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atlas/main.dart';
import 'package:image_picker/image_picker.dart';

// Riverpod Provider
final profilePictureProvider = StateProvider<Uint8List?>((ref) => null);

class UserProfile extends ConsumerWidget {
  // ignore: use_key_in_widget_constructors
  const UserProfile({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final usersCollection = FirebaseFirestore.instance.collection("Users");
    final currentIndex = ref.watch(selectedIndexProvider);
    final image = ref.watch(profilePictureProvider.notifier);

    void saveProfilePic() async {
      final imageBytes = image.state;

      if (imageBytes != null) {
        try {
          await usersCollection
              .doc(currentUser.email)
              .update({'profilePicture': imageBytes});
        } catch (e) {
          print("Error: $e");
        }
      }
    }

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
        ref.read(profilePictureProvider.notifier).state =
            Uint8List.fromList(imageBytes);

        saveProfilePic();
      }
    }

    Widget buildProfilePicture(Uint8List? picBytes) {
      return Stack(
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
            style: const TextStyle(color: Colors.blue),
          ),
          content: TextField(
            autofocus: true,
            style: const TextStyle(
                color:
                    Color.fromARGB(255, 0, 0, 0)), // Change text color to white
            decoration: InputDecoration(
              hintText: "Enter new $field",
              hintStyle: const TextStyle(color: Colors.black),
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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: myAppBar2(context, ref, 'U s e r    P r o f i l e'),
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
              return ListView(
                children: [
                  const SizedBox(height: 50),

                  buildProfilePicture(image.state),

                  const SizedBox(height: 10),

                  // User email
                  Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),

                  const SizedBox(height: 50),

                  // User details
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                      'My Details',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                      ),
                    ),
                  ),

                  // Username
                  MyTextBox(
                    text: userData['username']?.toString() ??
                        '', // Safely access username
                    sectionName: 'Username',
                    onPressed: () => editField('username'),
                  ),

                  // Bio
                  MyTextBox(
                    text:
                        userData['bio']?.toString() ?? '', // Safely access bio
                    sectionName: 'Bio',
                    onPressed: () => editField('bio'),
                  ),

                  const SizedBox(height: 50),

                  // User posts
                  const Padding(
                    padding: EdgeInsets.only(left: 25.0),
                    child: Text(
                      'My Posts',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
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
      ),
      /*drawer: myDrawer,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 38, 97, 185),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          ref.read(selectedIndexProvider.notifier).state = index;
          // Using Navigator to put a selected page onto the stack
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => tabs[index]),
          );
        },
      ),*/
    );
  }
}

import 'dart:typed_data';
import 'package:atlas/components/feed_post.dart';
import 'package:atlas/components/productHouser.dart';
import 'package:atlas/helper/time_stamp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

final pictureProvider = StateProvider<Uint8List?>((ref) => null);

final uploadPictureUrlProvider = FutureProvider<String?>((ref) async {
  try {
    final DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('User Posts')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();
    return doc['uploadPicture'] as String?;
  } catch (e) {
    print('Error $e');
    return null;
  }
});

class Feed extends ConsumerWidget {
  const Feed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final textController = TextEditingController();
    final uploadPictureUrl = ref.watch(uploadPictureUrlProvider);
    final image = ref.watch(pictureProvider.notifier);

    /*
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
              .collection("User Posts")
              .doc(FirebaseAuth.instance.currentUser!.email)
              .update({"uploadPicture": downloadURL});
          print('UploadTask Complete. Download URL: $downloadURL');
        } catch (e) {
          print("Error: $e");
        }
      } catch (e) {
        print("Error: $e");
      }
    }
    */

    void addPicture(Uint8List imageBytes) async {
      try {
        final FirebaseStorage storage = FirebaseStorage.instance;
        final String? userEmail = FirebaseAuth.instance.currentUser!.email;

        // Generate a timestamp and convert it to a string
        final String timestamp =
            DateTime.now().millisecondsSinceEpoch.toString();

        // Construct a unique file name with the email and timestamp
        final String fileName = "{$userEmail$timestamp}postImage.jpg";

        // Upload the image to Firebase Storage
        final UploadTask uploadTask =
            storage.ref().child('postImages/$fileName').putData(imageBytes);

        // Wait for the upload task to complete
        final TaskSnapshot taskSnapshot =
            await uploadTask.whenComplete(() => null);
        final String downloadURL = await taskSnapshot.ref.getDownloadURL();

        // Store the download URL in Firestore
        await FirebaseFirestore.instance.collection("User Posts").add({
          'UserEmail': currentUser.email,
          'Message': textController.text,
          'TimeStamp': Timestamp.now(),
          'Likes': [],
          'recipe': {},
          'barcodeData': {},

          'ExerciseName': '',
          'ExerciseType': '',
          'ExerciseMuscle': '',
          'ExerciseEquipment': '',
          'ExerciseDifficulty': '',
          'ExerciseInstructions': '',
          'postImage':
              downloadURL, // Add the download URL to your Firestore document
        });

        // Clear the text field
        textController.clear();
      } catch (e) {
        print("Error: $e");
      }
    }

    void selectImage() async {
      //Dialog box to select image
      final ImageSource? source =
          await showCupertinoImageSourceDialog(context: context);
      if (source != null) {
        // Use the ImagePicker plugin to open the device's gallery to pick an image.
        final pickedFile =
            await ImagePicker().pickImage(source: source);
        //Image.file(pickedFile as File,width: 400,height: 300,);
        // Check if an image was picked.
        if (pickedFile != null) {
          // Read the image file as bytes.
          final imageBytes = await pickedFile.readAsBytes();

          // Update the profilePictureProvider state with the selected image as Uint8List.
          ref.read(pictureProvider.notifier).state =
              Uint8List.fromList(imageBytes);
          addPicture(Uint8List.fromList(imageBytes));
        }
      }
    }

    void postMessage() {
      //only post if there is something in the textfield
      if (textController.text.isNotEmpty) {
        FirebaseFirestore.instance.collection("User Posts").add({
          'UserEmail': currentUser.email,
          'Message': textController.text,
          'TimeStamp': Timestamp.now(),
          'ExerciseName': '',
          'ExerciseType': '',
          'ExerciseMuscle': '',
          'ExerciseEquipment': '',
          'ExerciseDifficulty': '',
          'ExerciseInstructions': '',
          'Likes': [],
          'barcodeData': {},
          'postImage': '', // Add the download URL to your Firestore document
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
      //resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(
          255, 232, 229, 229), //Home page for when a user logs in
      appBar: AppBar(
        leading: const Icon(
          null,
        ),
        centerTitle: true,
        title: const Text(
          "Feed",
          style:
              TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
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
                          // Get the message
                          final post = snapshot.data!.docs[index];

// Handle barcodeData with type checking
                          final barcodeDataDynamic = post['barcodeData'];
                          Map<String, dynamic> barcodeDataMap = {};

                          if (barcodeDataDynamic is Map<String, dynamic>) {
                            barcodeDataMap = barcodeDataDynamic;
                          } else {
                            print(
                                'Unexpected type for barcodeData: ${barcodeDataDynamic.runtimeType}');
                          }

                          //Check if doc has recipe data. If so, get the recipe data
                          final recipe =
                              post.data().toString().contains('recipe')
                                  ? post.get('recipe')
                                  : '';
                          Map<String, dynamic> emptyMap =
                              Map<String, dynamic>();
                          return StreamBuilder<String>(
                            stream: fetchUsername(email: post['UserEmail']),
                            builder: (context, usernameSnapshot) {
                              if (usernameSnapshot.hasData) {
                                return FeedPost(
                                    message: post['Message'],
                                    user: usernameSnapshot.data!,
                                    postId: post.id,
                                    barcodeData: barcodeDataMap,
                                    likes:
                                        List<String>.from(post['Likes'] ?? []),
                                    time: formatDate(post['TimeStamp']),
                                    email: post['UserEmail'],
                                    exerciseName: post['ExerciseName'] ?? '',
                                    exerciseType: post['ExerciseType'] ?? '',
                                    muscle: post['ExerciseMuscle'] ?? '',
                                    equipment: post['ExerciseEquipment'] ?? '',
                                    difficulty:
                                        post['ExerciseDifficulty'] ?? '',
                                    instructions:
                                        post['ExerciseInstructions'] ?? '',
                                    imageUrl: post['postImage'],
                                    recipe: recipe == '' ? emptyMap : recipe);
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

            //post message/image
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

                  IconButton(
                    onPressed: selectImage,
                    icon: const Icon(
                      Icons.add_a_photo_rounded,
                      color: Color.fromARGB(255, 0, 136, 204),
                    ),
                  ),
                  //post button
                  IconButton(
                    onPressed: postMessage,
                    icon: const Icon(
                      Icons.arrow_circle_up,
                      color: Color.fromARGB(255, 0, 136, 204),
                    ),
                  ),
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

Future<ImageSource?> showCupertinoImageSourceDialog(
    {required BuildContext context}) async {
  return await showCupertinoModalPopup<ImageSource>(
    context: context,
    builder: (BuildContext context) => CupertinoActionSheet(
      title: const Text('Select Image Source'),
      actions: <CupertinoActionSheetAction>[
        CupertinoActionSheetAction(
          child: const Text('Camera'),
          onPressed: () => Navigator.pop(context, ImageSource.camera),
        ),
        CupertinoActionSheetAction(
          child: const Text('Gallery'),
          onPressed: () => Navigator.pop(context, ImageSource.gallery),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        child: const Text('Cancel'),
        isDefaultAction: true,
        onPressed: () => Navigator.pop(context, null),
      ),
    ),
  );
}

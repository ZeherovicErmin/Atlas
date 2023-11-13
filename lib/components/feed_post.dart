import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/components/comment.dart';
import 'package:atlas/components/comment_button.dart';
import 'package:atlas/components/delete_button.dart';
import 'package:atlas/components/editPostButton.dart';
import 'package:atlas/components/like_button.dart';
import 'package:atlas/components/productHouser.dart';
import 'package:atlas/helper/time_stamp.dart';
import 'package:atlas/pages/saved_recipes.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:photo_view/photo_view.dart';

class FeedPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final Map<String, dynamic>? barcodeData;
  final String email;
  final String? exerciseName;
  final String? exerciseType;
  final String? muscle;
  final String? equipment;
  final String? difficulty;
  final String? instructions;
  final String imageUrl;
  final Map<String, dynamic>? recipe;

  const FeedPost(
      {super.key,
      required this.message,
      required this.user,
      required this.postId,
      required this.likes,
      required this.time,
      required this.email,
      required this.exerciseName,
      required this.exerciseType,
      required this.muscle,
      required this.equipment,
      required this.difficulty,
      required this.instructions,
      this.barcodeData,
      required this.imageUrl,
      this.recipe});

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  //user //hey
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userPostsCollection =
      FirebaseFirestore.instance.collection("User Posts");

  bool isLiked = false;
  final _commentTextController = TextEditingController();
  bool hasComments = true;
  //List of widgets to include in the barcode sharing

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
    checkForComments();
  }

  //toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    //Access the document in Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      //if post is liked add users email to Likes field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      //if post is unliked remove the users email from the Likes field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          //Makes it so the 3 dots is separated from Username
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                //User Icon, Username, Timestamp
                children: [
                  Icon(
                    Icons.account_circle,
                    size: 40.0,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  // User name stacked on top of the timestamp of time posted
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Username
                      Text(
                        widget.user.trim(),
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      //Timestamp
                      Text(
                        widget.time,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //More options Icon
            //Should give the user access to report, edit, delete
            //REMEMBER TO UPDATE WITH THE OPTIONS!!!!!
            //Most likely a modal shee
            IconButton(
                //passes in widget and current user for the Visibility check
                onPressed: () =>
                    _showPostOptions(context, widget, currentUser, this),
                icon: Icon(Icons.more_vert)),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        // feed post
        Text(
          widget.message,
          style: const TextStyle(color: Colors.black),
          maxLines: null,
        ),
Visibility(
  visible: widget.imageUrl != '' && widget.imageUrl.isNotEmpty,
  child: GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GestureDetector(
            onTap: () => Navigator.of(context).pop(), // Close dialog on tap outside
            child: Container(
              color: Colors.transparent, // Transparent background
              child: Center(
                child: PhotoView(
                  imageProvider: NetworkImage(widget.imageUrl),
                  backgroundDecoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  initialScale: PhotoViewComputedScale.contained,
                ),
              ),
            ),
          );
        },
      );
    },
    child: Container(
      height: 200, // Set a fixed height
      width: double.infinity, // Use the full width of the screen
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), // Optional for rounded corners
        image: DecorationImage(
          image: NetworkImage(widget.imageUrl),
          fit: BoxFit.cover, // This will cover the container, maintaining aspect ratio
        ),
      ),
    ),
  ),
),

        // Only display specific barcode data entries
        Visibility(
          visible: widget.barcodeData != null &&
              widget.barcodeData!.isNotEmpty &&
              widget.barcodeData!['productName'] != null &&
              widget.barcodeData!['productName'].isNotEmpty,
          child: Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 3.0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: InkWell(
              //This will pull up a modal sheet
              onTap: () {
                Widget modalContent = NewWidget(widget.barcodeData);

                showModalBottomSheet(
                  context: context,
                  builder: (context) => modalContent,
                );
                //deleteLog(context, data);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, top: 16, bottom: 8, right: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            widget.barcodeData?['productName'] ?? '',
                            maxLines: 1,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            minFontSize: 15,
                          ),

                          // The keys that are filtered get sent into .map(socialBarcode)
                          ...widget.barcodeData!.entries
                              .where((entry) =>
                                  entry.key == 'proteinPerServing' ||
                                  entry.key == 'carbsPerServing' ||
                                  entry.key ==
                                      'fatsPerServing') // Filter specific keyshere
                              .map(socialBarcode)
                              .toList(),
                          const SizedBox(height: 5),
                        ],
                      ),
                    ),
                    const Image(
                        height: 120,
                        width: 100,
                        image:
                            AssetImage('assets/icons/flameiconnameplate.png'),
                        fit: BoxFit.contain),
                  ],
                ),
              ),
            ),
          ),
        ),

        //Show if there is recipe data
        Visibility(
          visible: widget.recipe != null && widget.recipe!.isNotEmpty,
          child: ElevatedButton(
            onPressed: () => navigateToRecipeDetails(context,
                Result.fromJson(widget.recipe as Map<String, dynamic>)),
            child: Text("View Recipe"),
          ),
        ),

        const SizedBox(height: 5),
        // Displaying workout details
        if (widget.exerciseName != null && widget.exerciseType != null)
          Visibility(
              visible: widget.exerciseName != null &&
                  widget.exerciseName!.isNotEmpty,
              child: Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12.0), // Add a border radius
                  border: Border.all(
                    width: .5,
                    style: BorderStyle.solid,
                    color: Colors.transparent,
                    // Set the border color and width
                  ),
                ),
                child: fitdesign(),
              )),

        //delete button
        //  if (currentUser.email == widget.email)
        //    DeleteButton(onTap: deletePost),

        // Align(
        //   alignment: Alignment.topRight,
        //   child: currentUser.email == widget.email
        //       ? DeleteButton(onTap: deletePost)
        //       : const SizedBox(),
        // ),

        //edit post button
        Align(
          alignment: Alignment.topRight,
          child: currentUser.email == widget.email
              ? editButton(
                  onTap: () async {
                    // Check if there are comments
                    bool hasComments = await checkForComments();

                    BuildContext dialogContext = context;

                    if (hasComments) {
                      // Show a message or take any other action
                      // ignore: use_build_context_synchronously
                      showDialog(
                        context: dialogContext,
                        builder: (context) => AlertDialog(
                          title: const Text("Cannot Edit"),
                          content: const Text(
                              "There are comments on this post. You cannot edit it."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Allow editing if there are no comments
                      editPost();
                    }
                  },
                )
              : const SizedBox(),
        ),

        const SizedBox(height: 20),

        // buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //LIKE
            Column(
              children: [
                //like button
                LikeButton(
                  isLiked: isLiked,
                  onTap: toggleLike,
                ),

                const SizedBox(height: 5),

                //like count
                Text(
                  widget.likes.length.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(width: 15),

            //COMMENT
            Column(
              children: [
                //comment button
                CommentButton(onTap: showCommentDialog),

                const SizedBox(height: 5),

                //comment count
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .doc(widget.postId)
                      .collection("Comments")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      //Calculate the comment count
                      final commentCount = snapshot.data?.docs.length;
                      return Text(
                        commentCount.toString(),
                        style: const TextStyle(color: Colors.grey),
                      );
                    } else {
                      // show a loading indicator while fetching data
                      return const CircularProgressIndicator();
                    }
                  },
                )
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        //comments under the post
        Column(
          children: [
            ExpansionTile(
              backgroundColor: Colors.grey[200],
              title: Text('View Comments',
                  style: TextStyle(color: Colors.grey[500])),
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .doc(widget.postId)
                      .collection("Comments")
                      .orderBy("CommentTime", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    //show loading circle if theres no data
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: snapshot.data!.docs.map((doc) {
                        //get the comment
                        final commentData = doc.data() as Map<String, dynamic>;

                        //return the comment
                        return Comment(
                          text: commentData["CommentText"],
                          userId: commentData["CommentedBy"],
                          time: formatDate(commentData["CommentTime"]),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                //like button
                LikeButton(
                  isLiked: isLiked,
                  onTap: toggleLike,
                ),

                const SizedBox(height: 5),

                //like count
                Text(
                  widget.likes.length.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            Column(children: [
              IconButton(
                  onPressed: () => _showCommentsModal(context, widget.postId),
                  icon: Icon(
                    Icons.comment,
                    color: Colors.grey,
                  )),
            ])
          ],
        )
      ]),
    );
  }

  FlipCard fitdesign() {
    return FlipCard(
      fill: Fill.fillBack,
      direction: FlipDirection.VERTICAL,
      speed: 400,
      front: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(
                    widget.exerciseName ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32,
                    ),
                    maxLines: 1,
                    minFontSize: 20,
                    overflow: TextOverflow.clip,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        widget.difficulty ?? '',
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.muscle ?? '',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        widget.equipment ?? '',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      back: Card(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Returning a numbered list for the instructions of the workout
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: (widget.instructions ?? '').split('.').length - 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        '${index + 1}. ${(widget.instructions ?? '').split('.')[index]}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Row socialBarcode(MapEntry<String, dynamic> entry) {
    // Capitalize the first letter of each word, and remove 'PerServing'
    String keyText = entry.key
        .replaceAll(RegExp(r'PerServing'), '')
        .split(' ')
        .map((str) => str[0].toUpperCase() + str.substring(1))
        .join(' ');

    // Check if the entry is 'productName' and format it differently
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              AutoSizeText(
                '$keyText: ${entry.value}g',
                maxLines: 1,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      ],
    );
  }

  //show dialog box to add a comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //title: const Text("Add Comment"),
        content: TextField(
          maxLength: 100,
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "Add a comment..."),
        ),
        actions: [
          //cancel button
          TextButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear controller
              _commentTextController.clear();
            },
            child: const Text("Cancel"),
          ),

          //post button
          TextButton(
            onPressed: () {
              //add comment
              addComment(_commentTextController.text);

              //pop box
              Navigator.pop(context);

              //clear controller
              _commentTextController.clear();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  // delete a post
  void deletePost() {
    //show a dialog box for asking for confirmation before deleting the post
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          //CANCEL BUTTON
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          //DELETE BUTTON
          TextButton(
            onPressed: () async {
              //delete the comments from firestore first
              //(if you only delete the post, the comments will still be stored in firestore)
              final commentDocs = await FirebaseFirestore.instance
                  //Change back to User Posts
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    //Change back to User Posts
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              // delete the post
              FirebaseFirestore.instance

                  ///Change back to User Posts
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("post deleted"))
                  .catchError(
                      (error) => print("failed to delete post: $error"));

              // dismiss the dialog
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  addComment(String commentText) {
    // write the comment to firestore
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now() //format when displaying
    });
  }

  Future<void> editPost() async {
    TextEditingController post = TextEditingController(text: widget.message);
    //show a dialog box for ediitng the post
    String? newValue = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          "Edit Message",
          style: const TextStyle(color: Colors.black),
        ),
        content: TextField(
          controller: post,
          autofocus: true,
          style: const TextStyle(
              color: Colors.black), // Change text color to white
          decoration: InputDecoration(
            hintText: "Enter new Message",
            hintStyle: const TextStyle(color: Colors.black),
          ),
        ),
        actions: [
          // Cancel button
          TextButton(
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => Navigator.pop(context),
          ),

          // Confirm button
          TextButton(
            child: const Text(
              'Confirm',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => Navigator.of(context).pop(post.text),
          ),
        ],
      ),
    );

    // Update in Firestore
    if (newValue != null && newValue.trim().isNotEmpty) {
      try {
        // Only update if there is something in the text field
        await userPostsCollection
            .doc(widget.postId)
            .update({'Message': newValue});
        print("Post updated successfully");
      } catch (error) {
        print("Error updating post: $error");
      }
    }
  }

  Widget NewWidget(Map<String, dynamic>? barcodeData) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 252, 252),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: SingleChildScrollView(
        //controller: _controller,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            //NutriGridView(selectedFilters: selectedFilters, result: result, productName: productName, productCalories: productCalories, carbsPserving: carbsPserving, proteinPserving: proteinPserving, fatsPserving: fatsPserving,secondController: ScrollController()),
            //Nutritional Facts Column Sheet
            const Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  child: Text(
                    'Nutrition Facts',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontFamily: 'Helvetica Black',
                        fontSize: 44,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const Divider(
                thickness: 1, color: Color.fromARGB(255, 118, 117, 117)),
            Align(
              child: Container(
                height: 25,
                // Stack to hold the fats and the fats variable
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${barcodeData?['amtServingsProvider']}g per container",
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontFamily: 'Helvetica Black',
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            const NutritionRow(
              title: "Calories",
              value: '${0}',
              fontSize: 24,
              dividerThickness: 5,
              showDivider: false,
            ),
            //Nutritional Column Dividers
            //End NUTRITION FACTS ROW
            const Divider(thickness: 5, color: Color.fromARGB(255, 0, 0, 0)),
            //Start of Nutrition rows
            //
            NutritionRow(
                title: 'Total Fats',
                value: '${barcodeData!['fatsPerServing']}'),
            //saturated Fats
            NutritionRow(
              title: 'Saturated Fat',
              value: '${barcodeData['satfatsPserving']}',
              isSubcategory: true,
              hideIfZero: false,
            ),
            NutritionRow(
              title: 'Trans Fat',
              value: '${barcodeData['transfatsPserving']}',
              isSubcategory: true,
              hideIfZero: false,
            ),
            //end fats

            NutritionRow(
                title: "Total Carbohydrates",
                value: '${barcodeData['carbsPerServing']}'),
            //Sugars
            NutritionRow(
                title: "Total Sugars",
                isSubcategory: true,
                value: '${barcodeData['sugarsPerServing']}'),
            //end Protein

            //protein per serving
            NutritionRow(
                title: "Protein", value: '${barcodeData['proteinPerServing']}'),

            //sodium
            NutritionRow(
                title: "Sodium", value: "${barcodeData['sodiumPerServing']}"),
            NutritionRow(
                title: "Sodium", value: "${barcodeData['sodiumPerServing']}"),

            NutritionRow(
                title: "Cholesterol",
                value: '${barcodeData['cholesterolPerServing']}'),
            //end Protein
          ]),
        ),
      ),
    );
  }

  Future<bool> checkForComments() async {
    QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .get();

    return commentSnapshot.docs.isNotEmpty;
  }
}

_showCommentsModal(BuildContext context, String postId) {
  TextEditingController commentController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('User Posts')
            .doc(postId)
            .collection('Comments')
            .orderBy('CommentTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 500,
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Container(
              height: 500,
              alignment: Alignment.center,
              child: Text('No comments yet.', style: TextStyle(fontSize: 18)),
            );
          }

          List<Map<String, dynamic>> comments = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return Container(
            height: 500,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Comments',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> comment = comments[index];
                      return ListTile(
                        leading: Icon(Icons.account_circle, size: 40),
                        title: Text(comment['CommentText'],
                            style: TextStyle(fontSize: 16)),
                        subtitle: Text(
                            'Commented by: ${comment['CommentedBy']}',
                            style: TextStyle(fontSize: 14, color: Colors.grey)),
                      );
                    },
                  ),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(left: 16, bottom: 32.0),
                          child: TextField(
                            controller: commentController,
                            decoration: InputDecoration(
                              hintText: "Write a comment...",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          String commentText = commentController.text;
                          if (commentText.isNotEmpty) {
                            postComment(postId, commentText);
                            commentController.clear();
                            FocusScope.of(context).unfocus();
                          }
                        },
                        icon: Icon(Icons.send,
                            color: Color.fromARGB(255, 0, 136, 204)),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      );
    },
  );
}

void postComment(String postId, String commentText) {
  FirebaseFirestore.instance
      .collection('User Posts')
      .doc(postId)
      .collection('Comments')
      .add({
    "CommentText": commentText,
    "CommentedBy": FirebaseAuth.instance.currentUser?.email ?? "Anonymous",
    "CommentTime": Timestamp.now()
  });
}

Future<List<Map<String, dynamic>>> fetchComments(postId) async {
// Collects comments from a particular post
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('User Posts')
      .doc(postId)
      .collection('Comments')
      .orderBy('CommentTime', descending: true)
      .get();
  return snapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();
}

//Need to pass in widget and currentUser variables
void _showPostOptions(
    BuildContext context, widget, currentUser, _FeedPostState state) {
  showModalBottomSheet(
    context: context,
    builder: (
      BuildContext context,
    ) {
      return Container(
        height: 115,
        child: Column(
          children: <Widget>[
            Visibility(
              visible: currentUser.email != widget.email,
              child: ListTile(
                leading: Icon(Icons.report),
                title: Text('Report Post'),
                onTap: () {
                  // Add functionality for reporting a post
                  Navigator.pop(context);
                  //reportPost
                  _confirmReportDialog(
                      context, widget.postId, currentUser, widget);
                  //reportPost(widget.postId, currentUser, widget);
                },
              ),
            ),
            //Edit Post if user owns the post
            Visibility(
              visible: currentUser.email == widget.email,
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit Post'),
                onTap: () {
                  // Add functionality for reporting a post
                  Navigator.pop(context);
                  state.editPost();
                },
              ),
            ),
            //Delete Post if user owns the post (Need to add this functionality)
            Visibility(
              visible: currentUser.email == widget.email,
              child: ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Delete Post'),
                onTap: () {
                  // Add functionality for reporting a post
                  Navigator.pop(context);
                  state.deletePost();
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _confirmReportDialog(
    BuildContext context, String postId, currentUser, widget) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Report Post"),
      content: const Text(
          "Are you sure you want to report this post? This action cannot be undone."),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            reportPost(postId, currentUser, widget, context);
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Reported!')));
            Navigator.pop(context);
          },
          child: const Text("Report"),
        ),
      ],
    ),
  );
}

//Function to report a post
Future<void> reportPost(
    String postId, currentUser, widget, BuildContext context) async {
  final currentUserEmail = currentUser.email;
  final postRef =
      FirebaseFirestore.instance.collection('User Posts').doc(postId);
  final postSnapshot = await postRef.get();
  if (!postSnapshot.exists) {
    print('Post does not exist');
    return;
  }

  //Adds to data for reporting
  Map<String, dynamic> postData = postSnapshot.data() as Map<String, dynamic>;
  List<dynamic> reports = postData['Reports'] ?? [];

  if (!reports.contains(currentUserEmail)) {
    reports.add(currentUserEmail);
    await postRef.update({'Reports': reports});

    //Check if reports hits the amt of time
    if (reports.length >= 3) {
      //await deletePost(postId);
      final commentDocs = await FirebaseFirestore.instance
          .collection('User Posts')
          .doc(widget.postId)
          .collection("Comments")
          .get();
      //The only for loop in this codebases existence
      for (var doc in commentDocs.docs) {
        await FirebaseFirestore.instance
            .collection('User Posts')
            .doc(widget.postId)
            .collection('Comments')
            .doc(doc.id)
            .delete();
      }
      //delete the post
      FirebaseFirestore.instance
          .collection('User Posts')
          .doc(widget.postId)
          .delete()
          .then((value) => print("post deleted"))
          .catchError((error) => print('failed to report post: $error'));

      //dismiss dialog
      //Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Post reported')));
    }
  }

//Text(barcodeData!['productName']),
}

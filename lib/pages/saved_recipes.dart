import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/pages/recipe-details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_card/image_card.dart';

class SavedRecipes extends StatefulWidget {
  const SavedRecipes({super.key});

  @override
  State<SavedRecipes> createState() => _SavedRecipesState();
}

class _SavedRecipesState extends State<SavedRecipes> {
  final CollectionReference savedRecipesCollection =
      FirebaseFirestore.instance.collection("Saved_Recipes");

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    // Get the current user's uid
    final userID = auth.currentUser?.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream:
            savedRecipesCollection.where("uid", isEqualTo: userID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
                padding: EdgeInsets.all(50),
                alignment: Alignment.center,
                child: CircularProgressIndicator());
          }

          List<Result> savedRecipes = [];
          snapshot.data!.docs.forEach((doc) {
            savedRecipes.add(Result.fromJson(doc["recipe"], id: doc.id));
          });

          return Column(children: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    //ListView used to output recipe list element into individual components
                    child: ListView.separated(
                      shrinkWrap: true,
                      //Used to ensure list is scrollable
                      physics: const AlwaysScrollableScrollPhysics(),
                      //Number of recipes
                      itemCount: savedRecipes.length,
                      //Used to build recipe list tiles
                      itemBuilder: (context, index) {
                        Result recipe = savedRecipes[index];
                        return Container(
                            alignment: Alignment.center,
                            child: TransparentImageCard(
                              width: 300,
                              imageProvider: recipe.image != null ||
                                      recipe.image != ""
                                  ? NetworkImage(recipe.image)
                                  : const AssetImage(
                                          'assets/icons/recipe-notfound.svg')
                                      as ImageProvider,
                              // tags: [
                              //   _tag('Product', () {}),
                              // ],
                              title: Container(
                                  child: Text(
                                "${recipe.title}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              )),
                              description: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty
                                                    .all<Color>(const Color.fromARGB(255, 0, 136, 204))),
                                        onPressed: () =>
                                            navigateToRecipeDetails(
                                                context, recipe),
                                        child: Text(
                                          "View Details",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                        )),
                                    Container(
                                        padding: EdgeInsets.all(0),
                                        alignment: Alignment.bottomRight,
                                        child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                const Color.fromARGB(255, 0, 136, 204),
                                            child: Material(
                                                color: const Color.fromARGB(
                                                    0, 255, 255, 255),
                                                child: IconButton(
                                                  onPressed:
                                                      onShare(recipe, context),
                                                  icon: const Icon(Icons.share),
                                                  tooltip: "Share Recipe",
                                                  color: Colors.white,
                                                )))),
                                    Container(
                                        padding: EdgeInsets.all(0),
                                        alignment: Alignment.bottomRight,
                                        child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                const Color.fromARGB(255, 0, 136, 204),
                                            child: Material(
                                                color: const Color.fromARGB(
                                                    0, 255, 255, 255),
                                                child: IconButton(
                                                  onPressed: () => onRemove(
                                                      recipe,
                                                      context,
                                                      savedRecipesCollection),
                                                  icon: const Icon(
                                                      Icons.delete_forever),
                                                  tooltip: "Remove Recipe",
                                                  color: Colors.white,
                                                  highlightColor: Colors.black,
                                                  hoverColor: Colors.red
                                                      .withOpacity(0.3),
                                                  splashRadius: 20,
                                                  splashColor: Colors.blue,
                                                ))))
                                  ]),
                            ));
                      },
                      //Used to put a divider line between recipes
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                    )))
          ]);
        },
      ),
    );
  }
}

onShare(Result recipe, BuildContext context) {
  return () => showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer(builder: (context, ref, _) {
          return Dialog(
            insetPadding: EdgeInsets.only(top: 250, bottom: 325, left: 50, right: 50),
            child: Column(children: [
              Padding(padding: EdgeInsets.only(top: 45, left: 10, right: 10), child:
              //Recipe title
              Text("Post the recipe \"${recipe.title}\"?", style: TextStyle(fontSize: 15))),
              //Post button
              TextButton(
                onPressed: () {
                  FirebaseFirestore.instance.collection("User Posts").add({
                  'UserEmail': FirebaseAuth.instance.currentUser!.email,
                  'Message': "Check out this recipe: ${recipe.title}",
                  'TimeStamp': Timestamp.now(),
                  'Likes': [],
                  'barcodeData': {},
                  'postImage': '',
                  'ExerciseName': '',
                  'ExerciseType': '',
                  'ExerciseMuscle': '',
                  'ExerciseEquipment': '',
                  'ExerciseDifficulty': '',
                  'ExerciseGif': '',
                  'ExerciseInstructions': '',
                  'recipe': recipe.toMap() ,
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Recipe \"${recipe.title}\" was shared')));
              },
            child: const Text('Post'),
          ),
          //Close button
              TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          )
            ],)
            );
        }
        );
      });
}

// Function to navigate to recipe details page
void navigateToRecipeDetails(BuildContext context, Result recipe) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => RecipeDetails(recipe: recipe),
    ),
  );
}

//Remove Button Handler - Remove Saved Recipe
onRemove(Result recipe, BuildContext context,
    CollectionReference<Object?> savedRecipesCollection) async {
  await savedRecipesCollection.doc(recipe.firebaseID).delete();

  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Recipe Removed - ${recipe.title}'),
      duration: Duration(seconds: 1)));
}

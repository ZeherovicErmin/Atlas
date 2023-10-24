import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/pages/constants.dart';
import 'package:atlas/pages/recipe-details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

//State Provider holds list of saved recipes
final savedRecipesProvider = FutureProvider<List<Result>>((ref) async {
  return await getSavedRecipes();
});

class SavedRecipes extends ConsumerWidget {
  const SavedRecipes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedrecipes = ref.watch(savedRecipesProvider);
    return Scaffold(
        appBar: myAppBar2(context, ref, "Saved Recipes"),
        body: savedrecipes.when(
            //if successfull, output saved recipes
            data: (recipes) => gradient(recipes, context, ref),
            //iff error, output error
            error: (error, stacktrace) => Text("error"),
            //while loading, show progress indicator
            loading: () => CircularProgressIndicator()));
    // body: FutureBuilder<List<Result>>(
    //         future: ref.watch(savedRecipesProvider),
    //         builder: (context, snapshot) {
    //           List<Widget> children;
    //           if (snapshot.connectionState == ConnectionState.waiting) {
    //             return CircularProgressIndicator();
    //           } else if (snapshot.hasError) {
    //             return Text('$snapshot.error}');
    //           }
    //           {
    //             List<Result>? savedRecipes = snapshot.data;
    //             return gradient(savedRecipes!, context, ref);
    //           }
    //         }));
  }

  Widget gradient(
      List<Result> savedRecipes, BuildContext context, WidgetRef ref) {
    return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 90, 117, 255),
              Color.fromARGB(255, 161, 195, 250)
            ],
          ),
        ),
        child: Column(children: [savedRecipeList(savedRecipes, context, ref)]));
  }

  Widget savedRecipeList(
      List<Result> savedRecipes, BuildContext context, WidgetRef ref) {
    //List<Result>? savedRecipes = ref.watch(savedRecipesProvider);
    if (savedRecipes != null) {
      return Expanded(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                  String recipeName = recipe.title;
                  return ListTile(
                      onTap: () => navigateToRecipeDetails(context, recipe),
                      title: Text(recipeName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      //Add remove button to end of tile
                      trailing: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.redAccent,
                          child: Material(
                              color: const Color.fromARGB(0, 255, 255, 255),
                              child: IconButton(
                                onPressed: () => onRemove(recipe, ref, context),
                                icon: const Icon(Icons.delete_forever),
                                tooltip: "Remove Recipe",
                                color: Colors.black,
                                highlightColor: Colors.black,
                                hoverColor: Colors.red.withOpacity(0.3),
                                splashRadius: 20,
                                splashColor: Colors.blue,
                              ))));
                },
                //Used to put a divider line between recipes
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              )));
    }
    return const Text("No Saved Recipes");
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
  onRemove(Result recipe, WidgetRef ref, BuildContext context) async {
    /*
    //copy list of saved recipes
    List<Result>? recipes = [
      ...ref.watch(savedRecipesProvider as ProviderListenable<Iterable<Result>>)
    ];
    //remove the selected recipe
    recipes.remove(recipe);
    //save new list without the removed recipe
    ref.read(savedRecipesProvider.notifier).state = recipes;
  */
    final recipeCollection =
        FirebaseFirestore.instance.collection("Saved_Recipes");
    await recipeCollection.doc(recipe.firebaseID).delete();

    //ref.refresh(savedRecipesProvider);
    //Output removed message
    // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //     content: Text('Recipe Removed - ${recipe.title}'),
    //     duration: Duration(seconds: 1)));
  }
}

Future<List<Result>> getSavedRecipes() async {
  //list of recipe objects to be returned
  List<Result> savedRecipes = [];

  // Create an instance of FirebaseAuth
  final FirebaseAuth auth = FirebaseAuth.instance;
  // Get the current user's uid
  final userID = auth.currentUser?.uid;
  //variable used to manage the Saved Recipes collection on firebase
  final collection = FirebaseFirestore.instance.collection("Saved_Recipes");

  //List of saved recipes that have uids that match the current users
  //(List of this users saved recipes)
  collection.where("uid", isEqualTo: userID).get().then((recipes) {
    for (var recipeRecord in recipes.docs) {
      //Converting recipe from firebase to Result object
      var recipe = Result.fromJson(recipeRecord["recipe"], id: recipeRecord.id);
      savedRecipes.add(recipe);
    }
  });
  return savedRecipes;
  //ref.read(savedRecipesProvider.notifier).state = savedRecipes;
}

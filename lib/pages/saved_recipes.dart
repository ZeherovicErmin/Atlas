import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/pages/recipe-details.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SavedRecipes extends ConsumerWidget {
  const SavedRecipes({Key? key, required this.savedRecipesProvider})
      : super(key: key);
  final StateProvider<List<Result>?> savedRecipesProvider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(appBar: AppBar(), body: gradient(context, ref));
  }

  Widget gradient(BuildContext context, WidgetRef ref) {
    List<Result>? savedRecipes = ref.watch(savedRecipesProvider);
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
      //List<dynamic> recipes,
      List<Result>? recipes,
      BuildContext context,
      WidgetRef ref) {
    if (recipes != null) {
      return Expanded(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              //ListView used to output recipe list element into individual components
              child: ListView.separated(
                shrinkWrap: true,
                //Used to ensure list is scrollable
                physics: const AlwaysScrollableScrollPhysics(),
                //Number of recipes
                itemCount: recipes.length,
                //Used to build recipe list tiles
                itemBuilder: (context, index) {
                  Result recipe = recipes[index];
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
  onRemove(Result recipe, WidgetRef ref, BuildContext context) {
    //copy list of saved recipes
    List<Result>? recipes = [
      ...ref.watch(savedRecipesProvider as ProviderListenable<Iterable<Result>>)
    ];
    //remove the selected recipe
    recipes.remove(recipe);
    //save new list without the removed recipe
    ref.read(savedRecipesProvider.notifier).state = recipes;
    //Output removed message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Recipe Removed - ${recipe.title}'),
        duration: Duration(seconds: 1)));
  }
}
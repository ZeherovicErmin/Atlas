import 'dart:convert';
import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:atlas/pages/recipe-details.dart';

//State Provider holds API Response data including list of Recipes
final resultProvider = StateProvider<RecipeModel>((ref) {
  return RecipeModel();
});

//State Provider holds list of saved recipes
final savedRecipesProvider = StateProvider<List<Result>>((ref) {
  return [];
});

//Recipe Class that handles and displays the recipes is
//child of class Consumer Widget
class Recipes extends ConsumerWidget {
  //Constructors
  Recipes({Key? key}) : super(key: key);

  //global key used for recipe form-handling
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //Text controller used to store value from recipe search bar
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //recipes provider state getter
    final recipes = ref.watch(resultProvider).results;
    //Saved recipes provider state getter
    List<Result> savedRecipes = ref.watch(savedRecipesProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: myAppBar2(context, ref, "Recipes"),
      body: gradient(recipes, savedRecipes, context, ref),
      //Recipe search bar submit button
      floatingActionButton: FloatingActionButton(
        //Use onSubmit to activate search, onSubmitTEST to deactivate search
        //and use test data
        onPressed: () => onSubmitTEST(context, ref),
        child: Text('Submit'),
      ),
    );
  }

  // bg gradient color
  Widget gradient(List<Result>? recipes, List<Result>? savedRecipes,
      BuildContext context, WidgetRef ref) {
    return Container(
      //gradient decoration
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 238, 238, 238),
            Color.fromARGB(255, 238, 238, 238),
          ],
        ),
      ),
      //Rest of page material including search form and list
      //recipes returned from API
      child: Column(children: [
        form(),
        recipeList(recipes, context, ref),
        const Text(
          "SAVED RECIPES",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        savedRecipeList(savedRecipes, context, ref),
      ]),
    );
  }

  //Recipe search form
  Widget form() {
    return Column(children: [
      //Spacing between components

      Container(
        margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.11))
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(children: [searchBar()]),
        ),
      ),
    ]);
  }

// Recipe search bar
  Widget searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: TextFormField(
        controller: searchController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please Input A Value into Searchbar';
          }
          return null;
        },
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            border: InputBorder.none,
            hintText: "Enter Recipe Search"),
      ),
    );
  }

  // List of recipe results from the API request
  Widget recipeList(
      //List<dynamic> recipes,
      List<Result>? recipes,
      BuildContext context,
      WidgetRef ref) {
    //Expanded takes up entire container space
    if (recipes == null) {
      return const Text("INVALID API RESPONSE");
    }
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
                    title: Text(recipeName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    //Function used to capture tap event for list items
                    onTap: () => navigateToRecipeDetails(context, recipe),
                    //Add Save button to end of tile
                    trailing: ElevatedButton(
                        child: const Text("Save"),
                        onPressed: () => onSave(recipe, ref, context)));
              },
              //Used to put a divider line between recipes
              separatorBuilder: (context, index) {
                return const Divider();
              },
            )));
  }

  //Save Button Handler - Save New Recipe
  void onSave(Result recipe, WidgetRef ref, BuildContext context) async {
    //copy list of saved recipes
    List<Result> recipes = [...ref.watch(savedRecipesProvider)];
    //add new recicpe
    recipes.add(recipe);
    //save new list of recipes
    ref.read(savedRecipesProvider.notifier).state = recipes;
    //output recipe saved message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Recipe Saved'), duration: Duration(seconds: 1)));
    print(ref.watch(savedRecipesProvider));
  }

  //Form Submission Handler - Submits recipe search to API
  void onSubmit(BuildContext context, WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Searching for Recipes')));

      //Parameter: Query - User-Inputted Search Query
      String query = searchController.text;
      //Parameter: API Key - Used to gain access to the API
      String apiKey = "cd2573f729714ab5bba24521e30d23ec";
      //Parameter: Number - number of results to be returned from API
      int number = 5;
      //Parameter: AddRecipeNutrition - true to add nutrition info, false to not
      bool addNutrition = true;
      //Parameter: AddRecipeInformation - true to add recipe info such as instructions, false to not
      bool addRecipeInfo = true;
      //API Request URL with Parameters
      String url =
          'https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey&query=$query&number=$number&addRecipeNutrition=$addNutrition&addRecipeInformation=$addRecipeInfo';
      //formats url
      final uri = Uri.parse(url);
      //sends request to api
      final response = await http.get(uri);
      //converts response from json
      final data = jsonDecode(response.body);
      //maps API response data to RecipeModel
      RecipeModel mappedData = RecipeModel.fromJson(data);
      //If the results is not null(or empty) we use state management
      //to set the result equal to the mapped RecipeModel containing
      //All of the API response data
      if (mappedData.results != null) {
        ref.read(resultProvider.notifier).state = mappedData;
      } else {
        mappedData = RecipeModel();
      }
    }
  }

  //TEST Form Submission Handler - Outputs Test Data from
  //spoonacularResult.json
  void onSubmitTEST(BuildContext context, WidgetRef ref) async {
    print("Submit testing");
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Searching for Recipes')));
      String value = searchController.text;
      final String response =
          await rootBundle.loadString('assets/spoonacularResult.json');
      final data = await json.decode(response);
      //print(data);
      RecipeModel mappedData = RecipeModel.fromJson(data);
      if (mappedData.results != null) {
        ref.read(resultProvider.notifier).state = mappedData;
      } else {
        mappedData = RecipeModel();
      }
    }
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
                      trailing: ElevatedButton(
                          child: const Text("Remove"),
                          onPressed: () => onRemove(recipe, ref, context),
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.red))));
                },
                //Used to put a divider line between recipes
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              )));
    }
    return const Text("No Saved Recipes");
  }

  //Remove Button Handler - Remove Saved Recipe
  onRemove(Result recipe, WidgetRef ref, BuildContext context) {
    //copy list of saved recipes
    List<Result> recipes = [...ref.watch(savedRecipesProvider)];
    //remove the selected recipe
    recipes.remove(recipe);
    //save new list without the removed recipe
    ref.read(savedRecipesProvider.notifier).state = recipes;
    //Output removed message
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Recipe Removed'), duration: Duration(seconds: 1)));
    //print(ref.watch(savedRecipesProvider));
  }
}

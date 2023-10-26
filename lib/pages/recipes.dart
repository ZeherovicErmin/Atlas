import 'dart:convert';
import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/pages/constants.dart';
import 'package:atlas/pages/saved_recipes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atlas/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:atlas/pages/recipe-details.dart';
import 'package:image_card/image_card.dart';

//State Provider holds API Response data including list of Recipes
final resultProvider = StateProvider<RecipeModel>((ref) {
  return RecipeModel();
});

//State Provider holds List of users saved recipe Ids
final savedRecipeIdsProvider = StateProvider<List<int>>((ref) {
  return [];
});

final calorieRangesProvider = StateProvider<RangeValues>((ref) {
  return const RangeValues(0, 2000);
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

  get themeColor => null;

  get themeColor2 => null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //recipe provider state getter
    final recipes = ref.watch(resultProvider).results;
    return DefaultTabController(
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Color(0xFFFAF9F6), //- OFFWHITE
          appBar: AppBar(
              title: const Center(
                  child: Text("Recipes",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              backgroundColor: Colors.orange,
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.search), text: "Search"),
                Tab(icon: Icon(Icons.bookmark_add_rounded), text: "Saved"),
              ])),
          body: TabBarView(children: [
            Column(children: [
              Padding(padding: EdgeInsets.only(top: 20)),
              form(context, ref),
              //ingredientsList(),
              recipeList(recipes, context, ref)
            ]),
            const SavedRecipes()
          ]),
        ));
  }

  //Recipe search form
  Widget form(BuildContext context, WidgetRef ref) {
    RangeValues calorieRange = ref.watch(calorieRangesProvider);
    return Column(children: [
      //Spacing between components

      const Padding(
        padding: EdgeInsets.only(
            top: 5,
            left: 15,
            right: 15,
            bottom: 5), //apply padding to all sides
      ),
      Container(
        margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.11))
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(children: [
            searchBar(context, ref),
            Container(
                color: Color(0xFFFAF9F6),
                padding: EdgeInsets.only(top: 15),
                alignment: Alignment.topLeft,
                child: Text("Calorie Filter",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ))),
            Container(
                color: Color(0xFFFAF9F6),
                child: RangeSlider(
                    values: calorieRange,
                    max: 5000,
                    divisions: 50,
                    activeColor: Colors.orange,
                    inactiveColor: const Color.fromARGB(155, 255, 153, 0),
                    overlayColor: MaterialStatePropertyAll(
                        const Color.fromARGB(255, 255, 190, 104)),
                    labels: RangeLabels(calorieRange.start.round().toString(),
                        calorieRange.end.round().toString()),
                    onChanged: (RangeValues range) {
                      ref.read(calorieRangesProvider.notifier).state = range;
                    }))
          ]),
        ),
      ),
    ]);
  }

// Recipe search bar

  Widget searchBar(BuildContext context, WidgetRef ref) {
    return TextFormField(
      //Controller stores value entered by user
      controller: searchController,
      //Checks if searchbar has a value, if not: show error message
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please Input A Value into Searchbar';
        }
        return null;
      },
      style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
      decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 15),
          prefixIcon: Icon(Icons.search),
          prefixIconColor: Colors.orangeAccent,
          suffixIcon: IconButton(
              icon: Icon(Icons.send),
              //Use onSubmit to activate search, onSubmitTEST to deactivate search
              //and use test data
              onPressed: () => onSubmitTEST(context, ref)),
          suffixIconColor: Colors.orangeAccent,
          filled: true,
          fillColor: Color.fromARGB(255, 248, 237, 220),
          //Placeholder message in search bar directing user
          hintText: "Enter Recipe Search",
          hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
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
            padding: const EdgeInsets.all(4.0),
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

                //Function called when saved button is pressed
                var onPressedFunction;

                List<int> savedRecipeIds = ref.watch(savedRecipeIdsProvider);
                //If recipe is already saved, set the onPressedFunction to null
                //which will disable the save button - preventing duplicates
                if (savedRecipeIds.contains(recipe.id)) {
                  onPressedFunction = null;
                }
                //If the recipe is not already saved, set the onPressedFunction
                //To the onSave function which will save it to the database
                else {
                  onPressedFunction = () => onSave(recipe, ref, context);
                }

                return Container(
                    alignment: Alignment.center,
                    child: TransparentImageCard(
                      width: 300,
                      imageProvider: recipe.image != null || recipe.image != ""
                          ? NetworkImage(recipe.image)
                          : const AssetImage('assets/icons/recipe-notfound.svg')
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color.fromARGB(255, 255, 162, 23))),
                                onPressed: () =>
                                    navigateToRecipeDetails(context, recipe),
                                child: Text(
                                  "View Details",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                            Container(
                                padding: EdgeInsets.all(0),
                                alignment: Alignment.bottomRight,
                                child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor:
                                        const Color.fromARGB(255, 255, 176, 58),
                                    child: IconButton(
                                      onPressed: onPressedFunction,
                                      icon: const Icon(
                                          Icons.bookmark_add_rounded),
                                      tooltip: "Save Recipe",
                                      color: const Color.fromARGB(
                                          255, 255, 255, 255),
                                      disabledColor:
                                          Color.fromARGB(102, 255, 255, 255),
                                      highlightColor: Colors.purpleAccent,
                                      hoverColor: Colors.blue.withOpacity(0.3),
                                      splashRadius: 20,
                                      splashColor: Colors.red,
                                    )))
                          ]),
                    ));
              },
              //Used to put a divider line between recipes
              separatorBuilder: (context, index) {
                return const Divider();
              },
            )));
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

      //Calorie Filter Range
      RangeValues calorieRange = ref.watch(calorieRangesProvider);

      //Parameter: minCalories -minimum number of calories allowed for recipe results
      int minCalories = calorieRange.start.round();
      //Parameter: maxCalories -maximum number of calories allowed for recipe results
      int maxCalories = calorieRange.end.round();
      //API Request URL with Parameters
      String url =
          'https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey&query=$query&number=$number&addRecipeNutrition=$addNutrition&addRecipeInformation=$addRecipeInfo&minCalories=$minCalories&maxCalories=$maxCalories';
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
        //Update list of saved recipe Ids
        ref.read(savedRecipeIdsProvider.notifier).state =
            await getSavedRecipeIds();
        //Update list of searched recipes
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
        //Update list of saved recipe Ids
        ref.read(savedRecipeIdsProvider.notifier).state =
            await getSavedRecipeIds();
        //Update list of searched recipes
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

  // Function to navigate to Saved Recipes Page
  navigateToSavedRecipesPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SavedRecipes()),
    );
  }

  //Save Button Handler - Save New Recipe
  void onSave(Result recipe, WidgetRef ref, BuildContext context) async {
    //Save the recipe to the DB
    saveRecipeToDB(recipe);

    //copy list of Ids
    List<int> savedRecipeIds = [...ref.watch(savedRecipeIdsProvider)];
    //add new Id
    savedRecipeIds.add(recipe.id);
    //save new list of recipes
    ref.read(savedRecipeIdsProvider.notifier).state = savedRecipeIds;

    //output recipe saved message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Recipe Saved - ${recipe.title}'),
        duration: Duration(seconds: 1)));

    // Map<String, dynamic> recipeMap = recipe.toMap();
    // print(recipeMap);
  }

  Future<void> saveRecipeToDB(Result recipe) async {
    // Create an instance of FirebaseAuth
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Get the current user's uid
    final userID = auth.currentUser?.uid;

    //reference to Saved_Recipes collection in firebase
    final recipeCollection =
        FirebaseFirestore.instance.collection("Saved_Recipes");

    //send request to firebase to add recipe to the Saved_Recipes collection
    await recipeCollection.add(
        {"uid": userID, "recipe": recipe.toMap(), "saveDate": DateTime.now()});
  }

  Future<List<int>> getSavedRecipeIds() async {
    // Create an instance of FirebaseAuth
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Get the current user's uid
    final userID = auth.currentUser?.uid;

    //reference to Saved_Recipes collection in firebase
    final recipesCollection =
        FirebaseFirestore.instance.collection("Saved_Recipes");

    final savedRecipes =
        await recipesCollection.where("uid", isEqualTo: userID).get();

    List<int> recipeIDList = [];
    savedRecipes.docs.forEach((doc) {
      recipeIDList.add(doc["recipe"]["id"]);
    });

    return recipeIDList;
  }
}

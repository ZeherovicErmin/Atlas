import 'dart:convert';
import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/pages/custom-recipes.dart';
import 'package:atlas/pages/saved_recipes.dart';
import 'package:atlas/pages/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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

//global key used for recipe form-handling
//final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();


//Recipe Class that handles and displays the recipes is
//child of class Consumer Widget
class Recipes extends ConsumerWidget {
  final GlobalKey<FormBuilderState> formKey;

  //Constructors
  //Recipes({Key? key, required this.formKey}) : super(key: key);
  Recipes({Key? key})
      : formKey = GlobalKey<FormBuilderState>(),
        super(key: key);

  get themeColor => null;

  get themeColor2 => null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Variables
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    //recipe provider state getter
    final recipes = ref.watch(resultProvider).results;
    return DefaultTabController(
        initialIndex: 0,
        length: 3,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: const Color(0xFFFAF9F6), //- OFFWHITE
          appBar: AppBar(
              actions: [
                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('Users')
                        .doc(user?.email)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }
                      if (snapshot.hasData && snapshot.data!.exists) {
                        var userData =
                            snapshot.data!.data() as Map<String, dynamic>;
                        var profileImageUrl = userData['profilePicture'];
                        if (profileImageUrl is String &&
                            profileImageUrl.isNotEmpty) {
                          return IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const UserProfile()),
                              );
                            },
                            icon: CircleAvatar(
                              backgroundImage: NetworkImage(profileImageUrl),
                            ),
                          );
                        }
                        return IconButton(
                          icon: const Icon(CupertinoIcons.profile_circled),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const UserProfile()),
                            );
                          },
                        );
                      }
                      return IconButton(
                          icon: const Icon(CupertinoIcons.profile_circled),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const UserProfile()));
                          });
                    })
              ],
              leading: const Icon(
                null,
              ),
              centerTitle: true,
              title: const Text("Recipes",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: const Color.fromARGB(255, 0, 136, 204),
              bottom: const TabBar(tabs: [
                Tab(icon: Icon(Icons.search), text: "Search"),
                Tab(icon: Icon(Icons.bookmark_add_rounded), text: "Saved"),
                Tab(icon: Icon(Icons.dining), text: "Custom")
              ])),
          body: TabBarView(children: [
            Column(children: [
              ExpansionTile(
                title: const Text(
                  "Search",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                backgroundColor: const Color.fromARGB(255, 248, 237, 220),
                collapsedBackgroundColor:
                    const Color.fromARGB(255, 248, 237, 220),
                initiallyExpanded: true,
                children: [
                  form(context, ref),
                  const Text("Ingredient Quick-Search",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  ElevatedButton(
                      onPressed: ingredientQuickSearchDialog(context, ref),
                      child: Text("Quick Search"))
                ],
              ),
              recipeList(recipes, context, ref)
            ]),
            SavedRecipes(),
            CustomRecipes()
          ]),
        ));
  }

  //Recipe search form
  Widget form(BuildContext context, WidgetRef ref) {
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
              BoxShadow(
                  color:
                      const Color.fromARGB(255, 88, 34, 194).withOpacity(0.11))
            ],
          ),
          child: FormBuilder(
            key: formKey,
            child: Column(children: [
              searchBar(context, ref),
              ExpansionTile(
                title: const Text("Filters",
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                children: [filters(ref)],
                backgroundColor: Color.fromARGB(255, 248, 237, 220),
                collapsedBackgroundColor: Color.fromARGB(255, 248, 237, 220),
              )
            ]),
          )),
    ]);
  }

// Recipe search bar
  Widget searchBar(BuildContext context, WidgetRef ref) {
    return FormBuilderTextField(
      name: "query",
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
          prefixIconColor: Colors.blueAccent,
          suffixIcon: IconButton(
              icon: Icon(Icons.send),
              //Use onSubmit to activate search, onSubmitTEST to deactivate search
              //and use test data
              onPressed: () => onSubmit(context, ref)),
          suffixIconColor: Colors.blueAccent,
          filled: true,
          fillColor: Color(0xFFFAF9F6),
          //Placeholder message in search bar directing user
          hintText: "Enter Recipe Search",
          hintStyle: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
    );
  }

  Widget filters(WidgetRef ref) {
    RangeValues calorieRange = ref.watch(calorieRangesProvider);
    return Column(children: [
      FormBuilderRangeSlider(
          name: "calorieRange",
          min: 0,
          max: 5000,
          initialValue: const RangeValues(0, 0),
          divisions: 50,
          activeColor: Colors.blue,
          inactiveColor: Color.fromARGB(155, 0, 8, 255),
          labels: RangeLabels(calorieRange.start.round().toString(),
              calorieRange.end.round().toString()),
          decoration: const InputDecoration(labelText: "Calorie Range"),
          onChanged: (RangeValues? range) {
            ref.read(calorieRangesProvider.notifier).state =
                range as RangeValues;
          }),
      FormBuilderFilterChip(
        name: "diets",
        options: const [
          FormBuilderChipOption(value: 'vegan', child: Text("Vegan")),
          FormBuilderChipOption(value: 'vegetarian', child: Text("Vegetarian")),
          FormBuilderChipOption(
              value: 'pescetarian', child: Text("Pescatarian")),
          FormBuilderChipOption(value: 'ketogenic', child: Text("Ketogenic")),
          FormBuilderChipOption(
              value: 'glutenFree', child: Text("Gluten Free")),
          FormBuilderChipOption(value: 'dairyFree', child: Text("Dairy Free")),
          FormBuilderChipOption(
              value: 'peanutFree', child: Text("Peanut Free")),
          FormBuilderChipOption(
              value: 'seafoodFree', child: Text("Seafood Free")),
          FormBuilderChipOption(
              value: 'shellfishFree', child: Text("Shellfish Free")),
          FormBuilderChipOption(value: 'soyFree', child: Text("Soy Free"))
        ],
        decoration: const InputDecoration(labelText: "Dietary Restrictions"),
        selectedColor: Colors.blue,
        checkmarkColor: Colors.white,
        autovalidateMode: AutovalidateMode.always,
        validator: (value) {
          if (value == null) {
            return null;
          }
          if (value!.contains("vegan") && value!.contains("pescetarian")) {
            return 'Recipe cannot be vegan and pescatarian';
          } else if (value!.contains("vegetarian") &&
              value!.contains("pescetarian")) {
            return 'Recipe cannot be vegetarian and pesecatarian';
          }
          return null;
        },
      )
    ]);
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
                          : const AssetImage(
                                  'assets/images/recipe-notfound.png')
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
                                            Colors.blueAccent)),
                                onPressed: () =>
                                    navigateToRecipeDetails(context, recipe),
                                child: const Text(
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
                                        Color.fromARGB(255, 58, 127, 255),
                                    child: Material(
                                        color: const Color.fromARGB(
                                            0, 255, 255, 255),
                                        child: IconButton(
                                          onPressed: onShare(recipe, context),
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
                                        Color.fromARGB(255, 58, 127, 255),
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
    if (formKey.currentState!.saveAndValidate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Searching for Recipes')));

      Map<String, dynamic> formData = formKey.currentState!.value;
      print(formData);

      //Parameter: Query - User-Inputted Search Query
      String query = formData["query"];
      //Parameter: API Key - Used to gain access to the API
      String apiKey = "cd2573f729714ab5bba24521e30d23ec";
      //Parameter: Number - number of results to be returned from API
      int number = 10;
      //Parameter: AddRecipeNutrition - true to add nutrition info, false to not
      bool addNutrition = true;
      //Parameter: AddRecipeInformation - true to add recipe info such as instructions, false to not
      bool addRecipeInfo = true;

      RangeValues calorieRange = ref.watch(calorieRangesProvider);

      //Parameter: minCalories -minimum number of calories allowed for recipe results
      int minCalories = calorieRange.start.round();
      //Parameter: maxCalories -maximum number of calories allowed for recipe results
      int maxCalories = calorieRange.end.round();

      String diets = "";
      String intolerances = "";

      if (formData["diets"] != null) {
        if (formData["diets"].contains("vegan")) {
          diets += ",vegan";
        }
        if (formData["diets"].contains("vegetarian")) {
          diets += ",vegetarian";
        }
        if (formData["diets"].contains("pescetarian")) {
          diets += ",pescetarian";
        }
        if (formData["diets"].contains("glutenFree")) {
          diets += ",gluten free";
        }
        if (formData["diets"].contains("ketogenic")) {
          diets += ",ketogenic";
        }
        if (formData["diets"].contains("dairyFree")) {
          intolerances += ",dairy";
        }
        if (formData["diets"].contains("peanutFree")) {
          intolerances += ",peanut";
        }
        if (formData["diets"].contains("seafoodFree")) {
          intolerances += ",seafood";
        }
        if (formData["diets"].contains("shellfishFree")) {
          intolerances += ",shellfish";
        }
        if (formData["diets"].contains("soyFree")) {
          intolerances += ",soy";
        }

        //Make sure diet string doesn't start/end with comma
        if (diets.startsWith(',')) {
          diets = diets.substring(1);
        } else if (diets.endsWith(',')) {
          diets = diets.substring(0, diets.length - 2);
        }

        //Make sure intolerance string doesn't start/end with comma
        if (intolerances.startsWith(',')) {
          intolerances = intolerances.substring(1);
        } else if (intolerances.endsWith(',')) {
          intolerances = intolerances.substring(0, intolerances.length - 2);
        }
      }

      //API Request URL with Parameters
      String url =
          'https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey';
      url += '&query=$query';
      url += '&number=$number';
      url += '&addRecipeNutrition=$addNutrition';
      url += '&addRecipeInformation=$addRecipeInfo';
      url += '&minCalories=$minCalories';
      url += '&maxCalories=$maxCalories';
      url += '&diet=$diets';
      url += '&intolerances=$intolerances';
      print(url);
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      RecipeModel mappedData = RecipeModel.fromJson(data);
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
    if (formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Searching for Recipes')));
      String value = formKey.currentState!.value["query"];
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

  //list of quick-search ingredients
  Widget ingredientsList(
      BuildContext buildContext, WidgetRef ref, List<String> ingredients) {
    return Padding(
        padding: EdgeInsets.only(top: 15, bottom: 15, left: 0, right: 0),
        child: SizedBox(
            height: 80,
            child: Column(
              children: [
                Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        //Used to ensure list is scrollable
                        physics: const AlwaysScrollableScrollPhysics(),
                        //Number of recipes
                        itemCount: ingredients.length,
                        //Used to build recipe list tiles
                        itemBuilder: (context, index) {
                          String ingredient = ingredients[index];
                          return Padding(
                              padding: EdgeInsets.all(5),
                              child: ElevatedButton(
                                  style: const ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll(
                                          Colors.blueAccent)),
                                  child: FittedBox(
                                      fit: BoxFit.fitWidth,
                                      child: Text(ingredient,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  //Function used to capture tap event for list items
                                  onPressed: () => {
                                        searchIngredient(
                                            context, ref, ingredient),
                                        Navigator.of(buildContext).pop(),
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Searching for Recipes with $ingredient')))
                                      }));
                        }))
              ],
            )));
  }

  //Dialog containing lists of ingredients from different food categories
  ingredientQuickSearchDialog(BuildContext context, WidgetRef ref) {
    List<String> meats = [
      'Chicken',
      'Beef',
      'Fish',
      'Lamb',
      'Turkey',
      'Shrimp',
      'Crab',
      'Lobster',
      'Salmon'
    ];

    List<String> fruits = [
      'Apple',
      'Banana',
      'Orange',
      'Grapes',
      'Strawberry',
      'Mango',
      'Pineapple',
      'Watermelon',
      'Cherry',
      'Kiwi',
    ];

    List<String> vegetables = [
      'Carrot',
      'Broccoli',
      'Spinach',
      'Tomato',
      'Cucumber',
      'Bell Pepper',
      'Zucchini',
      'Onion',
      'Lettuce',
      'Potato',
    ];

    List<String> dairy = [
      'Milk',
      'Cheese',
      'Yogurt',
      'Butter',
      'Cream',
      'Cottage Cheese',
      'Sour Cream',
      'Cream Cheese',
      'Ice Cream',
      'Whipped Cream',
    ];

    List<String> carbs = [
      'Bread',
      'Rice',
      'Pasta',
      'Potatoes',
      'Quinoa',
      'Oats',
      'Cereal',
      'Beans',
      'Corn',
      'Sweet Potato',
    ];

    return () => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer(builder: (dialogContext, dialogRef, _) {
            return Dialog(
                insetPadding: EdgeInsets.only(left: 10, right: 10),
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 0, left: 0, right: 0),
                    child: SingleChildScrollView(
                        padding: const EdgeInsets.all(0),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            //mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                "Meats",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                              ingredientsList(dialogContext, ref, meats),
                              const Text(
                                "Fruits",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                              ingredientsList(dialogContext, ref, fruits),
                              const Text(
                                "Vegetables",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                              ingredientsList(dialogContext, ref, vegetables),
                              const Text(
                                "Dairy",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                              ingredientsList(dialogContext, ref, dairy),
                              const Text(
                                "Carbs",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                              ingredientsList(dialogContext, ref, carbs)
                            ]))));
          });
        });
  }

  void searchIngredient(
      BuildContext context, WidgetRef ref, String ingredient) async {
    //Parameter: Query - User- Selected Search Query
    String query = ingredient;
    //Parameter: API Key - Used to gain access to the API
    String apiKey = "cd2573f729714ab5bba24521e30d23ec";
    //Parameter: Number - number of results to be returned from API
    int number = 10;
    //Parameter: AddRecipeNutrition - true to add nutrition info, false to not
    bool addNutrition = true;
    //Parameter: AddRecipeInformation - true to add recipe info such as instructions, false to not
    bool addRecipeInfo = true;
    //API Request URL with Parameters
    String url =
        'https://api.spoonacular.com/recipes/complexSearch?apiKey=$apiKey&query=$query&number=$number&addRecipeNutrition=$addNutrition&addRecipeInformation=$addRecipeInfo';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final data = jsonDecode(response.body);
    RecipeModel mappedData = RecipeModel.fromJson(data);
    if (mappedData.results != null) {
      ref.read(resultProvider.notifier).state = mappedData;
    } else {
      mappedData = RecipeModel();
    }
  }
}

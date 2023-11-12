import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/Models/recipe-model.dart' as RecipeModel show Step;
import 'package:atlas/pages/recipe-details.dart';
import 'package:atlas/pages/saved_recipes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_card/image_card.dart';

//riverpod state provider that holds list of custom recipes
final customRecipesProvider = StateProvider<List<Result>>((ref) {
  return [];
});

final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

final ingredientCountProvider = StateProvider<int>((ref) {
  return 1;
});

final instructionCountProvider = StateProvider<int>((ref) {
  return 1;
});

class CustomRecipes extends ConsumerWidget {
  CustomRecipes({Key? key}) : super(key: key);

  final CollectionReference customRecipesCollection =
      FirebaseFirestore.instance.collection("Custom_Recipes");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //List of custom recipes, updated when user adds/removes
    // List<Result>? customRecipes = ref.watch(customRecipesProvider);

    final FirebaseAuth auth = FirebaseAuth.instance;
    // Get the current user's uid
    final userID = auth.currentUser?.uid;

    return Scaffold(
        body: Column(children: [
      Container(
          alignment: Alignment.center,
          child: ElevatedButton(
              onPressed: addRecipeDialog(context, ref),
              child: Text("Add New Recipe"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Color.fromARGB(255, 255, 162, 23)),
              ))),
      customRecipeList(ref, customRecipesCollection, userID)
    ]));
  }

  addRecipeDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    int instructionCount = ref.watch(instructionCountProvider);
    int ingredientCount = ref.watch(ingredientCountProvider);

    return () => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer(builder: (context, ref, _) {
            return Dialog(
                child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: SingleChildScrollView(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FormBuilder(
                              key: _formKey,
                              child: Column(
                                children: <Widget>[
                                  //Recipe Title Form Input
                                  FormBuilderTextField(
                                    name: 'recipeTitle',
                                    decoration: InputDecoration(
                                        labelText: 'Recipe Title'),
                                    validator: FormBuilderValidators.required(),
                                  ),
                                  //Recipe Image Form Input
                                  FormBuilderTextField(
                                    name: 'recipeImage',
                                    decoration: InputDecoration(
                                        labelText: 'Recipe Image'),
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.match(
                                          '^(https?|ftp):\\/\\/[^\\s/\$.?#].[^\\s]*\$')
                                    ]),
                                  ),
                                  //Recipe Cuisine Form Input
                                  FormBuilderTextField(
                                    name: 'cuisine',
                                    decoration:
                                        InputDecoration(labelText: 'Cuisine'),
                                    validator: FormBuilderValidators.required(),
                                  ),
                                  //Recipe Calories Form Input
                                  FormBuilderTextField(
                                    name: 'calories',
                                    decoration:
                                        InputDecoration(labelText: 'Calories'),
                                    keyboardType: TextInputType.number,
                                  ),
                                  //Recipe Ready Time Form Input
                                  FormBuilderTextField(
                                    name: 'readyTime',
                                    decoration: InputDecoration(
                                        labelText: 'Ready Time (in minutes)'),
                                    keyboardType: TextInputType.number,
                                  ),

                                  FormBuilderCheckbox(
                                    name: 'isVegan',
                                    title: Text('Is it Vegan?'),
                                  ),
                                  FormBuilderCheckbox(
                                    name: 'isVegetarian',
                                    title: Text('Is it Vegetarian?'),
                                  ),
                                  const Divider(
                                    height: 100,
                                    color: Colors.orange,
                                    thickness: 5,
                                  ),
                                  Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Instructions",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      //Number of ingredients
                                      itemCount:
                                          ref.watch(instructionCountProvider),
                                      //Used to build instruction list tiles
                                      itemBuilder: (context, index) {
                                        return FormBuilderTextField(
                                          name: 'instruction${index + 1}',
                                          decoration: InputDecoration(
                                              labelText:
                                                  'Instruction ${index + 1}'),
                                          maxLines: 5,
                                        );
                                      }),
                                  IconButton(
                                      onPressed: () => {
                                            ref
                                                .read(instructionCountProvider
                                                    .notifier)
                                                .state = ++instructionCount
                                          },
                                      icon: Icon(Icons.add_circle_outlined)),
                                  const Divider(
                                    height: 100,
                                    color: Colors.orange,
                                    thickness: 5,
                                  ),
                                  Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "Ingredients",
                                        style: TextStyle(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Padding(padding: EdgeInsets.only(bottom: 10)),
                                  ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      //Number of ingredients
                                      itemCount:
                                          ref.watch(ingredientCountProvider),
                                      //Used to build instruction list tiles
                                      itemBuilder: (context, index) {
                                        return Column(children: [
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 30)),
                                          Container(
                                              alignment: Alignment.topLeft,
                                              child: Text(
                                                "Ingredient ${index + 1}",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                          FormBuilderTextField(
                                            name: 'ingredientName${index + 1}',
                                            decoration: InputDecoration(
                                                labelText: 'Name'),
                                          ),
                                          Row(children: [
                                            Expanded(
                                                child: FormBuilderTextField(
                                              name:
                                                  'ingredientAmount${index + 1}',
                                              decoration: InputDecoration(
                                                  labelText: 'Amount'),
                                            )),
                                            Expanded(
                                                child: FormBuilderTextField(
                                              name:
                                                  'ingredientUnit${index + 1}',
                                              decoration: InputDecoration(
                                                  labelText: 'Unit'),
                                            )),
                                          ]),
                                        ]);
                                      }),
                                  IconButton(
                                      onPressed: () => {
                                            ref
                                                .read(ingredientCountProvider
                                                    .notifier)
                                                .state = ++ingredientCount
                                          },
                                      icon: Icon(Icons.add_circle_outlined)),
                                  const Divider(
                                    height: 100,
                                    color: Colors.orange,
                                    thickness: 5,
                                  ),
                                  Padding(padding: EdgeInsets.only(top: 20)),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (_formKey.currentState!
                                          .saveAndValidate()) {
                                        // Handle form data submission
                                        final formData =
                                            _formKey.currentState!.value;
                                        onAdd(formData, ref);
                                      }
                                    },
                                    child: Text('Submit'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Close dialog
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Close'),
                          )
                        ]))));
          });
        });
  }

  customRecipeList(WidgetRef ref,
      CollectionReference<Object?> customRecipesCollection, String? userID) {
    return StreamBuilder<QuerySnapshot>(
        stream:
            customRecipesCollection.where("uid", isEqualTo: userID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
                padding: EdgeInsets.all(50),
                alignment: Alignment.center,
                child: CircularProgressIndicator());
          }

          List<Result> customRecipes = [];
          snapshot.data!.docs.forEach((doc) {
            customRecipes.add(Result.fromJson(doc["recipe"], id: doc.id));
          });

          return Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  //ListView used to output recipe list element into individual components
                  child: ListView.separated(
                    shrinkWrap: true,
                    //Used to ensure list is scrollable
                    physics: const AlwaysScrollableScrollPhysics(),
                    //Number of recipes
                    itemCount: customRecipes!.length,
                    //Used to build recipe list tiles
                    itemBuilder: (context, index) {
                      Result recipe = customRecipes[index];
                      String recipeName = recipe.title;
                      return Container(
                          alignment: Alignment.center,
                          child: TransparentImageCard(
                            width: 300,
                            imageProvider:
                                recipe.image != null || recipe.image != ""
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
                                              MaterialStateProperty.all<Color>(
                                                  Color.fromARGB(
                                                      255, 255, 162, 23))),
                                      onPressed: () => navigateToRecipeDetails(
                                          context, recipe),
                                      child: Text(
                                        "View Details",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                  Container(
                                        padding: EdgeInsets.all(0),
                                        alignment: Alignment.bottomRight,
                                        child: CircleAvatar(
                                            radius: 20,
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 255, 176, 58),
                                            child: Material(
                                                color: const Color.fromARGB(
                                                    0, 255, 255, 255),
                                                child: IconButton(
                                                  onPressed: onShare(recipe, context),
                                                  icon: const Icon(
                                                      Icons.share),
                                                  tooltip: "Share Recipe",
                                                  color: Colors.white,
                                                )))),
                                  Container(
                                      padding: EdgeInsets.all(0),
                                      alignment: Alignment.bottomRight,
                                      child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: const Color.fromARGB(
                                              255, 255, 176, 58),
                                          child: Material(
                                              color: const Color.fromARGB(
                                                  0, 255, 255, 255),
                                              child: IconButton(
                                                onPressed: () => onRemove(
                                                    recipe,
                                                    context, 
                                                    customRecipesCollection),
                                                icon: const Icon(
                                                    Icons.delete_forever),
                                                tooltip: "Remove Recipe",
                                                color: Colors.white,
                                                highlightColor: Colors.black,
                                                hoverColor:
                                                    Colors.red.withOpacity(0.3),
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
                  )));
        });
  }

  onAdd(Map<String, dynamic> formData, WidgetRef ref) async {
    Nutrient nutrient = Nutrient(
        name: "Calories",
        amount: double.parse(formData["calories"]),
        unit: "kcal",
        percentOfDailyNeeds: 56.05);

    int ingredientCount = ref.watch(ingredientCountProvider);
    List<Ingredient> ingredientsList = [];
    for (int i = 1; i <= ingredientCount; i++) {
      Ingredient ingredient = Ingredient(
          id: 0,
          amount: double.parse(formData["ingredientAmount$i"]),
          name: formData["ingredientName${i}"],
          unit: formData["ingredientUnit${i}"],
          nutrients: []);

      ingredientsList.add(ingredient);
    }

    int instructionCount = ref.watch(instructionCountProvider);
    List<RecipeModel.Step> stepsList = [];
    for (int i = 1; i <= instructionCount; i++) {
      RecipeModel.Step step = RecipeModel.Step(
          number: i + 1,
          step: formData["instruction${i}"],
          ingredients: [],
          equipment: []);

      stepsList.add(step);
    }

    AnalyzedInstruction instructions =
        AnalyzedInstruction(name: "", steps: stepsList);

    Nutrition nutrition = Nutrition(
        nutrients: [nutrient],
        ingredients: ingredientsList,
        properties: [],
        flavonoids: [],
        caloricBreakdown: CaloricBreakdown(
            percentCarbs: 0.0, percentFat: 0.0, percentProtein: 0.0),
        weightPerServing: WeightPerServing(amount: 0, unit: "unit"));

    //Build Result object with all of the data
    Result recipe = Result(
        title: formData["recipeTitle"],
        image: formData["recipeImage"],
        cuisines: [formData["cuisine"]],
        readyInMinutes: int.parse(formData["readyTime"]),
        vegan: formData["isVegan"] == null ? false : true,
        vegetarian: formData["isVegetarian"] == null ? false : true,
        analyzedInstructions: [instructions],
        servings: 1,
        nutrition: nutrition);
    recipe.nutrition = nutrition;

    print(recipe.toMap());

    // Create an instance of FirebaseAuth
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Get the current user's uid
    final userID = auth.currentUser?.uid;

    //reference to Custom_Recipes collection in firebase
    final recipeCollection =
        FirebaseFirestore.instance.collection("Custom_Recipes");

    //send request to firebase to add recipe to the Custom_Recipes collection
    await recipeCollection.add(
        {"uid": userID, "recipe": recipe.toMap(), "saveDate": DateTime.now()});

    //Add new recipe to custom recipe list after copying the list.
    // List<Result> recipes = [...ref.watch(customRecipesProvider)];
    // recipes.add(recipe);
    // ref.read(customRecipesProvider.notifier).state = recipes;

    //Reset ingredient and instruction counts to 1
    ref.read(instructionCountProvider.notifier).state = 1;
    ref.read(ingredientCountProvider.notifier).state = 1;
  }

  //Remove Button Handler - Remove Custom Recipe
  onRemove(Result recipe, BuildContext context,
      CollectionReference<Object?> customRecipesCollection) async {
    // List<Result> recipes = [...ref.watch(customRecipesProvider)];
    // recipes.remove(recipe);
    // ref.read(customRecipesProvider.notifier).state = recipes;

    await customRecipesCollection.doc(recipe.firebaseID).delete();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Recipe Removed - ${recipe.title}'),
        duration: Duration(seconds: 1)));
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
}

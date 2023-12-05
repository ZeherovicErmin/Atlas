import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/Models/recipe-model.dart' as RecipeModel show Step;
import 'package:atlas/pages/custom-recipes.dart';
import 'package:atlas/pages/recipe-details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

StateProvider<int> ingredientCountProvider = StateProvider<int>((ref) {
  return 1;
});

StateProvider<int> instructionCountProvider = StateProvider<int>((ref) {
  return 1;
});
final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

class EditRecipe extends ConsumerWidget {
  EditRecipe({Key? key, required this.recipe}) : super(key: key) {
    ingredientCountProvider = StateProvider<int>((ref) {
      return recipe.nutrition!.ingredients.length;
    });
    instructionCountProvider = StateProvider<int>((ref) {
      return recipe.analyzedInstructions[0].steps.length;
    });
  }

  Result recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<Result>? customRecipes = ref.watch(customRecipesProvider);
    return Scaffold(
        body: Container(child: editRecipeForm(context, ref, customRecipes)));
  }

  editRecipeForm(
      BuildContext context, WidgetRef ref, List<Result>? customRecipes) {
    int instructionCount = ref.watch(instructionCountProvider);
    int ingredientCount = ref.watch(ingredientCountProvider);

    return SingleChildScrollView(
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
                      decoration: InputDecoration(labelText: 'Recipe Title'),
                      validator: FormBuilderValidators.required(),
                      initialValue: recipe != null ? recipe.title : ""),
                  //Recipe Image Form Input
                  FormBuilderTextField(
                      name: 'recipeImage',
                      decoration: InputDecoration(labelText: 'Recipe Image'),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.match(
                            '^(https?|ftp):\\/\\/[^\\s/\$.?#].[^\\s]*\$')
                      ]),
                      initialValue: recipe != null ? recipe.image : ""),
                  //Recipe Cuisine Form Input
                  FormBuilderTextField(
                      name: 'cuisine',
                      decoration: InputDecoration(labelText: 'Cuisine'),
                      validator: FormBuilderValidators.required(),
                      initialValue: recipe != null ? recipe.cuisines[0] : ""),
                  //Recipe Calories Form Input
                  FormBuilderTextField(
                      name: 'calories',
                      decoration: InputDecoration(labelText: 'Calories'),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(),
                        FormBuilderValidators.min(0)
                      ]),
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      initialValue: recipe != null
                          ? recipe.nutrition?.nutrients[0].amount.toString()
                          : ""),
                  //Recipe Ready Time Form Input
                  FormBuilderTextField(
                      name: 'readyTime',
                      decoration:
                          InputDecoration(labelText: 'Ready Time (in minutes)'),
                      keyboardType: const TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: FormBuilderValidators.required(),
                      initialValue: recipe != null
                          ? recipe.readyInMinutes.toString()
                          : ""),
                  //Dietary Restrictions
                  FormBuilderFilterChip(
                      name: "diets",
                      options: [
                        FormBuilderChipOption(
                            value: 'vegan', child: Text("Vegan")),
                        FormBuilderChipOption(
                            value: 'vegetarian', child: Text("Vegetarian")),
                        FormBuilderChipOption(
                            value: 'pescetarian', child: Text("Pescetarian")),
                        FormBuilderChipOption(
                            value: 'glutenFree', child: Text("Gluten Free")),
                        FormBuilderChipOption(
                            value: 'dairyFree', child: Text("Dairy Free")),
                        FormBuilderChipOption(
                            value: 'peanutFree', child: Text("Peanut Free"))
                      ],
                      decoration: const InputDecoration(
                          labelText: "Dietary Restrictions"),
                      selectedColor: const Color.fromARGB(255, 0, 136, 204),
                      checkmarkColor: Colors.white,
                      autovalidateMode: AutovalidateMode.always,
                      validator: (value) {
                        if (value == null) {
                          return null;
                        }
                        if (value!.contains("vegan") &&
                            value!.contains("pescetarian")) {
                          return 'Recipe cannot be vegan and pesecatarian';
                        } else if (value!.contains("vegetarian") &&
                            value!.contains("pescetarian")) {
                          return 'Recipe cannot be vegetarian and pesecatarian';
                        }
                        return null;
                      },
                      initialValue: recipe != null ? recipe.diets : [""]),
                  const Divider(
                    height: 100,
                    color: const Color.fromARGB(255, 0, 136, 204),
                    thickness: 5,
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "Instructions",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      )),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      //Number of ingredients
                      itemCount: ref.watch(instructionCountProvider),
                      //Used to build instruction list tiles
                      itemBuilder: (context, index) {
                        return FormBuilderTextField(
                            name: 'instruction${index + 1}',
                            decoration: InputDecoration(
                                labelText: 'Instruction ${index + 1}'),
                            maxLines: 5,
                            validator: FormBuilderValidators.required(),
                            initialValue: recipe != null &&
                                    recipe.analyzedInstructions[0].steps
                                            .length >
                                        index
                                ? recipe
                                    .analyzedInstructions[0].steps[index].step
                                : "");
                      }),
                  Row(children: [
                    //Add Ingredients Button
                    Expanded(
                        child: IconButton(
                            onPressed: () => {
                                  ref
                                      .read(instructionCountProvider.notifier)
                                      .state = ++instructionCount
                                },
                            icon: Icon(Icons.add_circle_outlined))),
                    //Remove Ingredients Button
                    Expanded(
                        child: IconButton(
                            onPressed: () => {
                                  ref
                                      .read(instructionCountProvider.notifier)
                                      .state = --instructionCount
                                },
                            icon: Icon(Icons.remove_circle_outlined)))
                  ]),
                  const Divider(
                    height: 100,
                    color: const Color.fromARGB(255, 0, 136, 204),
                    thickness: 5,
                  ),
                  Container(
                      alignment: Alignment.center,
                      child: const Text(
                        "Ingredients",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      )),
                  Padding(padding: EdgeInsets.only(bottom: 10)),
                  ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      //Number of ingredients
                      itemCount: ref.watch(ingredientCountProvider),
                      //Used to build instruction list tiles
                      itemBuilder: (context, index) {
                        return Column(children: [
                          const Padding(padding: EdgeInsets.only(top: 30)),
                          Container(
                              alignment: Alignment.topLeft,
                              child: Text(
                                "Ingredient ${index + 1}",
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              )),
                          FormBuilderTextField(
                              name: 'ingredientName${index + 1}',
                              decoration:
                                  const InputDecoration(labelText: 'Name'),
                              validator: FormBuilderValidators.required(),
                              initialValue: recipe != null &&
                                      recipe.nutrition!.ingredients.length >
                                          index
                                  ? recipe.nutrition?.ingredients[index].name
                                  : ""),
                          Row(children: [
                            Expanded(
                                child: FormBuilderTextField(
                                    name: 'ingredientAmount${index + 1}',
                                    decoration: const InputDecoration(
                                        labelText: 'Amount'),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            signed: true, decimal: true),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    validator: FormBuilderValidators.compose([
                                      FormBuilderValidators.required(),
                                      FormBuilderValidators.min(0)
                                    ]),
                                    initialValue: recipe != null &&
                                            recipe.nutrition!.ingredients
                                                    .length >
                                                index
                                        ? recipe.nutrition?.ingredients[index]
                                            .amount
                                            .toString()
                                        : "")),
                            Expanded(
                                child: FormBuilderTextField(
                                    name: 'ingredientUnit${index + 1}',
                                    decoration:
                                        InputDecoration(labelText: 'Unit'),
                                    validator: FormBuilderValidators.required(),
                                    initialValue: recipe != null &&
                                            recipe.nutrition!.ingredients
                                                    .length >
                                                index
                                        ? recipe
                                            .nutrition?.ingredients[index].unit
                                        : "")),
                          ]),
                        ]);
                      }),
                  Row(children: [
                    //Add Ingredients Button
                    Expanded(
                        child: IconButton(
                            onPressed: () => {
                                  ref
                                      .read(ingredientCountProvider.notifier)
                                      .state = ++ingredientCount
                                },
                            icon: Icon(Icons.add_circle_outlined))),
                    //Remove Ingredients Button
                    Expanded(
                        child: IconButton(
                            onPressed: () => {
                                  ref
                                      .read(ingredientCountProvider.notifier)
                                      .state = --ingredientCount
                                },
                            icon: Icon(Icons.remove_circle_outline)))
                  ]),
                  const Divider(
                    height: 100,
                    color: const Color.fromARGB(255, 0, 136, 204),
                    thickness: 5,
                  ),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.saveAndValidate()) {
                        // Handle form data submission
                        final formData = _formKey.currentState!.value;
                        print(formData);
                        onEdit(formData, ref, recipe!.firebaseID);
                        Navigator.pop(context);
                      }
                    },
                    child: Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Close'),
          )
        ]));
  }

  onEdit(Map<String, dynamic> formData, WidgetRef ref,
      [String recipeId = ""]) async {
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
    Result newRecipe = Result(
        title: formData["recipeTitle"],
        image: formData["recipeImage"] == null ? "" : formData["recipeImage"],
        cuisines: [formData["cuisine"]],
        readyInMinutes: int.parse(formData["readyTime"]),
        vegan: formData["isVegan"] == null ? false : true,
        vegetarian: formData["isVegetarian"] == null ? false : true,
        analyzedInstructions: [instructions],
        servings: 1,
        nutrition: nutrition);
    newRecipe.nutrition = nutrition;
    newRecipe.firebaseID = recipe.firebaseID;

    List<dynamic> dietList = [];
    if (formData["diets"] != null) {
      if (formData["diets"].contains("vegan")) {
        newRecipe.vegan = true;
        dietList.add("vegan");
      }
      if (formData["diets"].contains("vegetarian")) {
        newRecipe.vegetarian = true;
        dietList.add("vegetarian");
      }
      if (formData["diets"].contains("pescetarian")) {
        newRecipe.diets.add("pescetarian");
        dietList.add("pescetarian");
      }
      if (formData["diets"].contains("glutenFree")) {
        newRecipe.glutenFree = true;
        dietList.add("glutenFree");
      }
      if (formData["diets"].contains("dairyFree")) {
        newRecipe.dairyFree = true;
        dietList.add("dairyFree");
      }
      if (formData["diets"].contains("peanutFree")) {
        dietList.add("peanutFree");
      }
      if (formData["diets"].contains("ketogenic")) {
        dietList.add("ketogenic");
      }
      if (formData["diets"].contains("dairyFree")) {
        dietList.add("dairy");
      }
      if (formData["diets"].contains("peanutFree")) {
        dietList.add("peanut");
      }
      if (formData["diets"].contains("seafoodFree")) {
        dietList.add("seafood");
      }
      if (formData["diets"].contains("shellfishFree")) {
        dietList.add("shellfish");
      }
      if (formData["diets"].contains("soyFree")) {
        dietList.add("soy");
      }
    }
    newRecipe.diets = dietList;
    print(newRecipe.toMap());

    // Create an instance of FirebaseAuth
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Get the current user's uid
    final userID = auth.currentUser?.uid;

    //reference to Custom_Recipes collection in firebase
    final recipeCollection =
        FirebaseFirestore.instance.collection("Custom_Recipes");

    //Update recipe with new info
    recipeCollection.doc(newRecipe.firebaseID).update({
      "uid": userID,
      "recipe": newRecipe.toMap(),
      "saveDate": DateTime.now()
    });

    //Reset ingredient and instruction counts to 1
    ref.read(instructionCountProvider.notifier).state = 1;
    ref.read(ingredientCountProvider.notifier).state = 1;
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

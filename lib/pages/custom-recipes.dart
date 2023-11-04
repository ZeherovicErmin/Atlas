import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/Models/recipe-model.dart' as RecipeModel show Step;
import 'package:atlas/pages/recipe-details.dart';
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

class CustomRecipes extends ConsumerWidget {
  const CustomRecipes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    //List of custom recipes, updated when user adds/removes
    List<Result>? customRecipes = ref.watch(customRecipesProvider);
    return Scaffold(
        body: Column(
          children: [
            Container(
              alignment: Alignment.center,
              child: IconButton(
                onPressed: addRecipeDialog(context, ref),
                icon: Icon(Icons.add_circle),
                iconSize: 40,
              )
            ),
            customRecipeList(customRecipes)]));
  }

  addRecipeDialog(BuildContext context, WidgetRef ref) {
    return () => showDialog<String>(
        context: context,
        builder: (BuildContext context) => Dialog(
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
                              FormBuilderTextField(
                                name: 'recipeTitle',
                                decoration:
                                    InputDecoration(labelText: 'Recipe Title'),
                                validator: FormBuilderValidators.required(),
                              ),
                              FormBuilderTextField(
                                name: 'recipeImage',
                                decoration:
                                    InputDecoration(labelText: 'Recipe Image'),
                                    //Compose is used for multiple validators
                                validator: FormBuilderValidators.compose([
                                  FormBuilderValidators.required()])
                              ),
                              FormBuilderTextField(
                                name: 'cuisine',
                                decoration:
                                    InputDecoration(labelText: 'Cuisine'),
                                validator: FormBuilderValidators.required(),

                              ),
                              FormBuilderTextField(
                                name: 'calories',
                                decoration:
                                    InputDecoration(labelText: 'Calories'),
                                keyboardType: TextInputType.number,
                              ),
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
                                title: Text('Is it Vegetarian?')
                              ),
                              FormBuilderTextField(
                                name: 'instructions',
                                decoration:
                                    InputDecoration(labelText: 'Instructions'),
                                maxLines: 5,
                              ),
                              FormBuilderTextField(
                                name: 'ingredientName',
                                decoration: InputDecoration(
                                    labelText: 'Ingredient Name'),
                              ),
                              FormBuilderTextField(
                                name: 'ingredientAmount',
                                decoration: InputDecoration(
                                    labelText: 'Ingredient Amount'),
                              ),
                              FormBuilderTextField(
                                name: 'ingredientUnit',
                                decoration: InputDecoration(
                                    labelText: 'Ingredient Unit'),
                              ),
                              SizedBox(height: 20),
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
                    ])))));
  }

  customRecipeList(List<Result>? customRecipes){
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
                      itemCount: customRecipes!.length,
                      //Used to build recipe list tiles
                      itemBuilder: (context, index) {
                        Result recipe = customRecipes[index];
                        String recipeName = recipe.title;
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
                                                    .all<Color>(Color.fromARGB(
                                                        255, 255, 162, 23))),
                                        onPressed: () =>
                                            navigateToRecipeDetails(
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
                                                  onPressed: () => onRemove(
                                                      recipe,
                                                      context,
                                                      customRecipesProvider),
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
  }
  onAdd(Map<String, dynamic> formData, WidgetRef ref) {
    Nutrient nutrient = Nutrient(
        name: "Calories",
        amount: double.parse(formData["calories"]),
        unit: "kcal",
        percentOfDailyNeeds: 56.05);

   Ingredient ingredients = Ingredient(
        id: 0,
        amount: double.parse(formData["ingredientAmount"]),
        name: formData["ingredientName"],
        unit: formData["ingredientUnit"],
        nutrients: []);

    RecipeModel.Step step = RecipeModel.Step(
        number: 1,
        step: formData["instructions"],
        ingredients: [],
        equipment: []);

    AnalyzedInstruction instructions =
        AnalyzedInstruction(name: "", steps: [step]);

    Nutrition nutrition = Nutrition(
        nutrients: [nutrient], 
        ingredients: [ingredients],
        properties: [],
        flavonoids: [],
        caloricBreakdown: CaloricBreakdown(
          percentCarbs: 0.0,
          percentFat: 0.0,
          percentProtein: 0.0
        ),
        weightPerServing: WeightPerServing(amount: 0, unit: "unit"));

    Result recipe = Result(
        title: formData["recipeTitle"],
        image: formData["recipeImage"],
        cuisines: [formData["cuisine"]],
        readyInMinutes: int.parse(formData["readyTime"]),
        vegan: formData["isVegan"],
        vegetarian: formData["isVegetarian"],
        analyzedInstructions: [instructions],
        servings: 1,
        nutrition: nutrition
        );

    print(recipe.toMap());
    List<Result> recipes = [...ref.watch(customRecipesProvider)];
    recipes.add(recipe);
    ref.read(customRecipesProvider.notifier).state = recipes;
  }

  
  onRemove(Result recipe, BuildContext context, StateProvider<List<Result>> customRecipesProvider) {}

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

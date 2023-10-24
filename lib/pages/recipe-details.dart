import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/pages/constants.dart';
import 'package:atlas/pages/recipe-info.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeDetails extends ConsumerWidget {
  const RecipeDetails({Key? key, required this.recipe}) : super(key: key);
  final Result recipe; //recipe object

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 136, 204),
      ),
      body: Column(children: [
        Expanded(
            child: ListView(
                // ignore: prefer_const_constructors
                children: [
              recipeImage(),
              recipeInformation(),
              //margin for spacing
              Container(margin: const EdgeInsets.only(top: 10, bottom: 10)),
              // recipeIngredients(),
              // //margin for spacing
              // Container(margin: const EdgeInsets.only(top: 10, bottom: 10)),
              // recipeInstructions(),
              SizedBox(
                  width: 200, height: 400, child: RecipeInfo(recipe: recipe))
            ])),
      ]),
      backgroundColor: Color.fromARGB(255, 255, 253, 251),
    );
  }

  Widget gradient() {
    return Container(
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
        child: Column(
          children: [
            Expanded(
                child: ListView(
                    // ignore: prefer_const_constructors
                    children: [
                  recipeImage(),
                  recipeInformation(),
                  //margin for spacing
                  Container(margin: const EdgeInsets.only(top: 10, bottom: 10)),
                  recipeIngredients(),
                  //margin for spacing
                  Container(margin: const EdgeInsets.only(top: 10, bottom: 10)),
                  recipeInstructions(),
                ]))
          ],
        ));
  }

  Widget recipeInformation() {
    //Recipe calories
    int calories = recipe.nutrition.nutrients[0].amount.ceil();

    return Column(
      children: [
        //recipe title
        Text(recipe.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        //Recipe Cuisine
        Text(
            "Cuisine: " +
                (recipe.cuisines.isNotEmpty ? recipe.cuisines[0] : "N/A"),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        //Recipe Calories, Servings, and Ready Time
        Row(
            //Centers row content
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Recipe Calories
              Text("Calories: $calories",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              //Recipe Servings
              Text("   Servings: ${recipe.servings}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
              //Recipe Ready Time
              Text("   Ready Time: ${recipe.readyInMinutes} min",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15)),
            ]),
      ],
    );
  }

  Widget recipeIngredients() {
    //Expandable section
    return ExpansionTile(
      title: const Text("INGREDIENTS: ",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      //Make the arrow appear before the title
      controlAffinity: ListTileControlAffinity.leading,
      collapsedTextColor: Colors.black,
      children: [
        //Outputs each ingredient in the ingredients list
        ListView.builder(
            shrinkWrap: true,
            //Used to ensure list is scrollable
            physics: const NeverScrollableScrollPhysics(),
            //Number of ingredients
            itemCount: recipe.nutrition.ingredients.length,
            //Used to build instruction list tiles
            itemBuilder: (context, index) {
              //recipe igredient
              Ingredient ingredient = recipe.nutrition.ingredients[index];
              //Amount of the ingredient
              var ingredientAmount = ingredient.amount;
              //Formatted ingredient string with amount and unit
              String ingredientFormatted =
                  "${ingredient.name} - $ingredientAmount ${ingredient.unit}";

              return ListTile(
                  title: Text(ingredientFormatted,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontWeight: FontWeight.bold)));
            })
      ],
    );
  }

  Widget recipeImage() {
    return Card(
        elevation: 3,
        color: const Color(0xffA9B7FF),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color.fromARGB(255, 114, 138, 255)),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              recipe.image,
              height: 200,
              fit: BoxFit.fill,
            )));
  }

  Widget recipeInstructions() {
    //if this recipe does not contain instructions, return a message
    //notifying the user. If it does, output the instructions
    if (recipe.analyzedInstructions.isEmpty) {
      return const ExpansionTile(
        title: Text("INSTRUCTIONS: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        controlAffinity: ListTileControlAffinity.leading,
        collapsedTextColor: Colors.black,
        children: [Text("Sorry! This Recipe Does Not Contain Instructions")],
      );
    } else {
      return ExpansionTile(
        title: const Text("INSTRUCTIONS: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        controlAffinity: ListTileControlAffinity.leading,
        collapsedTextColor: Colors.black,
        children: [
          ListView.builder(
              shrinkWrap: true,
              //Used to ensure list is scrollable
              physics: const NeverScrollableScrollPhysics(),
              //Number of instructions
              itemCount: recipe.analyzedInstructions[0].steps.length,
              //Used to build instruction list tiles
              itemBuilder: (context, index) {
                final instruction = recipe.analyzedInstructions[0].steps[index];
                String step = instruction.step;
                var stepCount = index + 1;
                String instructionTitle = "$stepCount.) $step ";
                return ListTile(
                    title: Text(instructionTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold)));
              }),
        ],
      );
    }
  }
}

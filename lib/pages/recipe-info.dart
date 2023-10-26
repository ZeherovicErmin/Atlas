import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/pages/constants.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeInfo extends StatefulWidget {
  const RecipeInfo({super.key, required this.recipe});
  final Result recipe;

  @override
  State<RecipeInfo> createState() => _RecipeInfoState();
}

class _RecipeInfoState extends State<RecipeInfo> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: DefaultTabController(
            length: 2,
            child: Scaffold(
                body: Column(children: [
              Container(
                  color: Colors.orange,
                  child: TabBar(tabs: const [
                    Tab(text: "Ingredients"),
                    Tab(text: "Instructions")
                  ])),
              Expanded(
                  child: Container(
                      color: Color.fromARGB(115, 255, 153, 0),
                      child: TabBarView(children: [
                        recipeIngredients(widget.recipe),
                        recipeInstructions(widget.recipe)
                      ])))
            ]))));
  }

  Widget recipeIngredients(Result recipe) {
    //Expandable section
    return
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
                  "• ${ingredient.name} - $ingredientAmount ${ingredient.unit}";

              return ListTile(
                  title: Text(ingredientFormatted,
                      textAlign: TextAlign.left,
                      style: const TextStyle(fontWeight: FontWeight.bold)));
            });
  }

  Widget recipeInstructions(Result recipe) {
    //if this recipe does not contain instructions, return a message
    //notifying the user. If it does, output the instructions
    if (recipe.analyzedInstructions.isEmpty) {
      return Text("INSTRUCTIONS: EMPTY",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20));
    } else {
      return Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: ListView.builder(
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
                        textAlign: TextAlign.left,
                        style: const TextStyle(fontWeight: FontWeight.bold)));
              }));
    }
  }
}

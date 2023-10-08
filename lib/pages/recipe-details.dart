import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/pages/constants.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeDetails extends ConsumerWidget {
  const RecipeDetails({Key? key, required this.recipe}) : super(key: key);
  final Result recipe; //recipe object

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: myAppBar2(context, ref, 'Recipes'), body: gradient());
  }

  Widget gradient() {
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
        child: Column(
          children: [
            Expanded(
                child: ListView(
              children: [
                recipeImage(),
                recipeInformation(),
                Container(margin: const EdgeInsets.only(top: 10, bottom: 10)),
                //recipeIngredients(),
                Container(margin: const EdgeInsets.only(top: 10, bottom: 10)),
                recipeInstructions(),
              ],
            ))
          ],
        ));
  }

  Widget recipeInformation() {
    return Column(
      children: [
        Text(recipe.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        Text(
            "Cuisine: " +
                //if cuisine list is empty, return N/A, else return first result
                //in cuisine list
                (recipe.cuisines.isNotEmpty ? recipe.cuisines[0] : "N/A"),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
    return Column(
      children: [
        const Text("INSTRUCTIONS: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Padding(
            padding: EdgeInsets.all(5),
            //outputs all recipe instructions
            child: ListView.builder(
                shrinkWrap: true,
                //Used to ensure list is scrollable
                physics: const AlwaysScrollableScrollPhysics(),
                //Number of instructions
                itemCount: recipe.analyzedInstructions[0].steps.length,
                //Used to build instruction list tiles
                itemBuilder: (context, index) {
                  var currentStep = recipe.analyzedInstructions[0].steps[index];
                  String instruction = currentStep.step; //Instruction
                  int stepNumber = index + 1;
                  String instructionFormatted = "$stepNumber) $instruction ";
                  return ListTile(
                      title: Text(instructionFormatted,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold)));
                })),
      ],
    );
  }
}

AppBar appBar() {
  String userName = 'DEV';
  return AppBar(
    title: Text('Welcome, $userName!',
        style: const TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 18,
            fontWeight: FontWeight.bold)),
    backgroundColor: const Color(0xffA9B7FF),
  );
}

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
        title: const Padding(
            padding: EdgeInsets.only(left: 35),
            child: Text("Recipes Details",
                style: TextStyle(fontWeight: FontWeight.bold))),
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
              SizedBox(
                  width: 200, height: 400, child: RecipeInfo(recipe: recipe))
            ])),
      ]),
      backgroundColor: Color.fromARGB(255, 255, 253, 251),
    );
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
        Padding(padding: EdgeInsets.all(7)),
        Row(
            //Centers row content
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Recipe Calories
              Container(
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Text("Calories: $calories",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15))),
              //Recipe Servings
              Container(
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Text("Servings: ${recipe.servings}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15))),
              //Recipe Ready Time
              Container(
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.all(Radius.circular(25))),
                  child: Text("Ready Time: ${recipe.readyInMinutes} min",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15))),
            ]),
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
}

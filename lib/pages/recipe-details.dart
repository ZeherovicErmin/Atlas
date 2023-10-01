import 'package:atlas/pages/constants.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecipeDetails extends ConsumerWidget {
  const RecipeDetails({Key? key, required this.recipes}) : super(key: key);
  final Map<String, dynamic> recipes;

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
                recipeIngredients(),
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
        Text(recipes["strMeal"],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        Text("Cuisine: " + recipes["strArea"],
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget recipeIngredients() {
    String ingredients = "";
    if (recipes["strIngredient1"] != "" && recipes["strIngredient1"] != null) {
      ingredients += recipes["strIngredient1"] + ", ";
    }
    if (recipes["strIngredient2"] != "" && recipes["strIngredient2"] != null) {
      ingredients += recipes["strIngredient2"] + ", ";
    }
    if (recipes["strIngredient3"] != "" && recipes["strIngredient3"] != null) {
      ingredients += recipes["strIngredient3"] + ", ";
    }
    if (recipes["strIngredient4"] != "" && recipes["strIngredient4"] != null) {
      ingredients += recipes["strIngredient4"] + ", ";
    }
    if (recipes["strIngredient5"] != "" && recipes["strIngredient5"] != null) {
      ingredients += recipes["strIngredient5"] + ", ";
    }
    if (recipes["strIngredient6"] != "" && recipes["strIngredient6"] != null) {
      ingredients += recipes["strIngredient6"] + ", ";
    }
    if (recipes["strIngredient7"] != "" && recipes["strIngredient7"] != null) {
      ingredients += recipes["strIngredient7"] + ", ";
    }
    if (recipes["strIngredient8"] != "" && recipes["strIngredient8"] != null) {
      ingredients += recipes["strIngredient8"] + ", ";
    }
    if (recipes["strIngredient9"] != "" && recipes["strIngredient9"] != null) {
      ingredients += recipes["strIngredient9"] + ", ";
    }
    if (recipes["strIngredient10"] != "" &&
        recipes["strIngredient10"] != null) {
      ingredients += recipes["strIngredient10"] + ", ";
    }

    if (ingredients.endsWith(", ")) {
      ingredients = ingredients.substring(0, ingredients.length - 2);
    }

    return Column(
      children: [
        Text("Ingredients: $ingredients",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
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
              recipes["strMealThumb"],
              height: 200,
              fit: BoxFit.fill,
            )));
  }

  Widget recipeInstructions() {
    return Column(
      children: [
        const Text("INSTRUCTIONS: ",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        Card(
          elevation: 1,
          color: const Color(0xffA9B7FF),
          child: SizedBox(
            width: 300,
            child: Padding(
              padding: EdgeInsets.all(15.0),
              child: Center(
                  child: Text(
                recipes["strInstructions"],
              )),
            ),
          ),
        )
      ],
    );
  }
}

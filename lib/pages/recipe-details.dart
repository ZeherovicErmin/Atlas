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
        backgroundColor: Colors.orange,
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

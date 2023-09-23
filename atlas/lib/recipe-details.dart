import "package:flutter/material.dart";
import "package:atlas/recipes.dart";

class recipeDetails extends StatefulWidget {
  const recipeDetails( {super.key, required this.recipes});
  final Map<String, dynamic> recipes;

  @override
  State<recipeDetails> createState() => _recipeDetailsState();
}



class _recipeDetailsState extends State<recipeDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(),
        body: Column(children: [
          Expanded(child: ListView(
            children: [
              Image.network(widget.recipes["strMealThumb"], height: 200,),
              const Text("TITLE: "),
              Text(widget.recipes["strMeal"]),
              const Text("INSTRUCTIONS: "),
              Text(widget.recipes["strInstructions"])
            ],
          ))
        ],));
  }
}


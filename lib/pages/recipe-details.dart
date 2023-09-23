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
    return Scaffold(appBar: appBar(),
        body: gradient() 
        );
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
        child: Column(children: [
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

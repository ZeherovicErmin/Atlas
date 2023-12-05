import 'package:atlas/Models/recipe-model.dart';
import 'package:atlas/pages/recipe-info.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

StateProvider<double> servingsProvider = StateProvider<double>((ref) {
  return 1;
});

class RecipeDetails extends ConsumerWidget {
  RecipeDetails({Key? key, required this.recipe}) : super(key: key) {
    servingsProvider = StateProvider<double>((ref) {
      return recipe.servings + 0.0;
    });
    servingsController = TextEditingController(text: '${recipe.servings}');
  }
  final Result recipe; //recipe object

  //Text controller used to store value from recipe search bar
  TextEditingController servingsController = TextEditingController(text: "1");

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Recipe Details",
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color.fromARGB(255, 0, 136, 204),
      ),
      body: Column(children: [
        Expanded(
            child: ListView(
                // ignore: prefer_const_constructors
                children: [
              recipeImage(),
              recipeInformation(ref),
              //margin for spacing
              Container(margin: const EdgeInsets.only(top: 10, bottom: 10)),
              SizedBox(
                  width: 200, height: 400, child: RecipeInfo(recipe: recipe))
            ])),
      ]),
      backgroundColor: Color.fromARGB(255, 255, 253, 251),
    );
  }

  Widget recipeInformation(WidgetRef ref) {
    //Recipe calories
    double servings = ref.watch(servingsProvider);
    int calories =
        ((recipe.nutrition.nutrients[0].amount / recipe.servings) * servings)
            .ceil();

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
        SizedBox(
            height: 35,
            child: Row(children: [
              Expanded(
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                //Recipe Calories
                Container(
                    margin: EdgeInsets.only(right: 3),
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: Text("Calories: $calories",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15))),
                //Recipe Servings
                Container(
                    margin: EdgeInsets.only(right: 10),
                    padding: EdgeInsets.only(left: 7, right: 7),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: Text("Servings: ",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            height: 1.75))),
                SizedBox(
                    width: 30,
                    child: TextFormField(
                        //Controller stores value entered by user
                        controller: servingsController,
                        //Checks if value is valid, if not: show error message
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.parse(value) <= 0) {
                            return 'Please Enter A Valid Number';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(5,7.5, 5, 2)),
                        onFieldSubmitted: (value) => {
                              //convert user input from string to number and save it
                              ref.read(servingsProvider.notifier).state =
                                  double.parse(value)
                            },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        keyboardType: const TextInputType.numberWithOptions(
                            signed: true, decimal: true))),
                //Recipe Ready Time
                Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(Radius.circular(25))),
                    child: Text("Ready Time: ${recipe.readyInMinutes} min",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15))),
              ]))
            ])),
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
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/recipe-notfound.png', height: 200, fit: BoxFit.fill);
              },
            )));
  }
}

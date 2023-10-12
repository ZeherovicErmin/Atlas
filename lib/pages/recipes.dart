import 'dart:convert';
import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:atlas/pages/recipe-details.dart';

//State Provider holds recipe data
final recipeProvider = StateProvider<List<dynamic>>((ref) {
  return [];
});

//Consumer Widget that handles and displays the recipes
class Recipes extends ConsumerWidget {
  Recipes({Key? key}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //recipe provider state getter
    final recipes = ref.watch(recipeProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: myAppBar2(context, ref, 'R e c i p e s'),
      body: gradient(recipes, context, ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onSubmit(context, ref),
        child: Text('Submit'),
      ),
    );
  }

  // bg gradient color
  Widget gradient(recipes, context, ref) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 232, 229, 229),
            Color.fromARGB(255, 232, 229, 229),
          ],
        ),
      ),
      child: Column(children: [form(), recipeList(recipes, context, ref)]),
    );
  }

  Widget form() {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(15), //apply padding to all sides
        // child: Text('Welcome',
        //     style: TextStyle(
        //         color: Color.fromARGB(255, 255, 255, 255),
        //         fontSize: 18,
        //         fontWeight: FontWeight.bold)),
      ),
      Container(
        margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.11))
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(children: [searchBar()]),
        ),
      ),
    ]);
  }

  Widget searchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.0),
      ),
      child: TextFormField(
        controller: searchController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please Input A Value into Searchbar';
          }
          return null;
        },
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            border: InputBorder.none,
            hintText: "Enter Recipe Search"),
      ),
    );
  }

  // List of recipe results from the API request
  Widget recipeList(
      List<dynamic> recipes, BuildContext context, WidgetRef ref) {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final mealName = recipe['strMeal'];
                return ListTile(
                    title: Text(mealName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () => navigateToRecipeDetails(context, recipe));
              },
              separatorBuilder: (context, index) {
                return Divider();
              },
            )));
  }

  //Form Submission Handler - Submits search to API
  void onSubmit(BuildContext context, WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Searching for Recipes')));
      String value = searchController.text;
      var url = 'http://www.themealdb.com/api/json/v1/1/search.php?s=$value';
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      ref.read(recipeProvider.notifier).state = data['meals'];
    }
  }

  // Function to navigate to recipe details page
  void navigateToRecipeDetails(BuildContext context, dynamic recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetails(recipes: recipe),
      ),
    );
  }
}

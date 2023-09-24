import 'dart:convert';
import 'package:atlas/Recipes/recipe-details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;

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
      appBar: appBar(),
      body: gradient(recipes, context, ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () => onSubmit(context, ref),
        child: Text('Submit'),
      ),
    );
  }

  AppBar appBar() {
    //DEV needs to be removed and replaced with name of user authenticated
    String userName = 'DEV';
    return AppBar(
      title: Text(
        'Welcome, $userName!',
        style: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color(0xffA9B7FF),
      leading: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SvgPicture.asset(
          'assets/icons/burger-menu.svg',
          height: 20,
          width: 20,
        ),
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
            Color.fromARGB(255, 90, 117, 255),
            Color.fromARGB(255, 161, 195, 250),
          ],
        ),
      ),
      child: Column(
        children: [
          form(), 
          recipeList(recipes, context, ref)
        ]
      ),
    );
  }



 Widget form(){
  return  Column(
    children: [
      const Padding(
        padding: EdgeInsets.all(15), //apply padding to all sides
        child: Text('Recipes',
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      Container(
        margin: const EdgeInsets.only(top: 40, left: 20, right: 20),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: const Color.fromARGB(255, 88, 34, 194).withOpacity(0.11))
            ],
        ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            searchBar()
          ]
        ),
      ),
    ),  
  ]);
}

  Widget searchBar() {
    return TextFormField(
      controller: searchController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please Input A Value into Searchbar';
        }
        return null;
      },
      decoration:
          const InputDecoration(filled: true, fillColor: Colors.white),
    );
  }

 
  // List of recipe results from the API request
  Widget recipeList(List<dynamic> recipes, BuildContext context, WidgetRef ref){
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
              title: Text(
                  mealName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold)
              ),
              onTap: () => navigateToRecipeDetails(context, recipe)
            );
          },
          separatorBuilder: (context,index){
            return Divider();
          },
        )
      )
    );
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
 
  

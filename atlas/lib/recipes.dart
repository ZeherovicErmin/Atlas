import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class Recipes extends StatefulWidget {
  const Recipes({super.key});

  @override
  _resultsState createState() => _resultsState();
}

class _resultsState extends State<Recipes> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController searchController = TextEditingController();
  List<dynamic> recipes = [];

  @override
  Widget build(BuildContext conext) {
    return Scaffold(
        appBar: appBar(),
        body: gradient());
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
        child: searchBar());
  }

  Widget searchBar() {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.all(15), //apply padding to all four sides
        child: Text('Recipes',
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 18,
                fontWeight: FontWeight.bold)),
      ),
      Container(
          margin: EdgeInsets.only(top: 40, left: 20, right: 20),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Color.fromARGB(255, 88, 34, 194).withOpacity(0.11))
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                controller: searchController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Input A Value into Searchbar';
                  }
                },
                decoration:
                    InputDecoration(filled: true, fillColor: Colors.white),
                // alignLabelWithHint: filled:border: )
              ),
              button(),
            ]),
          ),

    )]);
  }

  FloatingActionButton button() {
    return FloatingActionButton(
      onPressed: onSubmit,
      child: Text('Submit'),
    );
  }

 void onSubmit() async {
    if (_formKey.currentState!.validate()) {
      //print('Onsubmit called');
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Searching for Recipes')));
      String value = searchController.text;
      var url = 'http://www.themealdb.com/api/json/v1/1/search.php?s=$value';
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      final data = jsonDecode(response.body);
      setState(() {
        recipes = data['meals'];
      });
      //print("fetch completed");
    }
  }
}

  AppBar appBar() {
    String userName = 'John Smith';
    return AppBar(
      title: Text('Welcome, $userName!',
          style: const TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      backgroundColor: Color(0xffA9B7FF),
      leading: Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: SvgPicture.asset('assets/icons/burger-menu.svg',
              height: 20, width: 20),
          decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(10))),
    );
  }


import 'dart:async';
import 'package:atlas/components/feed_post.dart';
import 'package:flutter/cupertino.dart';
import 'package:atlas/components/productHouser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:auto_size_text/auto_size_text.dart';
//import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

//paramaters to hold search, sort, filter
class FilterState {
  String? searchTerm;
  String? sortBy;
  String? filterBy;
  bool isAscending;

  FilterState(
      {this.searchTerm, this.sortBy, this.filterBy, this.isAscending = true});
}

// Create a provider to work with the data
final filterStateProvider =
    StateNotifierProvider<FilterStateController, FilterState>((ref) {
  return FilterStateController();
});

// Filter State Controller
class FilterStateController extends StateNotifier<FilterState> {
  FilterStateController() : super(FilterState());

  // Update search term
  void updateSearchTerm(String term) {
    state = FilterState(
        searchTerm: term, sortBy: state.sortBy, filterBy: state.filterBy);
  }

  // Update sort by option
  void updateSortBy(String sortBy) {
    state = FilterState(
        searchTerm: state.searchTerm, sortBy: sortBy, filterBy: state.filterBy);
  }

  // Update filter by option
  void updateFilterBy(String filterBy) {
    state = FilterState(
        searchTerm: state.searchTerm, sortBy: state.sortBy, filterBy: filterBy);
  }
}

class BarcodeLogPage extends ConsumerWidget {
  BarcodeLogPage({Key? key});
  final currentUser = FirebaseAuth.instance.currentUser!;
  final content = NutritionalModalClass(
      //productName: ''
      );

  String formatDecimal(double value) {
    // Round to one decimal place and format as a string
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    log("The user id is = $uid");

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 229, 229),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            leading: const Icon(
              null,
              ),
            centerTitle: true,
            backgroundColor: const Color.fromARGB(255, 0, 136, 204),
            floating: true,
            title: TextField(
              onChanged: (value) => ref
                  .read(filterStateProvider.notifier)
                  .updateSearchTerm(value),
              decoration: const InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.white),
              ),
            ),

            // Sorting Menu in the App Bar itself
            actions: [
              PopupMenuButton<String>(
                // Sorting functionality
                onSelected: (value) =>
                    ref.read(filterStateProvider.notifier).updateSortBy(value),
                itemBuilder: (context) => [
                  'Sort Alphabetical',
                  'Sort by Protein',
                  'Sort by Carbs',
                  'Sort by Fats'
                ].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(choice),
                        if (ref.read(filterStateProvider).sortBy == choice)
                          Icon(ref.read(filterStateProvider).isAscending
                              ? Icons.arrow_upward
                              : Icons.arrow_downward),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          SliverFillRemaining(child: _buildStreamBuilder(context, uid)),
        ],
      ),
    );
  }

  Widget _buildGradient(BuildContext context, WidgetRef ref, String? uid) {
    return Scaffold(
      extendBody: true,
      body: _buildStreamBuilder(context, uid),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildStreamBuilder(BuildContext context, String? uid) {
    return Consumer(
      builder: (context, ref, _) {
        final filterState = ref.watch(filterStateProvider);
        Query query = FirebaseFirestore.instance
            .collection('Barcode_Lookup')
            .where('uid', isEqualTo: uid);

        // Determine sorting field first
        String? orderByField;
        bool ascendingOrder = true; // Default to ascending order
        if (filterState.sortBy != null) {
          switch (filterState.sortBy) {
            case 'Sort Alphabetical':
              orderByField = 'productName';
              break;
            case 'Sort by Protein':
              orderByField = 'proteinPerServing';
              break;
            case 'Sort by Carbs':
              orderByField = 'carbsPerServing';
              break;
            case 'Sort by Fats':
              orderByField = 'fatsPerServing';
              break;
            default:
              orderByField = 'timestamp';
              break;
          }
        }

        if (filterState.searchTerm != null &&
            filterState.searchTerm!.isNotEmpty) {
          String searchTermLower = filterState.searchTerm!.toLowerCase();
          query = query
              .orderBy('productName_lowercase')
              .startAt([searchTermLower]).endAt(['$searchTermLower\uf8ff']);

          // If user already decided on an orderBy field, apply it here.
          if (orderByField != null) {
            query = query.orderBy(orderByField);
          }
        } else if (orderByField != null) {
          // If there's no search term, just apply the orderBy
          query = query.orderBy(orderByField);
        }

        return StreamBuilder(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const CircularProgressIndicator();
              }
              final logs = snapshot.data!.docs;
              //If no barcode logs are present
              if (logs.isEmpty) {
                return _buildEmptyCard(context, ref);
              }
              return _buildListView(logs);
            });
      },
    );
  }

  Widget _buildEmptyCard(BuildContext context, WidgetRef ref) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(top: 10.0),
        height: 175.0,
        width: 380.0,
        child: Card(
          elevation: 5,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.black, width: 5),
            borderRadius: BorderRadius.circular(24),
          ),
          child: InkWell(
            onTap: () {
              // Add the logic you want when the card is tapped
              print("Card tapped!");

              BarcodeLookupComb().scanBarcode(context, ref);
            },
            borderRadius:
                BorderRadius.circular(24), // Match with the card's shape
            child: Row(
              children: [
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, bottom: 8.0),
                          child: Text(
                            'Instructions:',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
                          child: Text(
                            '1. Click this card',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
                          child: Text(
                            '2. Open your camera',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
                          child: Text(
                            '3. Scan the barcode',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 140,
                  child: const VerticalDivider(
                    color: Color.fromARGB(255, 0, 0, 0),
                    thickness: 3.0,
                    width: 2.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 125,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.blue,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt, // Camera icon
                        size: 48.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(dynamic logs) {
    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final data = logs[index].data() as Map<String, dynamic>;

        //Captures doc ID for the current log
        String docId = logs[index].id;
        data['docId'] = docId;

        if (data.containsKey('uid')) {
          data['uid'] = ''; // Make the 'uid' row empty
        }

        final fatsPerServing = formatDecimal(data['fatsPerServing']);
        final carbsPerServing = formatDecimal(data['carbsPerServing']);
        final proteinPerServing = formatDecimal(data['proteinPerServing']);
        final cholesterolPerServing =
            formatDecimal(data['cholesterolPerServing']);
        final caloriesPerServing = formatDecimal(data['productCalories']);
        final satfatsPserving = formatDecimal(data["satfatsPserving"]);
        final sodiumPerServing = formatDecimal(data["sodiumPerServing"]);
        final transfatsPserving = formatDecimal(data["transfatsPserving"]);
        final amtServings = formatDecimal(data["amtServingsProvider"]);
        return Slidable(
          // Allows logs to be deleted, Wraps entire list widget

          key: ValueKey(logs[index].id),

          startActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: .25,
            children: [
              SlidableAction(
                autoClose: true,
                onPressed: (context) => deleteLog(context, data),
                backgroundColor: const Color.fromARGB(2, 140, 215, 85),
                foregroundColor: const Color.fromARGB(255, 255, 0, 0),
                icon: Icons.delete,
                label: 'Delete',
              )
            ],
          ),
          //Sliding to the rihgt activates sharing a post
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            extentRatio: .25,
            children: [
              SlidableAction(
                autoClose: true,
                onPressed: (context) => shareBarcodeToFeed(data),
                backgroundColor: const Color.fromARGB(2, 140, 215, 85),
                foregroundColor: Color.fromARGB(255, 0, 78, 12),
                icon: Icons.share,
                label: 'Share',
              )
            ],
          ),
          //card for the barcode logs
          // This shows in the list of logs
          child: Card(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 3.8),
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 7, // Card-like appearance
            margin: const EdgeInsets.all(12), // Margin for spacing
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              // Logic for showing a nutritional label
              onTap: () {
                Widget modalContent = NutritionContainer(
                    carbsPerServing,
                    proteinPerServing,
                    fatsPerServing,
                    caloriesPerServing,
                    satfatsPserving,
                    sodiumPerServing,
                    transfatsPserving,
                    cholesterolPerServing,
                    amtServings);

                showModalBottomSheet(
                  context: context,
                  builder: (context) => modalContent,
                );
                //deleteLog(context, data);
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: AutoSizeText(
                                '${data['productName']}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                minFontSize: 12,
                              ),
                            ),
                            const Divider(
                              color: Color.fromARGB(255, 0, 0, 0),
                              thickness: 3,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                  'Carbs Per Serving: ${carbsPerServing}g'),
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                      'Protein Per Serving: ${proteinPerServing}g'),
                                ),
                              ],
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child:
                                  Text('Fats Per Serving: ${fatsPerServing}g'),
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                  'Cholesterol Per Serving: ${cholesterolPerServing}g'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 170,
                        child: const VerticalDivider(
                          color: Color.fromARGB(255, 0, 0, 0),
                          thickness: 3.0,
                          width: 2.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          height: 125,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue,
                            image: const DecorationImage(
                                image: AssetImage(
                                    'assets/icons/flameiconnameplate.png'),
                                fit: BoxFit.contain),
                          ),
                          //Text over image
                          child: Stack(
                            children: [
                              Positioned(
                                top: 100,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Text(
                                    '${data['productCalories'].toInt()}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            ],
                          ),

                          //crossAxisAlignment: CrossAxisAlignment.start, de
                          // children: [
                          //   Text('Calories'),
                          //   Text('${data['productCalories']}'),
                          // ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Container NutritionContainer(
          String carbsPerServing,
          String proteinPerServing,
          String fatsPerServing,
          String calories,
          String satfatsPserving,
          String sodiumPerServing,
          String transfatsPserving,
          String cholesterolPerServing,
          String amtServings) =>
      Container(
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 252, 252),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
        ),
        child: SingleChildScrollView(
          //controller: _controller,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              //Drag Handle
              Center(
                child: Container(
                    margin: EdgeInsets.all(8.0),
                    width: 40,
                    height: 5.0,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 104, 104, 104),
                      borderRadius: BorderRadius.all(
                        Radius.circular(12.0),
                      ),
                    )),
              ),
              //NutriGridView(selectedFilters: selectedFilters, result: result, productName: productName, productCalories: productCalories, carbsPserving: carbsPserving, proteinPserving: proteinPserving, fatsPserving: fatsPserving,secondController: ScrollController()),
              //Nutritional Facts Column Sheet
              const Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Align(
                    child: Text(
                      'Nutrition Facts',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontFamily: 'Helvetica Black',
                          fontSize: 44,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              Divider(thickness: 1, color: Color.fromARGB(255, 118, 117, 117)),
              Align(
                child: Container(
                  height: 25,
                  // Stack to hold the fats and the fats variable
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${amtServings}g per container",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontFamily: 'Helvetica Black',
                            fontSize: 20,
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
              NutritionRow(
                title: "Calories",
                value: '${calories}',
                fontSize: 24,
                dividerThickness: 5,
                showDivider: false,
              ),
              //Nutritional Column Dividers
              //End NUTRITION FACTS ROW
              Divider(thickness: 5, color: Color.fromARGB(255, 0, 0, 0)),
              //Start of Nutrition rows
              //
              NutritionRow(title: 'Total Fats', value: '${fatsPerServing}'),
              //saturated Fats
              NutritionRow(
                title: 'Saturated Fat',
                value: '${satfatsPserving}',
                isSubcategory: true,
                hideIfZero: false,
              ),
              NutritionRow(
                title: 'Trans Fat',
                value: '${transfatsPserving}',
                isSubcategory: true,
                hideIfZero: false,
              ),
              //end fats

              NutritionRow(
                  title: "Total Carbohydrates", value: '${carbsPerServing}'),
              //Sugars
              NutritionRow(
                  title: "Total Sugars", isSubcategory: true, value: '${0}'),
              //end Protein

              //protein per serving
              NutritionRow(title: "Protein", value: "${proteinPerServing}"),

              //sodium
              NutritionRow(title: "Sodium", value: "${sodiumPerServing}"),

              NutritionRow(
                  title: "Cholesterol", value: '${cholesterolPerServing}'),
              //end Protein
            ]),
          ),
        ),
      );

  //sharing posts
  void shareBarcodeToFeed(Map<String, dynamic> data) {
    FirebaseFirestore.instance.collection('User Posts').add({
      'Message': 'Just scanned this barcode! Check it out!',
      'UserEmail': currentUser.email,
      'TimeStamp': Timestamp.now(),
      'barcodeData': data,
      'ExerciseName': '',
      'ExerciseType': '',
      'ExerciseMuscle': '',
      'ExerciseEquipment': '',
      'ExerciseDifficulty': '',
      'ExerciseInstructions': '',
      'Likes': [],
      'postImage': '',
    });
  }

  void deleteLog(BuildContext context, Map<String, dynamic> data) async {
    //Confirmation dialog
    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text("Are you sure you want to delete this log?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                // Cancels dialog box if cancel is pressed
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                // True if confirmed
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    //Deletes the barcode log
    if (confirmDelete == true) {
      try {
        //stores documentID into variable
        String? docId = data['docId'];

        if (docId != null) {
          await FirebaseFirestore.instance
              .collection('Barcode_Lookup')
              .doc(docId)
              .delete();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Barcode log deleted successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting barcode log: $e'),
          ),
        );
      }
    }
  }
}

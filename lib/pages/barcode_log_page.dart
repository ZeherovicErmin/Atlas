import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:atlas/components/productHouser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:flutter_slidable/flutter_slidable.dart';

//paramaters to hold search, sort, filter
class FilterState {
  String? searchTerm;
  String? sortBy;
  String? filterBy;

  FilterState({this.searchTerm, this.sortBy, this.filterBy});
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
  const BarcodeLogPage({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    log("The user id is = $uid");

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            title: TextField(
              onChanged: (value) => ref
                  .read(filterStateProvider.notifier)
                  .updateSearchTerm(value),
              decoration: InputDecoration(hintText: 'Search'),
            ),

            // Sorting Menu in the App Bar itself
            actions: [
              PopupMenuButton<String>(
                // Sorting functionality
                onSelected: (value) =>
                    ref.read(filterStateProvider.notifier).updateSortBy(value),
                itemBuilder: (context) =>
                    ['Sort Alphabetical'].map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice,
                    child: Text(choice),
                  );
                }).toList(),
              ),
              PopupMenuButton<String>(
                  onSelected: (value) =>
                      // Filtering functionality
                      ref
                          .read(filterStateProvider.notifier)
                          .updateFilterBy(value),
                  itemBuilder: (context) => [
                        'Filter by Category',
                        'Filter by Type'
                      ].map((String choice) {
                        return PopupMenuItem<String>(
                            value: choice, child: Text(choice));
                      }).toList())
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

        // If Search bar is not empty or null then apply search term to query
        if (filterState.searchTerm != null &&
            filterState.searchTerm!.isNotEmpty) {
          query = query.where('productName', isEqualTo: filterState.searchTerm);
        }

        //Determine sorting field
        if (filterState.sortBy != null) {
          String field = filterState.sortBy == 'Sort by Name'
              ? 'productName'
              : 'timestamp'; // Determine sort field.
          query = query.orderBy(field);
        }

        return StreamBuilder(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              final logs = snapshot.data!.docs;
              //If no barcode logs are present
              if (logs.isEmpty) {
                return Center(
                  child: Text('No barcode logs available'),
                );
              }
              return _buildListView(logs);
            });
      },
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

        final fatsPerServing = data['fatsPerServing'].toInt();
        final carbsPerServing = data['carbsPerServing'].toInt();
        final proteinPerServing = data['proteinPerServing'].toInt();
        final cholesterolPerServing = data['cholesterolPerServing'].toInt();

        return Slidable(
          // Allows logs to be deleted, Wraps entire list widget

          key: ValueKey(logs[index].id),

          startActionPane: ActionPane(
            motion: ScrollMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => deleteLog(context, data),
                backgroundColor: const Color.fromARGB(2, 140, 215, 85),
                foregroundColor: Color.fromARGB(255, 143, 0, 0),
                icon: Icons.delete,
                label: 'Delete',
              )
            ],
          ),
          child: Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.black, width: 5),
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 7, // Card-like appearance
            margin: EdgeInsets.all(12), // Margin for spacing
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              // Logic for showing a nutritional label
              onTap: () {},
              child: Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                child: ListTile(
                  contentPadding: EdgeInsets.all(0),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                '${data['productName']}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Divider(
                              color: Color.fromARGB(255, 0, 0, 0),
                              thickness: 3,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                  'Carbs Per Serving: ${carbsPerServing}g'),
                            ),
                            Divider(
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
                            Divider(
                              thickness: 1,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child:
                                  Text('Fats Per Serving: ${fatsPerServing}g'),
                            ),
                            Divider(
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
                        child: VerticalDivider(
                          color: Color.fromARGB(255, 0, 0, 0),
                          thickness: 3.0,
                          width: 2.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          height: 125,
                          width: 100,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue,
                            image: DecorationImage(
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
                                    style: TextStyle(
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

  void deleteLog(BuildContext context, Map<String, dynamic> data) async {
    //Deletes the barcode log
    try {
      //stores documentID into variable
      String? docId = data['docId'];

      if (docId != null) {
        await FirebaseFirestore.instance
            .collection('Barcode_Lookup')
            .doc(docId)
            .delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Barcode log deleted successfully')),
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

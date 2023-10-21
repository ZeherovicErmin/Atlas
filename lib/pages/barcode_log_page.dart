import 'dart:async';

import 'package:atlas/components/productHouser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';
import 'package:flutter_slidable/flutter_slidable.dart';

class BarcodeLogPage extends ConsumerWidget {
  const BarcodeLogPage({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    log("The user id is = $uid");

    return _buildGradient(context, ref, uid);
  }

  Widget _buildGradient(BuildContext context, WidgetRef ref, String? uid) {
    return Scaffold(
      extendBody: true,
      body: _buildStreamBuilder(context, uid),
      backgroundColor: Color.fromARGB(0, 153, 57, 57),
    );
  }

  Widget _buildStreamBuilder(BuildContext context, String? uid) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('Barcode_Lookup')
          .where('uid', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        final logs = snapshot.data!.docs;

        if (logs.isEmpty) {
          return Center(
            child: Text('No barcode logs available.'),
          );
        }

        return _buildListView(logs);
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
                foregroundColor: const Color.fromARGB(255, 0, 0, 0),
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
                              child: Text('${data['productName']}'),
                            ),
                            Divider(
                              color: Colors.black,
                              thickness: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child:
                                  Text('Carbs Per Serving: $carbsPerServing'),
                            ),
                            Divider(),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Image.asset(
                                  "assets/icons/chickenLeg.png",
                                  width: 36,
                                  height: 36,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text(
                                      'Protein Per Serving: $proteinPerServing'),
                                ),
                              ],
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text('Fats Per Serving: $fatsPerServing'),
                            ),
                            Divider(),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                  'Cholesterol Per Serving: $cholesterolPerServing'),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 5,
                        height: 170,
                        child: VerticalDivider(
                          color: Colors.black,
                          thickness: 5.0,
                          width: 1.0,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Calories'),
                            Text('${data['productCalories']}'),
                          ],
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

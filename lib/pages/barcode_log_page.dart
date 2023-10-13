import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

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
      body: _buildStreamBuilder(context, uid),
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

        if (data.containsKey('uid')) {
          data['uid'] = ''; // Make the 'uid' row empty
        }

        final fatsPerServing = data['fatsPerServing'].toInt();
        final carbsPerServing = data['carbsPerServing'].toInt();
        final proteinPerServing = data['proteinPerServing'].toInt();

        return ListTile(
          title: Text('Barcode: ${data['Barcode']}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Product Name: ${data['productName']}'),
              Text('Product Calories: ${data['productCalories']}'),
              Text('Carbs Per Serving: $carbsPerServing'),
              Text('Protein Per Serving: $proteinPerServing'),
              Text('Fats Per Serving: $fatsPerServing'),
            ],
          ),
        );
      },
    );
  }
}

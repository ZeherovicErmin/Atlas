import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atlas/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

  // here you write the codes to input the data into firestore

  CollectionReference users = FirebaseFirestore.instance.collection('users');

class BarcodeLogPage extends ConsumerWidget {
  const BarcodeLogPage({super.key});
  //dont need this code since it is a stateful and not consumer
  //@override
  //State<BarcodeLogPage> createState() => _BarcodeLogPageState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    log("The user id is = $uid");
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode logs'),
      ),

      // Listens to changes in Firestore
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('Barcode_Lookup').where('uid', isEqualTo: uid).snapshots(),
            //FirebaseFirestore.instance.collection('Barcode_Lookup').doc(uid).snapshots(),
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

          final firstLogData = logs.first.data() as Map<String, dynamic>;
          final columns = firstLogData.keys.toList();

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                // Takes data from firebase to create the initial columns
                columns: columns
                    .map((column) => DataColumn(label: Text(column)))
                    .toList(),
                rows: logs.map((log) {
                  final data = log.data() as Map<String, dynamic>;
                  return DataRow(
                    cells: columns.map((column) {
                      return DataCell(Text(
                          '${data[column]}')); //creates rows for each of the datatype
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}

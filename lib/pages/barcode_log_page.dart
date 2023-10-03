import 'package:atlas/pages/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atlas/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

CollectionReference users = FirebaseFirestore.instance.collection('users');

class BarcodeLogPage extends ConsumerWidget {
  const BarcodeLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    log("The user id is = $uid");
    Widget gradient(context, ref) {
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
        child: Scaffold(
          appBar: myAppBar2(context, ref, 'B a r c o d e L o g s'),
          body: StreamBuilder(
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

              // Define the column order, place 'Barcode' as the first column
              final columns = [
                'Barcode',
                // Hides UserID variable
                ...logs.first.data()!.keys.where((k) => k != 'uid')
              ];

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: columns.map((column) {
                      if (column == 'uid') {
                        // Make the 'uid' column invisible
                        return DataColumn(label: Text(''));
                      } else {
                        return DataColumn(label: Text(column));
                      }
                    }).toList(),
                    rows: logs.map((log) {
                      final data = log.data() as Map<String, dynamic>;
                      if (data.containsKey('uid')) {
                        data['uid'] = ''; // Make the 'uid' row empty
                      }
                      return DataRow(
                        // Each column fed from DataSentToFireStore
                        // is logged here
                        cells: columns.map((column) {
                          return DataCell(
                            Text('${data[column]}'),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return gradient(context, ref);
  }
}

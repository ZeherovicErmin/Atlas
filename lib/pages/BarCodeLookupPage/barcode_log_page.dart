import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BarcodeLogPage extends StatefulWidget {
  const BarcodeLogPage({super.key});

  @override
  State<BarcodeLogPage> createState() => _BarcodeLogPageState();
}

class _BarcodeLogPageState extends State<BarcodeLogPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode logs'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('Barcode_Lookup').snapshots(),
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

          return DataTable(
            columns: columns
                .map((column) => DataColumn(label: Text(column)))
                .toList(),
            rows: logs.map((log) {
              final data = log.data() as Map<String, dynamic>;
              return DataRow(
                cells: columns.map((column) {
                  return DataCell(Text('${data[column]}'));
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

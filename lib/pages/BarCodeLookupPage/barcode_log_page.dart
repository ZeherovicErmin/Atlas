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
          return ListView.builder(
            itemCount: logs?.length,
            itemBuilder: (context, index) {
              final log = logs[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Barcode: $log["Barcode"]'),
                subtitle: Text('product Name: '),
              );
            },
          );
        },
      ),
    );
  }
}

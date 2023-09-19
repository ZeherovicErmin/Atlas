//Atlas Fitness App CSC 4996
import 'package:flutter/material.dart';
import 'pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:atlas/pages/BarCodeLookupPage/barcode_lookup_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BarcodeLookupApp());
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: AuthPage(),
//     );
//   }
// }

//remove code underneath
class BarcodeLookupApp extends StatelessWidget {
  const BarcodeLookupApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Lookup',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BarcodeLookupPage(),
    );
  }
}

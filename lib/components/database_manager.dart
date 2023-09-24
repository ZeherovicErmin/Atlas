import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseManager {
/*
  Future getUserList() async {
    try {
      await profileList.getDocuments().then(QuerySnapshot);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
*/
}

  final CollectionReference profileList = FirebaseFirestore.instance.collection('Users');

  Future<void> userSetup(String displayName) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Users2');
    FirebaseAuth auth = FirebaseAuth.instance;
    String uid = auth.currentUser!.uid.toString();
    users.add({
      'displayName': displayName,
      'uid': uid
  });
  return;
  }
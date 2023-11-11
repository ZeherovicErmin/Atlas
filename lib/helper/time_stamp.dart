// return formatted date as a string

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  // Format date
  String formattedDate = DateFormat('MM/dd/yyyy').format(dateTime);

  // Format time
  String formattedTime = DateFormat('h:mm a').format(dateTime);

  // Combine date and time
  String formattedData = '$formattedDate • $formattedTime';

  return formattedData;
}

// return formatted date as a string

import 'package:cloud_firestore/cloud_firestore.dart';

String formatDate(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  //get year
  String year = dateTime.year.toString();

  //get month
  String month = dateTime.month.toString();

  //get year
  String day = dateTime.day.toString();

  //formatted data
  String formattedData = '$month/$day/$year';

  return formattedData;
}

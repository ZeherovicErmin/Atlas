import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});


  //For the customizing the fields a user can use to type in
  //(username and password text field)
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: myAppBar2(context, ref, 'S e t t i n g s'),
    );











  }
}

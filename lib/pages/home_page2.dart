//Atlas Fitness App CSC 4996
import 'package:atlas/main.dart';
import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_page.dart';

class HomePage2 extends ConsumerWidget {
  const HomePage2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
        //Home page for when a user logs in
        backgroundColor: const Color.fromARGB(255, 169, 183, 255),
        appBar: myAppBar(context, ref, 'Fitness'),
        body: user != null
            ? Column()
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}

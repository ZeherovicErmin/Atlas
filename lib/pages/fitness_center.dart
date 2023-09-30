//Atlas Fitness App CSC 4996
import 'package:atlas/main.dart';
import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FitCenter extends ConsumerWidget {
  const FitCenter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
        //Home page for when a user logs in
        backgroundColor: const Color.fromARGB(255, 169, 183, 255),
        appBar: myAppBar2(context, ref, 'Fitness Center'),
        body: user != null
            ? Column()
            : const Center(
                child: CircularProgressIndicator(),
              ));
  }
}

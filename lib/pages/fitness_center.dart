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
          //Home page for when a user logs in
          backgroundColor: Colors.transparent,
          appBar: myAppBar2(context, ref, 'Fitness Center'),
          body: user != null
              ? Column()
              : const Center(
                  child: CircularProgressIndicator(),
                )),
    );
  }
}

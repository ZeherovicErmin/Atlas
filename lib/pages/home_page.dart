//Atlas Fitness App CSC 4996
import 'package:atlas/main.dart';
import 'package:atlas/pages/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'fitness_center.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
        //Home page for when a user logs in
        backgroundColor: const Color.fromARGB(255, 169, 183, 255),
        appBar: myAppBar(context, ref, 'Home'),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FitCenter()),
                    );
                  },
                  child: myWidgCont(
                      150,
                      175,
                      const Color.fromARGB(255, 38, 97, 185),
                      Icons.fitness_center,
                      Colors.white),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/recipes');
                  },
                  child: myWidgCont(
                      150,
                      175,
                      const Color.fromARGB(255, 224, 224, 224),
                      CupertinoIcons.book_fill,
                      Color.fromARGB(255, 38, 97, 185)),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/userprof');
                    },
                    child: myWidgCont(
                        150,
                        175,
                        const Color.fromARGB(255, 224, 224, 224),
                        CupertinoIcons.profile_circled,
                        Color.fromARGB(255, 38, 97, 185))),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/barcode');
                  },
                  child: myWidgCont(150, 175, Color.fromARGB(255, 38, 97, 185),
                      CupertinoIcons.qrcode_viewfinder, Colors.white),
                ),
              ],
            ),
          ],
        ));
  }
}

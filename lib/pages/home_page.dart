//Atlas Fitness App CSC 4996
import 'package:atlas/main.dart';
import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_page2.dart';

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
        //Home page for when a user logs in
        backgroundColor: const Color.fromARGB(255, 169, 183, 255),
        appBar: myAppBar(context, ref, 'Home'),
        drawer: myDrawer,
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
                      MaterialPageRoute(builder: (context) => HomePage2()),
                    );
                  },
                  child: myWidgCont(
                      150, 175, const Color.fromARGB(255, 100, 167, 100)),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/recipes');
                  },
                  child: myWidgCont(
                      150, 175, const Color.fromARGB(255, 224, 224, 224)),
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
                        150, 175, const Color.fromARGB(255, 224, 224, 224))),
                myWidgCont(150, 175, const Color.fromARGB(255, 100, 167, 226)),
              ],
            ),
          ],
        ));
  }
}

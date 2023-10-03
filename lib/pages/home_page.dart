import 'package:atlas/components/bottom_bar.dart';
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

    Widget gradient(context, ref) {
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
                resizeToAvoidBottomInset : false,
                //Home page for when a user logs in
                backgroundColor: Colors.transparent,
                appBar: myAppBar(context, ref, 'Home'),
                body: SafeArea(
                  child: Center (
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              myWidgCont(150, 175, const Color.fromARGB(255, 38, 97, 185),
                                  Icons.fitness_center, Colors.white),
                              myWidgCont(
                                  150,
                                  175,
                                  const Color.fromARGB(255, 224, 224, 224),
                                  CupertinoIcons.book_fill,
                                  Color.fromARGB(255, 38, 97, 185)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              myWidgCont(
                                150,
                                175,
                                const Color.fromARGB(255, 224, 224, 224),
                                CupertinoIcons.profile_circled,
                                Color.fromARGB(255, 38, 97, 185),
                              ),
                            ],
                          ),
                          myWidgCont(150, 175, Color.fromARGB(255, 38, 97, 185),
                              CupertinoIcons.qrcode_viewfinder, Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
                ),
      );
    }

    return gradient(context, ref);
  }
}

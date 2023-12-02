import 'package:atlas/components/productHouser.dart';
import 'package:atlas/pages/barcode_log_page.dart';
import 'package:atlas/pages/feed.dart';
import 'package:atlas/pages/fitness_center%20redesign.dart';

import 'package:atlas/pages/home_page.dart';
import 'package:atlas/pages/newFeed.dart';
import 'package:atlas/pages/recipes.dart';
import 'package:atlas/pages/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

var indexProvider = StateProvider((ref) => 2);

class BottomNav extends ConsumerWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(indexProvider);

    final List<Widget> pages = [
      FitCenter2(),
      Recipes(),
      HomePage(),
      BarcodeLookupComb(),
      const Feed(),
    ];

    return Scaffold(
      //To avoid overflow error when keyboard opens
      resizeToAvoidBottomInset: false,

      //fixes NavBar transparency
      extendBody: true,

      // Indexed Stack holds the index of the page
      // So the programmer knows what page you are on
      body: IndexedStack(
        index: currentIndex,

        // See 'pages' variable above
        // Passes in pages of the application
        children: pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        // Colors of the nav
        backgroundColor: Colors.transparent,
        color: Color.fromARGB(255, 0, 136, 204),

        // Defines animation duration
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          // Watches for any changes to the index provider
          ref.read(indexProvider.notifier).state = index;
          print(ref.read(indexProvider.notifier).state);
        },
        index: ref.watch(indexProvider),
        items: const [
          Icon(
            Icons.fitness_center,
            color: Colors.white,
          ),
          Icon(
            Icons.dining_outlined,
            color: Colors.white,
          ),
          Icon(
            CupertinoIcons.home,
            color: Colors.white,
          ),
          Icon(
            CupertinoIcons.barcode_viewfinder,
            color: Colors.white,
          ),
          Icon(
            CupertinoIcons.chat_bubble,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

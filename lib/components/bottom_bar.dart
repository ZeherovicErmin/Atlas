import 'package:atlas/components/productHouser.dart';
import 'package:atlas/pages/barcode_log_page.dart';
import 'package:atlas/pages/barcode_lookup_page.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:atlas/pages/fitness_center.dart';
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
      const FitCenter(),
      Recipes(),
      const HomePage(),
      DraggableScrollCard(),
      const UserProfile(),
    ];

    return Scaffold(
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
        backgroundColor: Color.fromARGB(255, 161, 195, 250),
        color: const Color.fromARGB(255, 38, 97, 185),
        // Defines animation duration
        animationDuration: Duration(milliseconds: 300),
        onTap: (index) {
          // Watches for any changes to the index provider
          ref.read(indexProvider.notifier).state = index;
          print(ref.read(indexProvider.notifier).state);
        },
        index: ref.watch(indexProvider),
        items: [
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
            CupertinoIcons.profile_circled,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

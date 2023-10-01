import 'package:atlas/pages/barcode_log_page.dart';
import 'package:atlas/pages/barcode_lookup_page.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:atlas/pages/home_page2.dart';
import 'package:atlas/pages/recipes.dart';
import 'package:atlas/pages/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

var indexProvider = StateProvider((ref) => 0);

class BottomNav extends ConsumerWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(indexProvider);

    final List<Widget> pages = [
      BarcodeLookupPage(),
      Recipes(),
      const UserProfile(),
      HomePage2(),
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
        backgroundColor: Color.fromARGB(255, 169, 183, 255),
        color: const Color.fromARGB(255, 102, 20, 255),
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
            Icons.barcode_reader,
            color: Colors.white,
          ),
          Icon(
            Icons.dinner_dining,
            color: Colors.white,
          ),
          Icon(
            Icons.verified_user,
            color: Colors.white,
          ),
          Icon(
            Icons.fitness_center,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

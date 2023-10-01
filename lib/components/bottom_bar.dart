import 'package:atlas/pages/barcode_log_page.dart';
import 'package:atlas/pages/barcode_lookup_page.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:atlas/pages/recipes.dart';
import 'package:atlas/pages/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Riverpod Navigation"),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          ref.read(indexProvider.notifier).state = index;
          print(ref.read(indexProvider.notifier).state);
        },
        currentIndex: ref.watch(indexProvider),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Page 2"),
          BottomNavigationBarItem(icon: Icon(Icons.scanner), label: "Page 3"),
        ],
      ),
    );
  }
}

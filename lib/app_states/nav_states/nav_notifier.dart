import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'nav_states.dart';

class NavNotifier extends StateNotifier<NavStates> {
  NavNotifier() : super(const NavStates());

  // This method updates the 'index' state property when the user
  //  selects a different tab. It takes one index parameter
  //  and that parameter selects the index of the selected tab
  void onIndexChanged(int index) {
    // copyWith creates a new NavStates instance with updated index value
    state = state.copyWith(index: index);
  }
}

//Using Riverpods Provider
final navProvider =
    StateNotifierProvider<NavNotifier, NavStates>((ref) => NavNotifier());

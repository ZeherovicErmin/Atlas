import 'package:equatable/equatable.dart';

class NavStates extends Equatable {
  // Because we are working with indexes for the navigation bar, we
  //    need to have a variable for index
  const NavStates({this.index = 0});
  final int index;
// Creates a new instance of NavStates with the option to replace the 'index' property.
// If 'index' is not provided, it defaults to the current 'index' value.
  NavStates copyWith({int? index}) {
    return NavStates(index: index ?? this.index);
  }

  @override

  // List of properties to compare for object equality
  List<Object?> get props => [index];
}

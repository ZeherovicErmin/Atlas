import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:atlas/pages/settings_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangePassword extends ConsumerWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      return Scaffold(
      appBar: myAppBar2(context, ref, 'C h a n g e  P a s s w o r d'),
      );
  }
}
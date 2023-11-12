import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:atlas/pages/settings_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends ConsumerWidget {
  const ChangePassword({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
      return Scaffold(
      appBar: myAppBar4(context, ref, 'Change Password'),
      );
  }
}
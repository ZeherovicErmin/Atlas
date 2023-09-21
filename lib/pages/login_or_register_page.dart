/*import 'package:atlas/main.dart';
import 'package:atlas/pages/login_page.dart';
import 'package:atlas/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final loginOrRegisterProvider = StateProvider<bool>((ref) => true);

class LoginOrRegisterPage extends ConsumerWidget {
  const LoginOrRegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(builder: (context, ref, child){
      
      final bool showLoginPage = ref.watch(loginOrRegisterProvider);

    return showLoginPage
        ? LoginPage(
          onTap: () {
            ref.read(loginOrRegisterProvider).state = false;
          })
        : RegisterPage(
            onTap: () {
              ref.read(loginOrRegisterProvider).state = true;
            },
          );
  }
};
*/
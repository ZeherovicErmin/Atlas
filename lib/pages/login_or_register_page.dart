import 'package:atlas/main.dart';
import 'package:atlas/pages/login_page.dart';
import 'package:atlas/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginOrRegisterPage extends ConsumerWidget {
  const LoginOrRegisterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final showLoginPage = watch(loginOrRegisterProvider);

    return showLoginPage.state
        ? LoginPage(onTap: () {
            context.read(loginOrRegisterProvider).state = false;
          })
        : RegisterPage(
            onTap: () {
              context.read(loginOrRegisterProvider).state = true;
            },
          );
  }
}

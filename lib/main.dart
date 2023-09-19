//Atlas Fitness App CSC 4996
import 'package:atlas/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Implementing a Provider for firebase initialization and authentication
final firebaseProvider = FutureProvider<FirebaseApp>((ref) async {
  final options = DefaultFirebaseOptions.currentPlatform;
  return Firebase.initializeApp(options: options);
});

final userProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Storing our user with provider
    final user = ref.watch(userProvider);

    return user.when(
      data: (user) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const AuthPage(),
          routes: {
            '/home': (context) => HomePage(),
          },
        );
      },
      error: (e, s) => Text('error'),
      loading: () => Text('loading'),
    );
  }
}

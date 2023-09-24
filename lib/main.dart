//Atlas Fitness App CSC 4996
import 'package:atlas/components/bottom_bar.dart';
import 'package:atlas/pages/barcode_lookup_page.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:atlas/pages/fitness_center.dart';
import 'package:atlas/pages/login_page.dart';
import 'package:atlas/pages/recipes.dart';
import 'package:atlas/pages/register_page.dart';
import 'package:atlas/pages/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// Implementing a Provider for firebase initialization and authentication
final firebaseProvider = FutureProvider<FirebaseApp>((ref) async {
  final options = DefaultFirebaseOptions.currentPlatform;
  return Firebase.initializeApp(options: options);
});

final userProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Text box providers
final emailControllerProvider = Provider<TextEditingController>((ref) {
  return TextEditingController();
});

final passwordControllerProvider = Provider.autoDispose((ref) {
  return TextEditingController();
});

// Provider for signing out
final signOutProvider = FutureProvider<void>((ref) async {
  final user = ref.watch(userProvider);
  await FirebaseAuth.instance.signOut();
});

// Creating a registration provider
final registrationProvider = Provider((ref) => RegistrationState());

// Creating a provider for keeping track of the selected index of the navigation bar
final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Storing our user with provider
    final user = ref.watch(userProvider);

    return user.when(
      data: (user) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const AuthPage(),
            routes: {
              '/home': (context) => HomePage(),
              '/fitcenter': (context) => FitCenter(),
              '/login': (context) => LoginPage(),
              '/register': (context) => RegisterPage(),
              '/recipes': (context) => Recipes(),
              '/userprof': (context) => UserProfile(),
              '/barcode': (context) => BarcodeLookupPage(),
              '/start': (context) => BottomNav(),
            },
          ),
        );
      },
      error: (e, s) => Text('error'),
      loading: () {
        return CircularProgressIndicator();
      },
    );
  }
}

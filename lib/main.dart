//Atlas Fitness App CSC 4996
//Authors:
//Matthew McGowan
//Ermin Zeherovic
//Hussein Daher
//Ali Chowdhury
//Ayesha Helal
import 'package:atlas/components/bottom_bar.dart';
import 'package:atlas/components/productHouser.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:atlas/pages/login_page.dart';
import 'package:atlas/pages/recipes.dart';
import 'package:atlas/pages/register_page.dart';
import 'package:atlas/pages/settings_page.dart';
import 'package:atlas/pages/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'pages/fitness_center redesign.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //This line gets rid of the normal UI at the top of the phone like the battery etc.
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
            child: Consumer(builder: (context, ref, _) {
              final lightDarkTheme = ref.watch(themeProvider);
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                theme: ThemeData.light(),
                themeMode: lightDarkTheme ? ThemeMode.dark : ThemeMode.light,
                home: const AuthPage(),
                routes: {
                  '/home': (context) => HomePage(),
                  '/fitcenter': (context) => FitCenter2(),
                  '/login': (context) => LoginPage(),
                  '/register': (context) => RegisterPage(),
                  '/recipes': (context) => Recipes(),
                  '/userprof': (context) => UserProfile(),
                  '/barcode': (context) => BarcodeLookupComb(),
                  '/start': (context) => BottomNav(),
                },
              );
            }));
      },
      error: (e, s) => Text('error'),
      loading: () {
        return CircularProgressIndicator();
      },
    );
  }
}

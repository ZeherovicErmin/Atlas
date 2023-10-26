import 'package:atlas/pages/change_password.dart';
import 'package:flutter/material.dart';
import 'package:atlas/main.dart';
import 'package:atlas/pages/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:atlas/components/signout_button.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, bool> ( (ref) {
    return ThemeNotifier();
  }
);

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true);

  //Calling this function toggles the state of the theme
  void toggleTheme() {
    state = !state;
    }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Saves the state of dark mode being on or off
    final lightDarkTheme = ref.watch(themeProvider);

    //Holds the opposite theme color for the text
    final themeColor = lightDarkTheme ? Colors.white : Colors.black;

    return Scaffold(
      appBar: myAppBar4(context, ref, 'S e t t i n g s'),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SettingsList(
              sections: [
                SettingsSection(
                  title: Text(
                    'Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  tiles: [
                    SettingsTile(
                      title: Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      leading: Icon(
                        Icons.lock,
                        color: Colors.black,
                      ),
                      onPressed: (BuildContext context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChangePassword()),
                        );
                      },
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text(
                    'Appearance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  tiles: [
                    SettingsTile.switchTile(
                      title: Text(
                        'Dark Mode',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      leading: Icon(
                        Icons.flashlight_on_outlined,
                        color: Colors.black,
                      ),
                      initialValue: lightDarkTheme,
                      //Get rid of "test" to make this work again
                      onToggle: (bool testlightDarkTheme) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6),
            child: SignoutButton(
              onPressed: () async {
                ref.read(signOutProvider);
                // After successful logout redirect to logout page
                Navigator.of(context).pushReplacementNamed('/login');
              },
              text: 'Sign Out',
            ),
          ),
        ],
      ),
    );
  }
}
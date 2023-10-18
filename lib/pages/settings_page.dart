import 'package:flutter/material.dart';
import 'package:atlas/main.dart';
import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
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
  const SettingsPage({super.key});

  //For the customizing the fields a user can use to type in
  //(username and password text field)
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Saves the state of dark mode being on or off
    final lightDarkTheme = ref.watch(themeProvider);
    
    //Holds the opposite theme color for the text
    final themeColor = lightDarkTheme ? Colors.white : Colors.black;

    return Scaffold(
      appBar: myAppBar2(context, ref, 'S e t t i n g s'),
      body: Column (
      children: [
        Expanded (
          child: SettingsList(
            sections: [
              SettingsSection(
                title: Text(
                  'Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                tiles: [
                  SettingsTile(
                    title: const Text('Change Password'),
                    leading: const Icon(Icons.lock),
                    onPressed: (BuildContext context) {},
                  ),
                ],
              ),
              SettingsSection(
                title: Text(
                  'Appearance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                    ),
                  ),
                tiles: [
                  SettingsTile.switchTile (
                    title: const Text('Dark Mode'),
                    leading: const Icon(Icons.flashlight_on_outlined),
                    initialValue: lightDarkTheme,
                    onToggle: (bool lightDarkTheme) {
                      ref.read(themeProvider.notifier).toggleTheme();
                    },
                  ),
                ],
              ),
              ],
            ),
          ),
          Padding (
          padding: EdgeInsets.all(6),
          child: SignoutButton(
            onPressed: () async {
              await ref.read(signOutProvider);
              // After succesful logout redirect to logout page
              Navigator.of(context).pushReplacementNamed('/login');
            },
            text: 'Sign Out')
          ),
        ],
      ),
    );
  }
}
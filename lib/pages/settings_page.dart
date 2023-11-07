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
  ThemeNotifier() : super(false);

  //Calling this function toggles the state of the theme
  void toggleTheme() {
    state = !state;
    }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //Saves the state of dark mode being on or off
    final lightDarkTheme = ref.watch(themeProvider);

    //Holds the opposite theme color for the text
    final themeColor = lightDarkTheme ? Colors.white : Colors.black;
    final themeColor2 = lightDarkTheme ? Colors.black : Colors.white;

    return Theme(
      data: ThemeData(
        brightness: lightDarkTheme ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        appBar: myAppBar4(context, ref, 'Settings'),
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
                      title: Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 16,
                          color: themeColor,
                        ),
                      ),
                      leading: Icon(
                        Icons.lock,
                        color: themeColor,
                        ),
                      onPressed: (BuildContext context) {
                        Navigator.push(
                          context,
                          MaterialPageRoute (builder: (context) => const ChangePassword()),
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
                          color: themeColor,
                      ),
                    ),
                  tiles: [
                    SettingsTile.switchTile (
                      title: Text(
                        'Dark Mode',
                          style: TextStyle(
                            fontSize: 16,
                            color: themeColor,
                      ),
                        ),
                      leading: Icon(
                        Icons.flashlight_on_outlined,
                        color: themeColor,
                        ),
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
            padding: const EdgeInsets.all(6),
            child: SignoutButton(
              onPressed: () async {
                ref.read(signOutProvider);
                // After succesful logout redirect to logout page
                Navigator.of(context).pushReplacementNamed('/login');
              },
              text: 'Sign Out')
            ),
          ],
        ),
      ),
    );
  }
}
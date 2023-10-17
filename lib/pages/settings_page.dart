import 'package:atlas/main.dart';
import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:atlas/components/signout_button.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});


  //For the customizing the fields a user can use to type in
  //(username and password text field)
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: myAppBar2(context, ref, 'S e t t i n g s'),
      body: Column (
      children: [
        Expanded (
          child: SettingsList(
            sections: [
              SettingsSection(
                title: const Text(
                  'Account',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                title: const Text(
                  'Appearance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                    ),
                  ),
                tiles: [
                  SettingsTile.switchTile (
                    title: const Text('Dark Mode'),
                    leading: const Icon(Icons.flashlight_on_outlined),
                    initialValue: false,
                    onToggle: (bool dorl) {
                      print('test');
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
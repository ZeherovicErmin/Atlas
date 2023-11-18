import 'package:atlas/pages/change_password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:atlas/main.dart';
import 'package:atlas/pages/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:atlas/components/signout_button.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
//import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';


DateTime scheduleTime = DateTime.now();
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false);

  //Calling this function toggles the state of the theme
  void toggleTheme() {
    state = !state;
  }
}

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('flameicon.png');
    //ios
    var initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification: (id, title, body, payload) async {},
    );
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});

  void scheduleDailyNoonNotification(NotificationService notificationService) async {
  DateTime now = DateTime.now();
  DateTime noon = DateTime(now.year, now.month, now.day, 12, 0); // Set to 12:00 PM

  // If 12:00 PM today has already passed, schedule for the next day
  if (noon.isBefore(now)) {
    noon = noon.add(Duration(days: 1));
  }

  notificationService.scheduleNotification(
    title: 'Log a habit',
    body: 'Would you like to log your habits now?',
    scheduledNotificationDateTime: noon,
  );

  debugPrint('Notification scheduled for $noon');
}
  }

  notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  //show Notifcaiton button
Future<void> showNotification(int id, String title, String body) async {
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(Duration(seconds: 1)),
      const NotificationDetails(
        // Android details
        android: AndroidNotificationDetails('main_channel', 'Main Channel',
            channelDescription: "ashwin",
            importance: Importance.max,
            priority: Priority.max),
        // iOS details
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      // Type of time interpretation
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,//To show notification even when the app is closed
    );
  }
  
  void scheduleNotification(

    {required String title, 
    int id = 0,
    required String body, 
    required DateTime scheduledNotificationDateTime}) async {
      return notificationsPlugin.zonedSchedule(id, title, body, 
      tz.TZDateTime.from(scheduledNotificationDateTime, tz.local), 
      await notificationDetails(), uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime);
    }
}

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  // Initialize notifications AC

  //ios notification handling AC

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
                            MaterialPageRoute(
                                builder: (context) => const ChangePassword()),
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
                      SettingsTile.switchTile(
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
                  SettingsSection(
                      title: Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                        ),
                      ),
                      tiles: [
                        SettingsTile(
                          title: Text('Notification Timer'),
                          //Opens time picker sheet
                          onPressed: _openTimePickerAndSchedule,
                          leading: Icon(Icons.alarm_on,color: themeColor,
                          ),
                          
                        ),
                        
                      ],),
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
                          'Delete Account',
                          style: TextStyle(fontSize: 16, color: themeColor),
                        ),
                        leading: Icon(Icons.delete_forever,color: themeColor,),
                        onPressed: (BuildContext context) {
                          deleteUserAccount(context);
                        }),
                    ],),],),),
            Padding(
                padding: const EdgeInsets.all(6),
                child: SignoutButton(
                    onPressed: () async {
                      ref.read(signOutProvider);
                      // After succesful logout redirect to logout page
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                    text: 'Sign Out')),
          ],
        ),
      ),
      
    );
    
  }



  // Function to open DatePicker and schedule notification
  void _openTimePickerAndSchedule(BuildContext context) async {
    final now = DateTime.now();
    final xMinutesFromNow = now.add(Duration(minutes: 3));
    final initialTime = TimeOfDay(hour: xMinutesFromNow.hour, minute: xMinutesFromNow.minute);
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      

      initialTime: initialTime,
    );

    if (pickedTime != null) {
      DateTime now = DateTime.now();
      DateTime scheduledDateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);

      // If the picked time has already passed today, schedule it for the next day
      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(Duration(days: 1));
      }

      NotificationService().scheduleNotification(
        title: 'Log a habit',
        body: 'Would you like to log your habits now?',
        scheduledNotificationDateTime: scheduledDateTime,
      );

      debugPrint('Notification scheduled for $scheduledDateTime');
    } else {
      debugPrint('No valid time selected');
    }
  }
  }


class ScheduleBtn extends StatelessWidget {
  const ScheduleBtn({
    Key? key,
  }) : super(key: key);

@override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Schedule notifications'),
      onPressed: () {
        final now = DateTime.now();
        if (scheduleTime.isAfter(now)) {
          debugPrint('Notification Scheduled for $scheduleTime');
          NotificationService().scheduleNotification(
              title: 'Scheduled Notification',
              body: 'Scheduled for $scheduleTime',
              scheduledNotificationDateTime: scheduleTime);
        } else {
          debugPrint('Cannot schedule notification in the past');
        }
      },
    );
  }
}

class DatePickerTxt extends StatefulWidget {
  const DatePickerTxt({Key? key}) : super(key: key);

  @override
  State<DatePickerTxt> createState() => _DatePickerTxtState();
}

class _DatePickerTxtState extends State<DatePickerTxt> {
  DateTime selectedDateTime = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDateTime.isBefore(now) ? now : selectedDateTime,
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDateTime) {
      final TimeOfDay initialTime = selectedDateTime.isBefore(now)
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(selectedDateTime);
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        final DateTime newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (newDateTime.isAfter(now)) {
          setState(() {
            selectedDateTime = newDateTime;
            scheduleTime = selectedDateTime;
          });
          debugPrint('DateTime selected: $selectedDateTime');
        } else {
          debugPrint('Selected time is not in the future');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => _selectDate(context),
      child: const Text(
        'Select Date and Time',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}
Future<void> deleteUserAccount(BuildContext context) async{
  //get auth details
  final FirebaseAuth auth = FirebaseAuth.instance;
  // get currentUser
  final User? user = auth.currentUser;

  if (user != null)
  {
    try{
      
      FirebaseFirestore.instance.collection('Users').doc(user.uid).delete();
      //delete account
      await user.delete();
      Navigator.of(context).pushReplacementNamed('/login');
    }on FirebaseAuthException catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.message}")));
    }catch (e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e}")));
    
  }
  //User not found

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User not found")));
  }
}
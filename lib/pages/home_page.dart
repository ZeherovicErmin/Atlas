import 'package:atlas/pages/habit_toggle.dart';
import 'package:atlas/pages/line_chart.dart';
import 'package:atlas/pages/user_profile.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class HabitCard extends StatefulWidget {
  final String title;
  final String unit;
  final IconData iconData;
  final Color backgroundColor;
  final Function(String) onTap;
  final String selectedDate;
  final String image;

  const HabitCard({
    required this.title,
    required this.unit,
    required this.backgroundColor,
    required this.onTap,
    required this.selectedDate,
    this.iconData = Icons.flutter_dash,
    this.image = '',
  });

  @override
  HabitCardState createState() => HabitCardState();
}

class HabitCardState extends State<HabitCard> {
  late String currentSubtitle;
  late Stream<DocumentSnapshot> habitStream;

  @override
  void initState() {
    super.initState();
    currentSubtitle = '';
    habitStream = fetchHabits();
  }

  @override
  void didUpdateWidget(covariant HabitCard oldHabitData) {
    super.didUpdateWidget(oldHabitData);
    if (oldHabitData.selectedDate != widget.selectedDate) {
      habitStream = fetchHabits();
    }
  }

  //Fetches the habit cards from firebase to display to the user
  Stream<DocumentSnapshot> fetchHabits() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    //For debugging purposes, change the testdate to any date to test the
    //fetching of the correct data for the correct date.
    var testDate = '2023-10-25';
    return FirebaseFirestore.instance
      .collection('Habits')
      .doc(uid)
      .collection(widget.selectedDate)
      .doc('habits')
      .snapshots();
  }

  //Opens the habit card for editing & habit card build
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: habitStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        var data = snapshot.data?.data() as Map<String, dynamic>?;
        currentSubtitle = data?[widget.title.toLowerCase()] ?? '';
        return GestureDetector(
          onTap: () {
            editDialog(context, widget.title);
          },
          child: Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.image.isNotEmpty)
                Image.asset(
                  widget.image,
                  width: 60,
                  height: 60,
                ),
                if (widget.image.isEmpty)
                Icon(
                  widget.iconData,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                AutoSizeText(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    minFontSize: 12,
                  ),
                const SizedBox(height: 5),
                Text(
                  widget.unit,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentSubtitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  //Function for editing a habit card
  //Sends the data to firebase
  void editDialog(BuildContext context, String title) async {
    //Variables
    TextEditingController textController = TextEditingController(text: currentSubtitle);
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    //Habit card popup for editing data
    showDialog(
      context: context,
        builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit $title'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: 'Enter a value',
                      ),
                    onChanged: (value) {
                      setState(() {
                        currentSubtitle = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HabitLineChartPage(
                            habitTitle: title,
                            habitCardColor: widget.backgroundColor,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[850],
                    ),
                    child: Center(
                      child: Text('View $title Graph',
                        style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        ),
                      ),
                    ),
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Save'),
                  onPressed: () async {
                      widget.onTap(currentSubtitle);
                      DocumentReference userDocRef = FirebaseFirestore.instance
                        .collection('Habits')
                        .doc(uid);
                      CollectionReference dateSubcollectionRef =
                          userDocRef.collection(widget.selectedDate);
                      await dateSubcollectionRef
                        .doc('habits')
                        .set({title.toLowerCase(): currentSubtitle,
                        },
                        SetOptions(merge: true));
                      Navigator.of(context).pop();
                      setState(() {
                        currentSubtitle = textController.text;
                      });
                    },
                  ),
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime currentDate = DateTime.now();
  late String selectedDate;
  late String formattedDate;
  late Stream<String> usernameStream;
  String formatDate(DateTime date) => "${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}";
  String formatDateTime(DateTime date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  String? profileImage;
  ScrollController scroll = ScrollController();

  @override
  void initState() {
    currentDate = DateTime.now();
    selectedDate = formatDate(currentDate);
    formattedDate = formatDateTime(currentDate);
    usernameStream = fetchUsername();
    fetchProfileImage();
    super.initState();
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }

  //Gets the user's profile picture from firebase for the appbar
  void fetchProfileImage() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.email != null) {
      try {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .get();
        final userPicture = userDoc.data() as Map<String, dynamic>?;
        if (userPicture != null && userPicture.containsKey('profilePicture')) {
          setState(() {
            profileImage = userPicture['profilePicture'];
          });
        }
      } catch (e) {
        print('Error fetching your profile picture.');
      }
    }
  }

  //Grabs selected habits from firebase
  Stream<Map<String, bool>> fetchSelectedHabits() {
    //Variables
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;

    //Returns toggled habits to the screen
    return FirebaseFirestore.instance.collection('SelectedHabits').doc(uid).snapshots().map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>?;
      return Map<String, bool>.from(data?['selectedHabits'] ?? {});
    });
  }

  //Changes the date to the next day in real time
  void addDate() {
    changeDate(currentDate.add(const Duration(days: 1)));
  }

  //Changes the date to the previous day in real time
  void deleteDate() {
    changeDate(currentDate.subtract(const Duration(days: 1)));
  }

  //Changes the date to the next or previous date
  void changeDate(DateTime newDate) {
    setState(() {
      currentDate = newDate;
      selectedDate = formatDate(currentDate);
      formattedDate = formatDateTime(currentDate);
    });
  }

  //Function for choosing a date
  Future<void> chooseDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      //The earilest date a user can select and the latest date
      firstDate: DateTime(2023, 10),
      lastDate: DateTime(2026),
    );
    if (picked != null) {
      setState(() {
        var month = picked.month.toString().padLeft(2, '0');
        var day = picked.day.toString().padLeft(2, '0');
        currentDate = picked;
        formattedDate = "${picked.year}-$month-$day";
        selectedDate = "$month/$day";
      });
    }
  }

  //Gets the user's username
  Stream<String> fetchUsername() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser.email)
        .snapshots()
        .map((snapshot) {
        final userData = snapshot.data() as Map<String, dynamic>;
        return userData['username']?.toString() ?? '';
      });
    }
    return Stream.value('');
  }

  //App Bar
  PreferredSize homePageAppBar(BuildContext context) {
    //Variables
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;

    //Returns App bar
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HabitToggle()),
            );
          }
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 136, 204),
        toolbarHeight: 60,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Home',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 4),
            StreamBuilder<String>(
              stream: usernameStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Text('Username not found');
                }
                final username = snapshot.data!.trim();
                return Text(
                  'Welcome, $username',
                  style: const TextStyle(
                    fontFamily: 'Open Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          if (profileImage != null)
          IconButton(
            icon: CircleAvatar(
            backgroundImage: NetworkImage(profileImage!),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfile()),
              );
            },
          ),
          if (profileImage == null)
          IconButton(
            icon: const Icon(CupertinoIcons.profile_circled),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UserProfile()),
              );
            },
          ),
        ],
      ),
    );
  }

  //Function to save habit data in Firebase
  void saveHabitData(String uid, String formattedDate, String habit, String value) async {
    DocumentReference habitCollectionRef = FirebaseFirestore.instance
      .collection('Habits')
      .doc(uid)
      .collection(formattedDate)
      .doc('habits');
    await habitCollectionRef.set({habit: value}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
  //Variables
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;
  final uid = user?.uid;
  String uid2 = uid.toString();

  //Returns the app bar & habit cards
  return Scaffold(
    backgroundColor: const Color(0xFFFAF9F6),
    appBar: homePageAppBar(context),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Expanded(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: deleteDate,
                ),
                GestureDetector(
                  onTap: () {
                    chooseDate(context);
                  },
                  child: Container(
                    height: 46,
                    width: 256,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        selectedDate,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => addDate(),
                ),
              ],
            ),
              const SizedBox(height: 20),
              Expanded(
                child: StreamBuilder<Map<String, bool>> (
                  stream: fetchSelectedHabits(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (!snapshot.hasData) {
                      return const Text("No habit cards found");
                    }
                    var selectedHabits = snapshot.data!;
                      return GridView.count(
                      key: const PageStorageKey<String>(''),
                      controller: scroll,
                      crossAxisCount: 2,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: [
                        if (selectedHabits['Calories'] ?? true)
                        HabitCard(
                          title: 'Calories',
                          image: 'lib/images/burger.png',
                          backgroundColor: Colors.red,
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'calories', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(kcal)',
                        ),
                        if (selectedHabits['Sleep'] ?? true)
                        HabitCard(
                          title: 'Sleep',
                          image: 'lib/images/bed.png',
                          backgroundColor: Colors.purple,
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'sleep', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Hours)'
                        ),
                        if (selectedHabits['Water'] ?? true)
                        HabitCard(
                          title: 'Water',
                          image: 'lib/images/water.png',
                          backgroundColor: Colors.lightBlue,
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'water', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Fluid Ounces)',
                        ),
                        if (selectedHabits['Protein'] ?? true)
                        HabitCard(
                          title: 'Protein',
                          image: 'lib/images/protein.png',
                          backgroundColor: Colors.brown,
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'protein', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Grams)'
                        ),
                        if (selectedHabits['Weight'] ?? true)
                        HabitCard(
                          title: 'Weight',
                          image: 'lib/images/weigh-scales.png',
                          backgroundColor: Colors.grey[700] ?? Colors.grey,
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'weight', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Pounds)'
                        ),
                        if (selectedHabits['Carbohydrates'] ?? true)
                        HabitCard(
                          title: 'Carbohydrates',
                          image: 'lib/images/bread.png',
                          backgroundColor: Colors.cyan,
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'carbohydrates', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Grams)'
                        ),
                        if (selectedHabits['Sugar'] ?? true)
                        HabitCard(
                          title: 'Sugar',
                          image: 'lib/images/sugar.png',
                          backgroundColor: const Color.fromARGB(255, 255, 116, 163),
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'sugar', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Grams)'
                        ),
                        if (selectedHabits['Running'] ?? true)
                        HabitCard(
                          title: 'Running',
                          image: 'lib/images/jogging.png',
                          backgroundColor: Colors.green,
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'running', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Miles)'
                        ),
                        if (selectedHabits['Pushups'] ?? true)
                        HabitCard(
                          title: 'Pushups',
                          image: 'lib/images/push-up.png',
                          backgroundColor: const Color.fromARGB(255, 175, 142, 76),
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'pushups', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Count)'
                        ),
                        if (selectedHabits['Pullups'] ?? true)
                        HabitCard(
                          title: 'Pullups',
                          image: 'lib/images/pull-up-bar.png',
                          backgroundColor: const Color.fromARGB(255, 76, 165, 175),
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'pullups', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Count)'
                        ),
                        if (selectedHabits['Situps'] ?? true)
                        HabitCard(
                          title: 'Situps',
                          image: 'lib/images/sit-up.png',
                          backgroundColor: const Color.fromARGB(255, 209, 116, 238),
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'situps', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Count)'
                        ),
                        if (selectedHabits['Sodium'] ?? true)
                        HabitCard(
                          title: 'Sodium',
                          image: 'lib/images/sodium.png',
                          backgroundColor: const Color.fromARGB(255, 238, 116, 177),
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'sodium', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Miligrams)'
                        ),
                        if (selectedHabits['Fats'] ?? true)
                        HabitCard(
                          title: 'Fats',
                          image: 'lib/images/fat.png',
                          backgroundColor: const Color.fromARGB(255, 116, 238, 124),
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'fats', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Grams)'
                        ),
                        if (selectedHabits['Cholesterol'] ?? true)
                        HabitCard(
                          title: 'Cholesterol',
                          image: 'lib/images/colesterol.png',
                          backgroundColor: const Color.fromARGB(255, 248, 202, 17),
                          onTap: (value) {
                            saveHabitData(uid2, formattedDate, 'cholesterol', value);
                          },
                          selectedDate: formattedDate,
                          unit: '(Miligrams)'
                        ),
                      ],
                    );
                  }
                ),
              ),
            ],
          ),
      ),
    ),
    /*
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80.0),
        child: FloatingActionButton(
          onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HabitToggle()),
              );
            },
            ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      */
    );
  }
}
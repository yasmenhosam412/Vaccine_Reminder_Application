import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:workmanager/workmanager.dart';
import 'MainScreen.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeNotifications();
  await updateSecurityProvider();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  Workmanager().registerPeriodicTask(
    "1",
    "checkDatesTask",
    frequency: const Duration(hours: 24),
    initialDelay: const Duration(seconds: 5),
  );

  runApp(MainApp());
}

Future<void> updateSecurityProvider() async {
  if (Platform.isAndroid) {
    try {
      const platform = MethodChannel('flutter/sslprovider');
      await platform.invokeMethod('updateSecurityProvider');
      print("Security provider updated successfully");
    } catch (e) {
      print("Failed to update security provider: $e");
    }
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await initializeNotifications();

    if (task == "checkDatesTask") {
      print("Background task started");
      await checkDatesAndNotify();
    }
    return Future.value(true);
  });
}

Future<void> checkDatesAndNotify() async {
  try {
    DateTime currentDate = DateTime.now();
    String formattedCurrentDate =
        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";

    List<Map<String, dynamic>> allPetsData = [];

    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Pet_Info").get();

    for (var doc in querySnapshot.docs) {
      String petRealName = doc["petName"];
      String petId = doc["docId"];
      List<dynamic> fetchedList = doc['nameAndDateList'];

      for (int i = 0; i < fetchedList.length; i++) {
        var item = fetchedList[i];
        allPetsData.add({
          'petId': petId,
          'date': item['date'],
          'name': item['name'],
          'realName': petRealName,
          'index': i,
        });
      }
    }

    // Filter entries matching today's date
    List<Map<String, dynamic>> matchedPets = allPetsData
        .where((item) => item['date'] == formattedCurrentDate)
        .toList();

    if (matchedPets.isNotEmpty) {
      for (var pet in matchedPets) {
        await sendRealNotification(
          flutterLocalNotificationsPlugin,
          "Reminder",
          "Today's reminder for: ${pet['name']} (Pet: ${pet['realName']})",
        );

        await createFirebaseNoti(
            pet['name']!, pet['realName']!, pet['petId']!, pet['index']);
      }
    }
  } catch (e) {
    print("Error in checkDatesAndNotify: $e");
    Fluttertoast.showToast(msg: "Error in checkDatesAndNotify: $e");
  }
}

Future<void> createFirebaseNoti(
    String petName, String realName, String petId, int index) async {
  var x = await FirebaseFirestore.instance.collection("Noti_Pets").doc();

  var docId = x.id;

  String faormatted = DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());

  await x.set({
    'vac': petName,
    'realName': realName,
    'notiText': "$realName Should Take $petName",
    'docId': docId,
    "petId": petId,
    'index': index,
    "btnColor": "red",
    "dateAndTime": faormatted
  }).then((_) {
    print("Notification created for $petName with ID: $docId");
  }).catchError((error) {
    print("Error creating notification for $petName: $error");
  });
}

Future<void> sendRealNotification(
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  String title,
  String body,
) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'reminder_channel',
    'Reminders',
    channelDescription: 'Notifications for important reminders',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}

Future<void> initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    print("Foreground message: ${message.notification?.title}");
    if (message.notification != null) {
      await sendRealNotification(
        flutterLocalNotificationsPlugin,
        message.notification!.title ?? "No Title",
        message.notification!.body ?? "No Body",
      );
    }
  });
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling background message: ${message.messageId}");

  if (message.notification != null) {
    await sendRealNotification(
      flutterLocalNotificationsPlugin,
      message.notification!.title ?? "No Title",
      message.notification!.body ?? "No Body",
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    check();
  }

  void check() {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const MainScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          "assets/pet.gif",
          width: 125,
          height: 125,
        ),
      ),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  final String petName;
  final String petAge;
  final String spec;
  final String gender;
  final String spy;
  final String vac;
  final String petId;

  const DetailsScreen({
    super.key,
    required this.petName,
    required this.petId,
    required this.petAge,
    required this.spec,
    required this.gender,
    required this.spy,
    required this.vac,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  List<Map<String, dynamic>> nameAndDateList = [];
  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();

  TextEditingController unitController = TextEditingController();

  String docID = '';

  var color1 = Colors.indigo;
  var color2 = Colors.indigo;
  var color3 = Colors.indigo;
  var color4 = Colors.indigo;
  String selectedTimeUnit = '';

  @override
  void initState() {
    super.initState();
    fetchBy(widget.petId);
    _startBackgroundTask();
  }

  Future<void> _startBackgroundTask() async {
    await Workmanager().registerPeriodicTask(
      "1", // Task ID
      "checkDatesTask",
      frequency: const Duration(minutes: 15),
      // Set the interval for checking dates
      inputData: <String, dynamic>{},
    );
  }

  Future<void> fetchBy(String id) async {
    try {
      var x =
          await FirebaseFirestore.instance.collection("Pet_Info").doc(id).get();
      if (x.exists) {
        setState(() {
          docID = x.get('docId');
          nameAndDateList =
              List<Map<String, dynamic>>.from(x.get('nameAndDateList'));
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> updateCheck(int index, bool done) async {
    try {
      setState(() {
        nameAndDateList[index]['done'] = done;
      });

      await FirebaseFirestore.instance
          .collection("Pet_Info")
          .doc(widget.petId)
          .update({
        'nameAndDateList': nameAndDateList,
      });
    } catch (e) {
      print("Error updating data: $e");
    }
  }

  Future<void> openCalendar() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        date.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> addNew(String id) async {
    try {
      await FirebaseFirestore.instance.collection("Pet_Info").doc(id).update({
        'nameAndDateList': nameAndDateList,
      });
    } catch (e) {
      print("Error adding new data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F8FC),
      appBar: AppBar(
        title: Text(
          widget.petName,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff344CB7),
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              openAlert(context, widget.petName, widget.petAge, widget.spec,
                  widget.gender, widget.vac, widget.spy);
            },
            icon: Icon(Icons.info, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _customTextField("Name", name, Icons.pets),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child:
                        _customTextField("Date", date, Icons.calendar_today)),
                IconButton(
                  onPressed: openCalendar,
                  icon: Icon(Icons.calendar_month, color: Color(0xff344CB7)),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildTimeUnitButtons(),
            const SizedBox(height: 20),
            _buildUnitInputField(),
            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              onPressed: _addNewEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff344CB7),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                "Add New",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Divider(
              color: Colors.black,
              height: 1,
              thickness: 1,
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(child: _buildNameAndDateList()),
          ],
        ),
      ),
    );
  }

  Widget _customTextField(
      String hint, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Color(0xff344CB7)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  Widget _buildTimeUnitButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _timeUnitButton("Year", color1, () {
          setState(() {
            color1 = Colors.green;
            color2 = Colors.indigo;
            color3 = Colors.indigo;
            color4 = Colors.indigo;
            selectedTimeUnit = 'Year';
          });
        }),
        _timeUnitButton("Month", color2, () {
          setState(() {
            color2 = Colors.green;
            color1 = Colors.indigo;
            color3 = Colors.indigo;
            color4 = Colors.indigo;
            selectedTimeUnit = 'Month';
          });
        }),
        _timeUnitButton("Week", color3, () {
          setState(() {
            color3 = Colors.green;
            color1 = Colors.indigo;
            color2 = Colors.indigo;
            color4 = Colors.indigo;
            selectedTimeUnit = 'Week';
          });
        }),
        _timeUnitButton("Day", color4, () {
          setState(() {
            color4 = Colors.green;
            color2 = Colors.indigo;
            color3 = Colors.indigo;
            color1 = Colors.indigo;
            selectedTimeUnit = 'Day';
          });
        }),
      ],
    );
  }

  Widget _timeUnitButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(label, style: TextStyle(color: Colors.white)),
    );
  }

  void _addNewEntry() async {
    if (name.text.isNotEmpty &&
        date.text.isNotEmpty &&
        selectedTimeUnit.isNotEmpty &&
        unitController.text.isNotEmpty) {
      setState(() {
        String newId =
            FirebaseFirestore.instance.collection("Pet_Info").doc().id;
        nameAndDateList.add({
          "name": name.text,
          "date": date.text,
          "timeUnit": selectedTimeUnit,
          "unitValue": int.tryParse(unitController.text) ?? 1, // Default to 1
          "id": newId,
        });
      });

      // Reset fields
      color1 = Colors.indigo;
      color2 = Colors.indigo;
      color3 = Colors.indigo;
      color4 = Colors.indigo;
      selectedTimeUnit = '';
      unitController.clear();
      name.clear();
      date.clear();

      await addNew(widget.petId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Please fill in name, date, number, and select time unit')),
      );
    }
  }

  Widget _buildUnitInputField() {
    return TextField(
      controller: unitController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "Enter number of $selectedTimeUnit(s)",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildNameAndDateList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: nameAndDateList.length,
      itemBuilder: (context, index) {
        var item = nameAndDateList[index];

        return Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            onLongPress: () {
              _showDeleteConfirmationDialog(context, index, item['id'], docID);
            },
            contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xff344CB7).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.pets, color: Color(0xff344CB7), size: 28),
            ),
            title: Text(
              item['name']!,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      item['date']!,
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '(Every ${item['unitValue']} ${item['timeUnit']})',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, int index, String petId, docID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: const Text("Do you really want to delete this date?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              // Get the document ID of the selected item (based on the index)
              var item = nameAndDateList[index];
              String itemId =
                  item['id']; // Get the 'id' from the local list item

              // Call the Firestore deletion method
              await _deleteFromFirestore(petId, itemId, docID);

              // Remove the item from the local list after deletion
              setState(() {
                nameAndDateList.removeAt(index);
              });

              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFromFirestore(String petId, String itemId, docIId) async {
    try {
      // Get the pet's Firestore document reference
      DocumentReference petDocRef =
          FirebaseFirestore.instance.collection("Pet_Info").doc(docIId);

      // Fetch the pet document
      DocumentSnapshot petDoc = await petDocRef.get();

      if (petDoc.exists) {
        // Get the current nameAndDateList
        Map<String, dynamic>? petData = petDoc.data() as Map<String, dynamic>?;
        List<dynamic> nameAndDateList =
            List.from(petData?["nameAndDateList"] ?? []);

        // Remove the item with the matching 'id'
        nameAndDateList.removeWhere((item) => item['id'] == itemId);

        // Update the pet document with the modified list
        await petDocRef.update({
          "nameAndDateList": nameAndDateList,
        });
      }
    } catch (e) {
      print("Error deleting item from Firestore: $e");
    }
  }

  Widget textField(
      {required String hint,
      required TextEditingController controller,
      required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void openAlert(BuildContext context, name, age, spec, gender, vac, spy) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Center(
            child: Text(
              "Pet Information",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xff344CB7),
              ),
            ),
          ),
          content: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoRow(Icons.pets, "Name", name, Colors.blue),
                _infoRow(Icons.cake, "Age", age, Colors.green),
                _infoRow(Icons.nature, "Species", spec, Colors.orange),
                _infoRow(Icons.person, "Gender", gender, Colors.pink),
                _infoRow(Icons.medical_services, "Vaccinated", vac,
                    Colors.blueAccent),
                _infoRow(
                    Icons.check_circle, "Neutered/Spayed", spy, Colors.teal),
              ],
            ),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff344CB7),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: $value",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class NotiScreen extends StatefulWidget {
  const NotiScreen({super.key});

  @override
  State<NotiScreen> createState() => _NotiScreenState();
}

class _NotiScreenState extends State<NotiScreen> {
  List<Map<String, dynamic>> myData = [];
  List<String> dateOptions = [];
  String selectedDateFilter = 'All';

  @override
  void initState() {
    super.initState();
    fetchNotis();
  }

  Future<void> fetchNotis() async {
    try {
      FirebaseFirestore.instance
          .collection("Noti_Pets")
          .snapshots()
          .listen((snapshot) {
        List<Map<String, dynamic>> notifications = snapshot.docs.map((doc) {
          return {
            'vac': doc['vac']?.toString() ?? 'Unknown',
            'realName': doc['realName']?.toString() ?? 'No Name',
            'notiText': doc['notiText']?.toString() ?? 'None',
            'docId': doc.id,
            'petId': doc['petId']?.toString() ?? '',
            'index': doc['index'] ?? 0,
            'btnColor': doc['btnColor'] ?? 'red',
            "dateAndTime": doc['dateAndTime'] ?? "Unknown"
          };
        }).toList();

        Set<String> uniqueDates = {};
        for (var notification in notifications) {
          String formattedDate =
              formatDate(_parseDate(notification['dateAndTime']));
          uniqueDates.add(formattedDate);
        }

        uniqueDates.add('All');

        List<Map<String, dynamic>> filteredNotifications =
            notifications.where((notification) {
          DateTime notificationDate = _parseDate(notification['dateAndTime']);
          String formattedDate = formatDate(notificationDate);

          if (selectedDateFilter == 'All') {
            return true;
          } else {
            return formattedDate == selectedDateFilter;
          }
        }).toList();

        setState(() {
          myData = filteredNotifications;
          dateOptions = uniqueDates.toList();
        });
      });
    } catch (e) {
      print("Error fetching notifications: $e");
    }
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  DateTime _parseDate(String dateString) {
    try {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd hh:mm a");
      return dateFormat.parse(dateString);
    } catch (e) {
      print("Error parsing date: $e");
      return DateTime.now();
    }
  }

  String formatDate(DateTime date) {
    DateFormat dateFormat = DateFormat('d/M/yyyy');
    return dateFormat.format(date);
  }

  @override
  Widget build(BuildContext context) {
    myData.sort((a, b) {
      bool aDone = a['btnColor'] == "green";
      bool bDone = b['btnColor'] == "green";
      return aDone ? 1 : -1;
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Styled Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDateFilter,
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black54),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedDateFilter = newValue!;
                    });
                    fetchNotis();
                  },
                  items:
                      dateOptions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Notification List
            Expanded(
              child: ListView.builder(
                itemCount: myData.length,
                itemBuilder: (BuildContext context, int index) {
                  var data = myData[index];

                  return Dismissible(
                    key: Key(data['docId']),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      deleteNotification(data['docId']);
                      setState(() {
                        myData.removeAt(index);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Card(
                        color: Colors.white,
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Text(
                                data['vac']!,
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              // Pet Name
                              Text(
                                '🐾 Pet: ${data['realName']!}',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              // Notification Message
                              Text(
                                data['notiText']!,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              // Done Button
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: data['btnColor'] == "red"
                                        ? Colors.red.shade700
                                        : Colors.green,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    changeDate(data["petId"], data['docId'],
                                        data['index']);
                                  },
                                  child: const Text("✅ Mark as Done",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Date
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  formatDate(_parseDate(data['dateAndTime']!)),
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteNotification(String docId) {
    FirebaseFirestore.instance.collection("Noti_Pets").doc(docId).delete();
  }

  Future<void> changeDate(String? petId, String notiId, int index) async {
    try {
      await FirebaseFirestore.instance
          .collection("Noti_Pets")
          .doc(notiId)
          .update({"btnColor": "green"});

      setState(() {
        for (var item in myData) {
          if (item["docId"] == notiId) {
            item["btnColor"] = "green";
            break;
          }
        }
      });

      if (petId == null || petId.isEmpty) return;

      DocumentReference petDocRef =
          FirebaseFirestore.instance.collection("Pet_Info").doc(petId);
      DocumentSnapshot petDoc = await petDocRef.get();

      if (!petDoc.exists) return;

      Map<String, dynamic>? petData = petDoc.data() as Map<String, dynamic>?;

      if (petData == null || !petData.containsKey("nameAndDateList")) return;

      List<dynamic> nameAndDateList = List.from(petData["nameAndDateList"]);

      if (nameAndDateList.isEmpty ||
          index < 0 ||
          index >= nameAndDateList.length) {
        return; // Prevent index out-of-bounds error
      }

      String? currentDateString = nameAndDateList[index]["date"];
      if (currentDateString == null || currentDateString.isEmpty) return;

      DateTime currentDate;
      try {
        currentDate = DateTime.parse(currentDateString);
      } catch (e) {
        print("Error parsing current date: $e");
        return;
      }

      String selectedTimeUnit = nameAndDateList[index]["timeUnit"] ?? "";
      int unitValue =
          nameAndDateList[index]["unitValue"] ?? 1; // Default to 1 if null

      DateTime newDate;
      switch (selectedTimeUnit) {
        case 'Year':
          newDate = DateTime(
              currentDate.year + unitValue, currentDate.month, currentDate.day);
          break;
        case 'Month':
          newDate = DateTime(
              currentDate.year, currentDate.month + unitValue, currentDate.day);
          break;
        case 'Week':
          newDate = currentDate.add(Duration(days: unitValue * 7));
          break;
        case 'Day':
          newDate = currentDate.add(Duration(days: unitValue));
          break;
        default:
          return;
      }

      String formattedNewDate =
          "${newDate.year}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}";

      nameAndDateList[index]["date"] = formattedNewDate;

      await petDocRef.update({"nameAndDateList": nameAndDateList});
    } catch (e) {
      print("Error updating: $e");
    }
  }
}

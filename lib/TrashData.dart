import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'MainScreen.dart';

class TrashData extends StatefulWidget {
  const TrashData({super.key});

  @override
  State<TrashData> createState() => _TrashDataState();
}

class _TrashDataState extends State<TrashData> {
  List<Map<String, dynamic>> myData = [];
  bool isLoading = true;
  TextEditingController searchCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("Trash").get();

      myData = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          "docId": doc.id,
          "petName": data["petName"] ?? "Unknown",
          "petAge": data["petAge"] ?? "Unknown",
          "Gender": data["Gender"] ?? "Unknown",
          "Species": data["Species"] ?? "Unknown",
          "Spayed": data["Spayed"] ?? "No",
          "Vaccinated": data["Vaccinated"] ?? "No",
          "nameAndDateList": data["nameAndDateList"] ?? [],
        };
      }).toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void search(String query) {
    if (query.isEmpty) {
      fetchData();
    }

    setState(() {
      myData = myData
          .where((item) => item['petName']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> resetData(Map<String, dynamic> data) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference newDocRef =
          firestore.collection("Pet_Info").doc(data['docId']);

      await newDocRef.set({
        "petName": data["petName"],
        "petAge": data["petAge"],
        "Gender": data["Gender"],
        "Species": data["Species"],
        "Spayed": data["Spayed"],
        "Vaccinated": data["Vaccinated"],
        "nameAndDateList": data["nameAndDateList"],
        "docId": data["docId"], // Ensure docId is saved
      });

      await firestore.collection("Trash").doc(data['docId']).delete();

      Fluttertoast.showToast(msg: "Pet data has been restored successfully.");

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
      fetchData();
    } catch (e) {
      Fluttertoast.showToast(msg: "Error restoring pet data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        title: Text(
          "Deleted Pets",
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: searchCon,
                onChanged: search,
                decoration: InputDecoration(
                  hintText: 'Search by Pet Name...',
                  prefixIcon: Icon(Icons.search, color: Colors.red.shade800),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : myData.isEmpty
                      ? Center(
                          child: Text(
                            "No Deleted Pets Found",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.0,
                            mainAxisSpacing: 12.0,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: myData.length,
                          itemBuilder: (context, index) {
                            var data = myData[index];

                            return InkWell(
                              onTap: () {
                                openAlert(context, data);
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        maxLines: 1,
                                        data['petName'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        "Age: ${data['petAge']}",
                                        maxLines: 1,
                                      ),
                                      Text("Gender: ${data['Gender']}"),
                                      Text("Species: ${data['Species']}"),
                                      Text("Spayed: ${data['Spayed']}"),
                                      Text("Vaccinated: ${data['Vaccinated']}"),
                                      SizedBox(height: 10),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.green.shade700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: () {
                                          showResetDialog(context, data);
                                        },
                                        child: Text(
                                          "Restore Pet",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
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

  void showResetDialog(BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 40),
              SizedBox(height: 10),
              Text(
                "Restore Pet?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          content: Text(
            "Do you want to restore this pet's data?",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                resetData(data);
                Navigator.of(context).pop();
              },
              child: Text(
                "Yes, Restore",
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void openAlert(BuildContext context, data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              Icon(Icons.pets, color: Colors.redAccent),
              SizedBox(width: 8),
              Text(
                "Pet Data",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(color: Colors.grey.shade300),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: (data['nameAndDateList'] as List).length,
                    itemBuilder: (context, index) {
                      final entry = data['nameAndDateList'][index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.event, color: Colors.blueAccent),
                          title: Text(
                            '${entry['name']}',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          subtitle: Text(
                            '📅 ${entry['date']} \n⏳ Every ${entry['timeUnit']}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "CLOSE",
                style: TextStyle(
                    color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

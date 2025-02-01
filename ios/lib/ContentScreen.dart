import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'AddScreen.dart';
import 'main.dart';

class ContentScreen extends StatefulWidget {
  ContentScreen();

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  List<Map<String, dynamic>> myData = []; // Updated to dynamic for flexibility
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
          await FirebaseFirestore.instance.collection("Pet_Info").get();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100, // Soft background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.all(14),
              child: TextField(
                controller: searchCon,
                onChanged: search,
                decoration: InputDecoration(
                  hintText: 'Search Pets...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                ),
              ),
            ),

            // Check Dates Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff344CB7),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                checkDatesAndNotify();
              },
              child: Text("Check Dates Now",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),

            SizedBox(height: 12),

            // Pet Grid with RefreshIndicator
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData, // Method to reload data
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : myData.isEmpty
                        ? Center(
                            child: Text(
                              "No Pets Found",
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600),
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.only(top: 8),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, // Two items per row
                              crossAxisSpacing: 12.0,
                              mainAxisSpacing: 12.0,
                              childAspectRatio:
                                  0.7, // Adjusts item aspect ratio
                            ),
                            itemCount: myData.length,
                            itemBuilder: (BuildContext context, int index) {
                              var data = myData[index];

                              return InkWell(
                                onLongPress: () {
                                  _showDeleteDialog(context, data['docId']);
                                },
                                onTap: () {
                                  _navigateToDetails(context, data);
                                },
                                child: Card(
                                  color: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // Pet Name
                                        Text(
                                          maxLines: 1,
                                          data['petName'] ?? 'Unknown',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        SizedBox(height: 5),

                                        // Edit Button
                                        IconButton(
                                          onPressed: () {
                                            _navigateToEditScreen(
                                                context, data);
                                          },
                                          icon: Icon(Icons.edit,
                                              color: Color(0xff577BC1)),
                                        ),
                                        SizedBox(height: 5),

                                        // Pet Age
                                        Text(
                                          maxLines: 1,
                                          'Age: ${data['petAge'] ?? 'N/A'}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87),
                                        ),
                                        SizedBox(height: 10),

                                        // Pet Details
                                        _buildPetDetail(
                                            "Gender", data['Gender']),
                                        _buildPetDetail(
                                            "Species", data['Species']),
                                        _buildPetDetail(
                                            "Spayed", data['Spayed']),
                                        _buildPetDetail(
                                            "Vaccinated", data['Vaccinated']),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff344CB7),
        tooltip: "Add a new pet",
        child: Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: () {
          _navigateToAddScreen(context);
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });

    await fetchData();

    setState(() {
      isLoading = false;
    });
  }

// Helper Methods
  void _showDeleteDialog(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.red, size: 40),
              SizedBox(height: 10),
              Text(
                "Are You Sure?",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
              ),
            ],
          ),
          content: Text(
            "Do you really want to delete this pet? This action cannot be undone.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                delete(docId);
                Navigator.of(context).pop();
              },
              child: Text("Yes, Delete", style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToDetails(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          petName: data['petName'],
          petAge: data['petAge'],
          spec: data['Species'],
          gender: data['Gender'],
          spy: data['Spayed'],
          vac: data['Vaccinated'],
          petId: data['docId'],
        ),
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context, Map<String, dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScreen(
          name: data['petName'],
          age: data['petAge'],
          spec: data['Species'],
          gen: data['Gender'],
          spy: data['Spayed'],
          vac: data['Vaccinated'],
          isEdit: true,
          docId: data["docId"],
        ),
      ),
    );
  }

  void _navigateToAddScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddScreen(
          name: '',
          age: '',
          spec: '',
          gen: '',
          spy: '',
          vac: '',
          isEdit: false,
          docId: '',
        ),
      ),
    );
  }

  Widget _buildPetDetail(String title, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$title: ${value ?? 'N/A'}',
        style: TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87),
      ),
    );
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

  Future<void> delete(id) async {
    try {
      // First, get the pet details before deletion
      var petDoc =
          await FirebaseFirestore.instance.collection("Pet_Info").doc(id).get();

      if (petDoc.exists) {
        var petData = petDoc.data() as Map<String, dynamic>;
        var name = petData['petName'];
        var age = petData['petAge'];
        var spec = petData['Species'];
        var gender = petData['Gender'];
        var spy = petData['Spayed'];
        var vac = petData['Vaccinated'];

        var nameAndDateList =
            List<Map<String, dynamic>>.from(petData['nameAndDateList']);

        await SaveToTrash(name, age, spec, gender, spy, vac, nameAndDateList);

        await FirebaseFirestore.instance
            .collection("Pet_Info")
            .doc(id)
            .delete();

        Fluttertoast.showToast(msg: "Deleted Successfully");

        setState(() {
          myData.removeWhere((item) => item['docId'] == id);
        });
      } else {
        Fluttertoast.showToast(msg: "Pet not found for deletion.");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error deleting pet: $e");
    }
  }

  Future<void> SaveToTrash(
      String name,
      String age,
      String spec,
      String gender,
      String spy,
      String vac,
      List<Map<String, dynamic>> nameAndDateList) async {
    try {
      var id = await FirebaseFirestore.instance.collection("Trash").add({
        "petName": name,
        "petAge": age,
        "Species": spec,
        "Gender": gender,
        "Spayed": spy,
        "Vaccinated": vac,
        "nameAndDateList": nameAndDateList,
        "deletedAt": Timestamp.now(),
      });

      final docId = id.id;
      await id.update({"docId": docId});

      Fluttertoast.showToast(msg: "Moved to Trash");
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving to Trash: $e");
    }
  }
}

Widget textField({
  required String hint,
  required TextEditingController controller,
  IconData? icon, // Optional icon parameter
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: 15,
          ),
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.grey.shade600) : null,
          border: InputBorder.none,
        ),
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
    ),
  );
}

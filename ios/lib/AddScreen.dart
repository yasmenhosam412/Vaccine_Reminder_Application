import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'MainScreen.dart';
import 'main.dart';

class AddScreen extends StatefulWidget {
  final String name;
  final String age;
  final String gen;
  final String spec;
  final String vac;
  final String spy;
  final bool isEdit;
  final String docId;

  const AddScreen({
    super.key,
    this.name = '',
    this.age = '',
    this.gen = '',
    this.spec = '',
    this.vac = '',
    this.spy = '',
    required this.isEdit,
    required this.docId,
  });

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  late TextEditingController name;
  late TextEditingController age;

  int? _selectedGender;
  int? _selectedSpecies;
  int? _selectedVac;
  int? _selectedSpayed;

  String gender = 'UnKnown';
  String spec = 'Feline';
  String vac = 'UnKnown';
  String spy = 'UnKnown';

  @override
  void initState() {
    super.initState();
    name =
        TextEditingController(text: widget.name.isNotEmpty ? widget.name : '');
    age = TextEditingController(text: widget.age.isNotEmpty ? widget.age : '');

    _selectedGender =
        widget.gen.isNotEmpty ? _mapGenderToIndex(widget.gen) : null;
    _selectedSpecies =
        widget.spec.isNotEmpty ? _mapSpeciesToIndex(widget.spec) : null;
    _selectedVac = widget.vac.isNotEmpty ? _mapVacToIndex(widget.vac) : null;
    _selectedSpayed =
        widget.spy.isNotEmpty ? _mapSpayedToIndex(widget.spy) : null;
  }

  int _mapGenderToIndex(String gender) {
    switch (gender) {
      case 'Male':
        return 0;
      case 'Female':
        return 1;
      default:
        return 2; // 'Unknown'
    }
  }

  int _mapSpeciesToIndex(String species) {
    switch (species) {
      case 'Canine':
        return 0;
      case 'Feline':
        return 1;
      default:
        return 0; // Default case if needed
    }
  }

  int _mapVacToIndex(String vac) {
    return vac == 'Yes' ? 0 : 1;
  }

  int _mapSpayedToIndex(String spayed) {
    switch (spayed) {
      case 'Yes':
        return 0;
      case 'No':
        return 1;
      default:
        return 2; // 'Unknown'
    }
  }

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff344CB7),
        title: const Text("Add Pet Information",
            style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textField(
                hint: "Pet Name",
                controller: name,
                icon: Icons.pets,
                type: TextInputType.text),
            const SizedBox(height: 15),
            textField(
                hint: "Pet Age",
                controller: age,
                icon: Icons.cake,
                type: TextInputType.text),
            const SizedBox(height: 20),
            customRadioSection(
                title: "Species",
                options: ["Canine", "Feline"],
                groupValue: _selectedSpecies,
                onChanged: (int? value) =>
                    setState(() => _selectedSpecies = value)),
            customRadioSection(
                title: "Gender",
                options: ["Male", "Female", "Unknown"],
                groupValue: _selectedGender,
                onChanged: (int? value) =>
                    setState(() => _selectedGender = value)),
            customRadioSection(
                title: "Neutered/Spayed",
                options: ["Yes", "No", "Unknown"],
                groupValue: _selectedSpayed,
                onChanged: (int? value) =>
                    setState(() => _selectedSpayed = value)),
            customRadioSection(
                title: "Vaccinated",
                options: ["Yes", "No"],
                groupValue: _selectedVac,
                onChanged: (int? value) =>
                    setState(() => _selectedVac = value)),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff344CB7),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () {
                  if (widget.isEdit) {
                    UpdateData(widget.docId);
                  } else {
                    if (name.text.isEmpty || age.text.isEmpty) {
                      showEmptyConfirmationDialog();
                    } else {
                      saveData();
                    }
                  }
                },
                child: Text(widget.isEdit ? "Update" : "Next",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showEmptyConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Rounded Corners
          ),
          backgroundColor: Colors.white,
          // Background color
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.redAccent), // Warning Icon
              SizedBox(width: 10),
              Text(
                "Are You Sure?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want Name and Age to be empty (Unknown)?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                saveData(name: "Unknown", age: "Unknown");
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.redAccent, // Yes Button Color
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("Yes, Continue"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300], // No Button Color
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  Future<void> saveData({
    String? name,
    String? age,
  }) async {
    try {
      final docRef =
          await FirebaseFirestore.instance.collection("Pet_Info").add({
        "petName": name ?? this.name.text,
        "petAge": age ?? this.age.text,
        "Gender": _selectedGender == 0
            ? 'Male'
            : _selectedGender == 1
                ? 'Female'
                : 'Unknown',
        "Species": _selectedSpecies == 0 ? 'Canine' : 'Feline',
        "Spayed": _selectedSpayed == 0
            ? 'Yes'
            : _selectedSpayed == 1
                ? 'No'
                : 'Unknown',
        "Vaccinated": _selectedVac == 0 ? 'Yes' : 'No',
        "nameAndDateList": []
      });

      final docId = docRef.id;
      await docRef.update({"docId": docId});

      Fluttertoast.showToast(msg: "Data saved successfully!");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DetailsScreen(
            petName: this.name.text,
            petAge: this.age.text,
            gender: _selectedGender == 1
                ? 'Male'
                : _selectedGender == 2
                    ? 'Female'
                    : 'Unknown',
            spec: _selectedSpecies == 1 ? 'Canine' : 'Feline',
            spy: _selectedSpayed == 1
                ? 'Yes'
                : _selectedSpayed == 2
                    ? 'No'
                    : 'Unknown',
            vac: _selectedVac == 1 ? 'Yes' : 'No',
            petId: docId,
          ),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Error saving data: $e");
    }
  }

  Future<void> UpdateData(String docId) async {
    await FirebaseFirestore.instance.collection("Pet_Info").doc(docId).update({
      "petName": name.text.isNotEmpty ? name.text : "Unknown",
      "petAge": age.text.isNotEmpty ? age.text : "Unknown",
      "Gender": _selectedGender == 0
          ? 'Male'
          : _selectedGender == 1
              ? 'Female'
              : 'Unknown',
      "Species": _selectedSpecies == 0 ? 'Canine' : 'Feline',
      "Spayed": _selectedSpayed == 0
          ? 'Yes'
          : _selectedSpayed == 1
              ? 'No'
              : 'Unknown',
      "Vaccinated": _selectedVac == 0 ? 'Yes' : 'No',
    });
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => MainScreen()));
  }
}

class DateAndName extends StatefulWidget {
  final String name;
  final String age;
  final String spec;
  final String gender;
  final String vac;
  final String spy;
  final String docID;

  const DateAndName({
    super.key,
    required this.name,
    required this.age,
    required this.spec,
    required this.gender,
    required this.vac,
    required this.spy,
    required this.docID,
  });

  @override
  State<DateAndName> createState() => _DateAndNameState();
}

class _DateAndNameState extends State<DateAndName> {
  TextEditingController name = TextEditingController();
  TextEditingController date = TextEditingController();

  List<Map<String, dynamic>> nameAndDateList = [];
  List<bool> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F8FC),
      // Light background for better contrast
      appBar: AppBar(
        title: const Text(
          "Pet Information",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xff344CB7), // Dark Blue AppBar
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                          Icons.pets, "Name", widget.name, Color(0xff344CB7)),
                      _infoRow(Icons.cake, "Age", widget.age, Colors.green),
                      _infoRow(
                          Icons.nature, "Species", widget.spec, Colors.orange),
                      _infoRow(Icons.accessibility, "Gender", widget.gender,
                          Colors.pink),
                      _infoRow(Icons.medical_services, "Vaccinated", widget.vac,
                          Colors.blueAccent),
                      _infoRow(Icons.check_circle, "Neutered/Spayed",
                          widget.spy, Colors.teal),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff344CB7),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

Widget customRadioSection(
    {required String title,
    required List<String> options,
    required int? groupValue,
    required Function(int?) onChanged}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      Wrap(
        spacing: 10,
        children: options.asMap().entries.map((entry) {
          int index = entry.key;
          String option = entry.value;
          return ChoiceChip(
            label: Text(option),
            selected: groupValue == index,
            onSelected: (bool selected) => onChanged(selected ? index : null),
            selectedColor: Color(0xff344CB7),
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(
                color: groupValue == index ? Colors.white : Colors.black),
          );
        }).toList(),
      ),
    ],
  );
}

Widget textField(
    {required String hint,
    required TextEditingController controller,
    IconData? icon,
    required TextInputType type}) {
  return TextField(
    keyboardType: type,
    controller: controller,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade100,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Color(0xff344CB7)) : null,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
    ),
  );
}

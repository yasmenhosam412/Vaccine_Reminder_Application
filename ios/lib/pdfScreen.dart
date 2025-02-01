import 'dart:io';
import 'dart:typed_data';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter/rendering.dart';


import 'MainScreen.dart';


class PdfScreen extends StatefulWidget {
  const PdfScreen({super.key});

  @override
  State<PdfScreen> createState() => _PdfScreenState();
}

class _PdfScreenState extends State<PdfScreen> {
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController ownerNoController = TextEditingController();
  final TextEditingController studyDateController = TextEditingController();
  final TextEditingController speciesController = TextEditingController();
  final TextEditingController laDiamController = TextEditingController();
  final TextEditingController aoDiamController = TextEditingController();
  final TextEditingController laAoController = TextEditingController();
  final TextEditingController ivSdController = TextEditingController();
  final TextEditingController lvidDController = TextEditingController();
  final TextEditingController lvWdController = TextEditingController();
  final TextEditingController ivSsController = TextEditingController();
  final TextEditingController lvidSController = TextEditingController();
  final TextEditingController lvWsController = TextEditingController();
  final TextEditingController conclusionController = TextEditingController();
  final TextEditingController signController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('ECHO Report Entry',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSectionHeader("Owner Information"),
            buildTextField(
                TextInputType.text, "Owner Name", ownerNameController),
            buildTextField(TextInputType.phone, "Owner No", ownerNoController),
            buildTextField(
                TextInputType.datetime, "Study Date", studyDateController),
            buildTextField(TextInputType.text, "Species", speciesController),
            buildSectionHeader("2D Assessment"),
            buildTextField(TextInputType.number, "LA Diam.", laDiamController),
            buildTextField(TextInputType.number, "Ao Diam.", aoDiamController),
            buildTextField(TextInputType.number, "LA/Ao", laAoController),
            buildSectionHeader("M-Mode"),
            buildTextField(TextInputType.number, "IVSd", ivSdController),
            buildTextField(TextInputType.number, "LVIDd", lvidDController),
            buildTextField(TextInputType.number, "LVWd", lvWdController),
            buildTextField(TextInputType.number, "IVSs", ivSsController),
            buildTextField(TextInputType.number, "LVIDs", lvidSController),
            buildTextField(TextInputType.number, "LVWs", lvWsController),
            buildSectionHeader("Conclusion"),
            buildTextField(TextInputType.multiline, "Enter Conclusion",
                conclusionController,
                maxLines: 3),
            buildTextField(TextInputType.text, "Dr Signature", signController),
            const SizedBox(height: 20.0),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DisplayReportScreen(
                                ownerName: ownerNameController.text,
                                ownerNo: ownerNoController.text,
                                studyDate: studyDateController.text,
                                species: speciesController.text,
                                laDiam: laDiamController.text,
                                aoDiam: aoDiamController.text,
                                laAo: laAoController.text,
                                ivSd: ivSdController.text,
                                lvidD: lvidDController.text,
                                lvWd: lvWdController.text,
                                ivSs: ivSsController.text,
                                lvidS: lvidSController.text,
                                lvWs: lvWsController.text,
                                conclusion: conclusionController.text,
                                sign: signController.text,
                              )));
                },
                child: const Text("Save Report",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section Header Widget
  Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  /// Styled TextField Widget
  Widget buildTextField(
      TextInputType keyType, String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        keyboardType: keyType,
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle:
              TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}

class DisplayReportScreen extends StatelessWidget {
  final String ownerName;
  final String ownerNo;
  final String studyDate;
  final String species;
  final String laDiam;
  final String aoDiam;
  final String laAo;
  final String ivSd;
  final String lvidD;
  final String lvWd;
  final String ivSs;
  final String lvidS;
  final String lvWs;
  final String conclusion;
  final String sign;

  final GlobalKey _globalKey = GlobalKey(); // For screenshot
  final ScreenshotController screenshotController = ScreenshotController();

  DisplayReportScreen(
      {super.key,
      required this.ownerName,
      required this.ownerNo,
      required this.studyDate,
      required this.species,
      required this.laDiam,
      required this.aoDiam,
      required this.laAo,
      required this.ivSd,
      required this.lvidD,
      required this.lvWd,
      required this.ivSs,
      required this.lvidS,
      required this.lvWs,
      required this.conclusion,
      required this.sign});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Generated Report')),
      body: Screenshot(
        controller: screenshotController,
        child: RepaintBoundary(
          key: _globalKey,
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "assets/doc.png", // Ensure the correct image path
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              _buildText("Owner Name : $ownerName", 60, 180, -110, 100),

              _buildText("Owner No : $ownerNo", 50, 220, -110, 100),

              _buildText("Study Date : $studyDate", 60, 180, 190, 100),
              _buildText("Species : $species", 105, 220, 190, 100),

              // // 2D Assessment
              _buildText("LA Diam :  $laDiam cm", 115, 305, -75, 50),
              _buildText("Ao Diam : $aoDiam cm", 120, 326, -75, 50),
              _buildText("LA/AO : $laAo cm", 155, 343, -42, 50),
              //
              // // M-Mode Values
              _buildText("IVSd : $ivSd cm", 115, 308, 200, 50),
              _buildText("LVIDd : $lvidD cm", 115, 326, 200, 50),
              _buildText("LVWd : $lvWd cm", 60, 343, 150, 50),
              _buildText("IVSs : $ivSs cm", 95, 359, 170, 50),
              _buildText("LVIDs : $lvidS cm", 80, 375, 170, 50),
              _buildText("LVWs : $lvWs cm", 90, 395, 170, 50),

              Positioned(
                left: 55,
                top: 485,
                right: 120,
                bottom: 80,
                child: SizedBox(
                  width: 250,
                  child: Text(
                    conclusion,
                    style: textStyle,
                    textAlign: TextAlign.left,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              Positioned(
                bottom: 125,
                right: 25,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "D.R Signature : \n$sign",
                    textAlign: TextAlign.center,
                    style: textStyle,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          convertToPdf(context);
        },
        child: Icon(Icons.print),
      ),
    );
  }

  Widget _buildText(
      String text, double? right, double? top, double? left, double? bottom) {
    return Container(
      child: Positioned(
        right: right,
        left: left,
        bottom: bottom,
        top: top,
        child: Expanded(
          child: Text(
            text,
            style: textStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Future<void> convertToPdf(context) async {
    try {
      // Capture Screenshot
      final Uint8List? image = await screenshotController.capture();

      if (image == null) {
        print("Error capturing image.");
        Fluttertoast.showToast(msg: "error capture");
        return;
      }

      // Create a PDF document
      final pdf = pw.Document();

      // Add image to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                pw.MemoryImage(image),
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );

      // Get device storage path
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = "${directory.path}/Report.pdf";
      final File file = File(path);

      // Save the PDF file
      await file.writeAsBytes(await pdf.save());

      // Open the PDF (optional)
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      print("PDF saved at: $path");
      Fluttertoast.showToast(msg: "Done");
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => MainScreen()));
    } catch (e) {
      Fluttertoast.showToast(msg: "Not Done $e");
      print("Error generating PDF: $e");
    }
  }

  TextStyle get textStyle => const TextStyle(
        fontSize: 10,
        color: Colors.black,
      );
}

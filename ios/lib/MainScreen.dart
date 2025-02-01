import 'package:flutter/material.dart';
import 'package:ios/pdfScreen.dart';

import 'AddScreen.dart';
import 'ContentScreen.dart';
import 'NotiScreen.dart';
import 'TrashData.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,

      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TrashData()));
                },
                icon: Icon(
                  Icons.restore_from_trash_rounded,
                  color: Colors.white,
                  size: 35,
                )),

            IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PdfScreen()));
                },
                icon: Icon(
                  Icons.picture_as_pdf,
                  color: Colors.white,
                  size: 35,
                )),
          ],
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Color(0xff000957),
          bottom: TabBar(
            controller: tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: [
              Tab(
                icon: Column(
                  children: [
                    Icon(Icons.check, color: Color(0xffFFEB00), size: 30),
                  ],
                ),
              ),
              Tab(
                icon: Column(
                  children: [
                    Icon(Icons.notifications, color: Color(0xffFFEB00), size: 30),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            ContentScreen(),
            NotiScreen(),
          ],
        ),
      ),
    );
  }
}

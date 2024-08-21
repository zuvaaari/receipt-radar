//empty page in the app. probably have to change the bottom nav stuff depending on which page!
/*
import 'package:flutter/material.dart';
//import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:receipt_radar_1/screens/receipt_details.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Color(0xFF457D58)],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[

            SizedBox(height: 1),


          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF457D58), Colors.black],
            //Color(0xFFE8F5ED), the light green one
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent, // Set background to transparent
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard, color: Colors.white),
              label: '', // Empty label
            ),
            //BottomNavigationBarItem(
            //icon: Icon(Icons.add_a_photo, size: 50, color: Colors.white),
            //label: '', // Empty label
            //),
            BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.account_circle, color: Colors.white),
                onPressed: () {

                },
              ),
              label: '', // Empty label
            ),
          ],
          //currentIndex: _selectedIndex,
          onTap: (index) {
            // Handle navigation
          },
        ),
      ),
    );
  }

}

*/
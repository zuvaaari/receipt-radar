import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:receipt_radar_1/features/home/home.dart';
import '../authentication/change_password.dart';
import '../authentication/login.dart';
import 'receipt_stats.dart';
import '../services/notif.dart';

class UserProfile extends StatefulWidget {
  UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  int _selectedIndex = 0; //for bottom nav thing
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  late final NotificationManager notificationManager;

  @override
  void initState() {
    super.initState();
    notificationManager = NotificationManager(uid: uid);
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    // Requesting permission
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // If not allowed, show dialog to ask for permission
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Allow Notifications"),
            content: Text("Our app would like to send you notifications."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Don't Allow"),
              ),
              TextButton(
                onPressed: () {
                  // This will open the app's settings to allow the user to grant the permission
                  AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context));
                },
                child: Text("Allow"),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<String> _fetchUserName() async {
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc.data()?['name'] ?? 'No Name';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text("User Profile",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20))),
        iconTheme: IconThemeData(color: Colors.white),
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
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'Sign Out') {
                // Show confirmation dialog
                final bool confirmSignOut = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color(0xFF457D58),
                          title: Text(
                            'Sign Out',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to sign out?',
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                'Sign Out',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false; // In case the dialog is dismissed

                // If the user confirmed, sign out and navigate
                if (confirmSignOut) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'Sign Out',
                child: Text('Sign Out'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildProfileSection(context),
              SizedBox(height: 20),
              _buildOutlinedButton("Set up Reminders",
                  () => _showReminderFrequencyDialog(context)),
              _buildOutlinedButton(
                  "Cancel Reminders", () => _cancelNotifications(context)),
              _buildOutlinedButton("Receipt Statistics", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReceiptStats()),
                );
              }),
              _buildOutlinedButton("Change Password", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePassword()),
                );
              }),
            ],
          ),
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
              icon: IconButton(
                icon: Icon(Icons.dashboard, color: Colors.white),
                //add something that wont do anything if u already on this page
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              label: '',
            ),
            //BottomNavigationBarItem(
            //icon: Icon(Icons.add_a_photo, size: 50, color: Colors.white),
            //label: '', // Empty label
            //),
            BottomNavigationBarItem(
              icon: IconButton(
                icon: Icon(Icons.account_circle, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserProfile()),
                  );
                },
              ),
              label: '', // Empty label
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return FutureBuilder<String>(
      future: _fetchUserName(),
      builder: (context, snapshot) {
        // Initialize userName here, inside the builder function
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        // If the snapshot has data, it's used; otherwise, 'Unknown User' is the default.
        final String userName = snapshot.data ?? 'Unknown User';

        // Construct the UI elements using userName within this builder function.
        return Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                    'assets/images/avatar.png'), // Use AssetImage for local assets
              ),
            ),
            SizedBox(height: 10),
            Text(
              userName, // Use the fetched or default userName here
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF457D58)),
            ),
            // Include any additional details or widgets that use userName or other user details here
          ],
        );
      },
    );
  }

  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Color(0xFF457D58),
          // Text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildReminderSetupSection(BuildContext context) {
    return Column(
      children: [
        _buildOutlinedButton(
            'Set up Reminders', () => _showReminderFrequencyDialog(context)),
        _buildOutlinedButton(
            'Cancel Reminders', notificationManager.cancelAllNotifications),
      ],
    );
  }

  void _showReminderFrequencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF457D58),
          title: Text(
            'Set up your reminders',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildReminderOption(context, 'Daily', 'Daily'),
              _buildReminderOption(context, 'Weekly', 'Weekly'),
              _buildReminderOption(context, 'Monthly', 'Monthly'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminderOption(
      BuildContext context, String title, String frequency) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      onTap: () {
        Navigator.of(context).pop();
        notificationManager.scheduleNotification(frequency);
      },
    );
  }

  void _cancelNotifications(BuildContext context) {
    notificationManager.cancelAllNotifications();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All reminders have been cancelled'),
      ),
    );
  }
}

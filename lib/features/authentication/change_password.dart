import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../home/home.dart';
import '../user/user_profile.dart';
import 'login.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose(); // Add this line
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text.trim() ==
        _confirmNewPasswordController.text.trim()) {
      final user = FirebaseAuth.instance.currentUser;
      final cred = EmailAuthProvider.credential(
        email: user!.email!,
        password: _currentPasswordController.text.trim(),
      );

      user.reauthenticateWithCredential(cred).then((value) {
        user.updatePassword(_newPasswordController.text.trim()).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password was changed successfully!")),
          );
          // Navigate back or clear the text fields
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error changing password")),
          );
        });
      }).catchError((err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error")),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("The new password does not match! Please check again!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text("Change Password",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20))),
        // Updated title
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                  child: Text(
                'Update Password Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              )),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: _currentPasswordController,
                decoration: InputDecoration(
                  hintText: 'Current Password',
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(50)),
                ),
                obscureText: true,
                obscuringCharacter: "*",
              ),
              SizedBox(height: 20),
              TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  hintText: 'New Password',
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(50)),
                ),
                obscureText: true,
                obscuringCharacter: "*",
              ),
              SizedBox(height: 20),
              TextField(
                controller: _confirmNewPasswordController,
                decoration: InputDecoration(
                  hintText: 'Confirm New Password',
                  fillColor: Colors.grey[200],
                  filled: true,
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(50)),
                ),
                obscureText: true,
                obscuringCharacter: "*",
              ),
              SizedBox(
                height: 50,
              ),
              Center(
                child: ElevatedButton(
                  onPressed: _changePassword,
                  child: Text(
                    'Confirm Changes',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF457D58),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
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
}

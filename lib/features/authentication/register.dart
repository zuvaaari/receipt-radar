import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:receipt_radar_1/features/authentication/login.dart';
import '../services/database.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;

  //final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  //text field state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        //resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          //adding a scroll view because it gets too long
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ////RECEIPT RADAR LOGO & TAGLINE START HERE
                Image.asset(
                  'assets/images/RR.png', //MAIN LOGO
                  width: 250,
                  height: 250,
                ),
                Text(
                  'Simplify your Expenses', //TAGLINE?
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black950,
                      fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: 15,
                ),

                ///END OF LOGO STUFF
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    //labelText: 'Email',
                    hintText: 'Name',
                    fillColor: Colors.white70,
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  keyboardType: TextInputType.name,
                ),
                SizedBox(
                  height: 15,
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    //labelText: 'Email',
                    hintText: 'Email Address',
                    fillColor: Colors.white70,
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    //labelText: 'Password',
                    fillColor: Colors.white70,
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 15),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    //labelText: 'Confirm Password',
                    hintText: 'Confirm Password',
                    fillColor: Colors.white70,
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  obscureText: true,
                ),
                //SizedBox(height: 15),
                SizedBox(height: 20),
                //between register button and all the textfields
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[950],
                      elevation: 5,
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    if (_passwordController.text ==
                        _confirmPasswordController.text) {
                      registerUser();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Passwords do not match")),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ));
  }

  void registerUser() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String name = _nameController.text.trim();

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        try {
          // Save user's name and email to Firestore
          await DatabaseService(uid: user.uid).updateUserdata(name, email);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        } catch (e) {
          print("Error saving user data to Firestore: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save user data")),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? "An error occurred")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An unexpected error occurred")),
      );
    }
  }
}

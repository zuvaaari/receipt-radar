import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:receipt_radar_1/features/authentication/forgot_password.dart';
import 'package:receipt_radar_1/features/authentication/login.dart';
import 'package:receipt_radar_1/features/splash/splash_screen1.dart';
import 'features/authentication/register.dart';
import 'features/services/firebase_options.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    //Firebase connection
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://receipt-radar-ee33f-default-rtdb.asia-southeast1.firebasedatabase.app/");

  //Allow app tp send local notifications
  AwesomeNotifications().initialize(
    'resource://drawable/ic_notification',
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF457D58),
        ledColor: Colors.white,
        playSound: true,
        enableLights: true,
        enableVibration: true,
      )
    ],
  );

  runApp(MyApp());
}

//Represents root of the app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //Remove the debug banner on the side
      title: 'Welcome',
      theme: ThemeData(
        fontFamily: 'Eczar',
        primaryColor: Colors.green[950],
      ),
      home: SplashScreen(), //Shows the splash thing when the app opens
    );
  }
}

class Main extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, //Avoid overflowing
      body: Container(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 40),
              Image.asset(
                'assets/images/RR.png',
                width: 250,
                height: 250,
              ),
              Text(
                'Simplify your Expenses',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Eczar',
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 70),

              //Sign in button
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[950],
                    elevation: 5,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              ),

              SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[950],
                    elevation: 5,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              ),
              //Register
              ElevatedButton(
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage()),
                  );
                },
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[950], //colour of the button
                    elevation: 5,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              ),
              SizedBox(
                height: 30,
              ),
              //Forgot Password, Click here
              TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPassword()),
                    );
                  },
                  child: const Text(
                    'Forgot your password? Click Here.',
                    style: TextStyle(
                      color: Colors.black950,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

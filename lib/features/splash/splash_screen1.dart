import 'package:flutter/material.dart';
import '../../main.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI for splash screen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Main()),
      );
    });

    return Scaffold(
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //Text('Simplify your Expenses'),
              //SizedBox(height: 16,),
              Image.asset('assets/images/logo.png', width: 200, height: 200),

            ],
          )
      ),
    );
  }
}

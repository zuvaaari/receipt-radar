import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../home/home.dart';
import '../services/firebase_options.dart';
import '../splash/splash_screen1.dart';
import 'forgot_password.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SplashScreen(),
    );
    //SizedBox(height: 10),
  }
}

//New Login UI
class LoginPage extends StatelessWidget {
  //final AuthService _auth = AuthService();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, //avoids overflowing
      body: Container(
        child: Center(
          child: Column(
            children: [
              Image.asset(
                'assets/images/RR.png', //MAIN LOGO
                width: 250,
                height: 250,
              ),
              Text(
                'Simplify your Expenses', //TAGLINE?
                style: TextStyle(fontSize: 20, color: Colors.black950),
              ),

              ///END OF LOGO STUFF
              SizedBox(height: 15),

              //email textfield
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    //labelText: 'Email',
                    hintText: 'Email',
                    fillColor: Colors.grey[200],
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50)),
                  ),
                  obscureText: false,
                ),
              ),
              SizedBox(height: 5),
              //determines the space between email and pass box.

              //password textfield
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: passwordController,
                  //intText: 'Username',
                  decoration: InputDecoration(
                    //labelText: 'Password',
                    hintText: 'Password',
                    //the overall design of the textfield
                    fillColor: Colors.grey[200],
                    filled: true,
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50)),
                  ),

                  obscureText: true,
                  obscuringCharacter: "*",
                  //autofillHints: ('dd'),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              //between textfields and sign in button
              //ADD COMMA TO END EACH SECTION!

              //sign in button
              ElevatedButton(
                onPressed: () async {
                  try {
                    UserCredential userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: emailController.text,
                      password: passwordController.text,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Invalid Credentials. Please Check Again!'),
                        //TODO: come up with a better error msg?
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
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
                height: 10,
              ),
              //TextButton

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

              //SizedBox(height: 20), i dont think this is related to anything?

              //

              //TODO: add the forget password stuff if free time?
            ],
          ),
        ),
      ),
    );
  }
}

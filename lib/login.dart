import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:safaai/bottomnav.dart';
import 'package:audioplayers/audioplayers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "", password = "";
  TextEditingController emailcontroller = new TextEditingController();
  TextEditingController passwordcontroller = new TextEditingController();
  final _formkey = GlobalKey<FormState>();
  AudioPlayer _player = AudioPlayer();
  userLogin() async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      var assetSource = AssetSource('welcome.mp3');
      await _player.play(assetSource);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color(0xFF18cc84),
              title: Text('We Dont Know You!'),
              content:
                  Text('Please introduce yourself by registering in our app.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
      if (e.code == 'invalid-email') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color(0xFF18cc84),
              title: Text('Invalid Email'),
              content: Text('The entered Email is invalid. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else if (e.code == "wrong-password") {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color(0xFF18cc84),
              title: Text('Invalid Password'),
              content:
                  Text('The entered Password is invalid. Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else if (e.code == 'user-mismatch') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: Color(0xFF18cc84),
              title: Text('Who are you?'),
              content: Text("We don't know you. SignUp instead."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/login.png'), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          margin: EdgeInsets.only(left: 15, right: 15, top: 10),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 35, right: 35),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              RotatedBox(
                                quarterTurns:
                                    3, // Rotate 90 degrees counterclockwise
                                child: Text(
                                  "Heyloo!",
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 50,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Gilroy',
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/welcome.png',
                                width: 200,
                                height: 200,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Email';
                              }
                              return null;
                            },
                            controller: emailcontroller,
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255)),
                            decoration: InputDecoration(
                                fillColor: Color.fromARGB(0, 255, 255, 255),
                                filled: true,
                                hintText: "Email",
                                hintStyle: TextStyle(
                                    fontSize: 20.0,
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255)),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color.fromARGB(255, 254, 215, 20),
                                      width: 5.0),
                                  borderRadius: BorderRadius.circular(50),
                                )),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter Password';
                              }
                              return null;
                            },
                            controller: passwordcontroller,
                            style: TextStyle(
                                color: Color.fromARGB(255, 255, 255, 255)),
                            obscureText: true,
                            decoration: InputDecoration(
                                fillColor: Color.fromARGB(0, 255, 255, 255),
                                filled: true,
                                hintText: "Password",
                                hintStyle: TextStyle(
                                    fontSize: 20.0, color: Color(0xFFFFFFFF)),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Color(0xFF18cc84), width: 5.0),
                                  borderRadius: BorderRadius.circular(50),
                                )),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = emailcontroller.text.trim();
                                  password = passwordcontroller.text.trim();
                                });
                              }
                              userLogin();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(
                                    vertical: 13.0, horizontal: 13.0),
                                decoration: BoxDecoration(
                                    color: Color(0xFF18cc84),
                                    borderRadius: BorderRadius.circular(30)),
                                child: Center(
                                    child: Text(
                                  "Log In",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 30, 29, 29),
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w500),
                                ))),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  'Sign Up',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 18),
                                ),
                                style: ButtonStyle(),
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(context, '/forgotpass');
                                  },
                                  child: Text(
                                    'Forgot Password',
                                    style: TextStyle(
                                      decoration: TextDecoration.none,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      fontSize: 18,
                                    ),
                                  )),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

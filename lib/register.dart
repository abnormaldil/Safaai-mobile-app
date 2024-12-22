import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safaai/home.dart';
import 'package:safaai/login.dart';
import 'package:safaai/otp_screen.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String name = "", email = "", phone = "", password = "", upi = "";
  final namecontroller = TextEditingController();
  //TextEditingController emailcontroller = new TextEditingController();
  final phonecontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  final upicontroller = TextEditingController();
  final emailcontroller = TextEditingController();
  final _formkey = GlobalKey<FormState>();
  EmailOTP myauth = EmailOTP();

  void dispose() {
    namecontroller.dispose();
    emailcontroller.dispose();
    passwordcontroller.dispose();
    phonecontroller.dispose();
    upicontroller.dispose();
    super.dispose();
  }

  void registration() async {
    // ignore: unnecessary_null_comparison
    if (password != null &&
        namecontroller.text != "" &&
        emailcontroller.text != "" &&
        phonecontroller.text != "" &&
        upicontroller.text != "") {
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);
        String uid = userCredential.user!.uid; // Get the UID

        myauth.setConfig(
          appEmail: "safaai.rit@gmail.com",
          appName: "Safaai",
          userEmail: email,
          otpLength: 4,
          otpType: OTPType.digitsOnly,
        );

        if (await myauth.sendOTP()) {
          // OTP sent successfully
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("OTP has been sent"),
          ));

          // Navigate to OTP verification screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(
                myauth: myauth,
                userEmail: emailcontroller.text.trim(),
              ),
            ),
          );
        } else {
          // Failed to send OTP
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Oops, OTP send failed"),
          ));
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(emailcontroller.text.trim())
            .set({
          'Name': namecontroller.text.trim(),
          'Email': emailcontroller.text.trim(),
          'PhoneNumber': int.parse(phonecontroller.text.trim()),
          'UpiId': upicontroller.text.trim(),
          'CreditBalance': 0,
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-email') {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Color.fromARGB(255, 42, 254, 169),
                title: Text('Invalid Email'),
                content: Text(
                    'That Email Might Be Missing a Few Pieces. Try Again!'),
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
        } else if (e.code == 'weak-password') {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Color.fromARGB(255, 42, 254, 169),
                title: Text('Weak Password'),
                content: Text('Your Password Need More Strength'),
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
        } else if (e.code == "email-already-in-use") {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Color.fromARGB(255, 42, 254, 169),
                title: Text('Hey I Know You!'),
                content: Text(
                    'Account already exists for this Email. Login instead'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Container(
          margin: EdgeInsets.only(left: 15, right: 15, top: 70),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.05),
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
                                  "Register",
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 50,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Gilroy',
                                    color:
                                        const Color.fromARGB(255, 80, 79, 79),
                                  ),
                                ),
                              ),
                              Image.asset(
                                'assets/adduser.png',
                                width: 200,
                                height: 200,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 13,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Your sweet name?';
                              }
                              return null;
                            },
                            controller: namecontroller,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 80, 79, 79),
                              fontFamily: 'Gilroy',
                            ),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color:
                                        const Color.fromARGB(255, 80, 79, 79),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                hintText: "Name",
                                hintStyle: TextStyle(
                                  color: const Color.fromARGB(255, 80, 79, 79),
                                  fontFamily: 'Gilroy',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                          ),
                          SizedBox(
                            height: 13,
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
                              color: const Color.fromARGB(255, 80, 79, 79),
                              fontFamily: 'Gilroy',
                            ),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color:
                                        const Color.fromARGB(255, 80, 79, 79),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                hintText: "Email",
                                hintStyle: TextStyle(
                                  color: const Color.fromARGB(255, 80, 79, 79),
                                  fontFamily: 'Gilroy',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                          ),
                          SizedBox(
                            height: 13,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              } else if (value.length != 10) {
                                return 'Please Enter a Valid 10-digit Number';
                              }
                              return null;
                            },
                            controller: phonecontroller,
                            keyboardType: TextInputType
                                .number, // Set keyboard type to number
                            inputFormatters: [
                              FilteringTextInputFormatter
                                  .digitsOnly, // Allow only numeric input
                              LengthLimitingTextInputFormatter(
                                  10), // Limit input to 10 characters
                            ],
                            style: TextStyle(
                              color: const Color.fromARGB(255, 80, 79, 79),
                              fontFamily: 'Gilroy',
                            ),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color:
                                        const Color.fromARGB(255, 80, 79, 79),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                hintText: "Phone Number",
                                hintStyle: TextStyle(
                                  color: const Color.fromARGB(255, 80, 79, 79),
                                  fontFamily: 'Gilroy',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                          ),
                          SizedBox(
                            height: 13,
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
                              color: const Color.fromARGB(255, 80, 79, 79),
                              fontFamily: 'Gilroy',
                            ),
                            obscureText: true,
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color:
                                        const Color.fromARGB(255, 80, 79, 79),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                hintText: "Password",
                                hintStyle: TextStyle(
                                  color: const Color.fromARGB(255, 80, 79, 79),
                                  fontFamily: 'Gilroy',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                          ),
                          SizedBox(
                            height: 13,
                          ),
                          TextFormField(
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter UpiId';
                              }
                              return null;
                            },
                            controller: upicontroller,
                            style: TextStyle(
                              color: const Color.fromARGB(255, 80, 79, 79),
                              fontFamily: 'Gilroy',
                            ),
                            decoration: InputDecoration(
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color:
                                        const Color.fromARGB(255, 80, 79, 79),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide(
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                hintText: "Upi Id",
                                hintStyle: TextStyle(
                                  color: const Color.fromARGB(255, 80, 79, 79),
                                  fontFamily: 'Gilroy',
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                )),
                          ),
                          SizedBox(
                            height: 23,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = emailcontroller.text.trim();
                                  name = namecontroller.text.trim();
                                  password = passwordcontroller.text;
                                  phone = phonecontroller.text.trim();
                                  upi = upicontroller.text.trim();
                                });
                              }
                              registration();
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(
                                    vertical: 13.0, horizontal: 13.0),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color.fromARGB(255, 37, 232, 154),
                                        Color.fromARGB(255, 42, 254, 169),
                                        Color.fromARGB(255, 29, 213, 140),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(30)),
                                child: Center(
                                    child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Gilroy',
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600),
                                ))),
                          ),
                          SizedBox(
                            height: 13,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(
                                      context); // Go back to login page
                                },
                                child: Text(
                                  'Sign In',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontFamily: 'Gilroy',
                                    fontSize: 18,
                                    color:
                                        const Color.fromARGB(255, 80, 79, 79),
                                  ),
                                ),
                                style: ButtonStyle(),
                              ),
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

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

  goToHome(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
}

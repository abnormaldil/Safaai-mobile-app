import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  String email = "";
  TextEditingController emailcontroller = new TextEditingController();
  final _formkey = GlobalKey<FormState>();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Check your email inbox",
        style: TextStyle(
          fontSize: 20.0,
          fontFamily: 'Gilroy',
        ),
      )));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color.fromARGB(255, 36, 36, 36),
            content: Text(
              "We don't know you!",
              style: TextStyle(
                decoration: TextDecoration.none,
                color: const Color.fromARGB(255, 80, 79, 79),
                fontFamily: 'Gilroy',
                fontSize: 18,
              ),
            )));
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Color.fromARGB(255, 36, 36, 36),
            content: Text(
              " That email might be missing a few pieces",
              style: TextStyle(
                decoration: TextDecoration.none,
                fontFamily: 'Gilroy',
                color: const Color.fromARGB(255, 255, 255, 255),
                fontSize: 18,
              ),
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   image: DecorationImage(
      //       image: AssetImage('assets/forgot.png'), fit: BoxFit.cover),
      // ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        body: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formkey,
                  child: Container(
                    padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(left: 35, right: 35),
                            child: Column(
                              children: [
                                Center(
                                  child: const Text(
                                    'Forgot your password?',
                                    style: TextStyle(
                                      fontSize: 25,
                                      color:
                                          const Color.fromARGB(255, 80, 79, 79),
                                      fontFamily: 'AvantGardeLT',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Image.asset(
                                  'assets/forgotpass.png',
                                  width: 140,
                                  height: 140,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Dont Worry!',
                                  textAlign: TextAlign.justify,
                                  style: TextStyle(
                                    decoration: TextDecoration.none,
                                    fontSize: 43,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'Gilroy',
                                    color:
                                        const Color.fromARGB(255, 80, 79, 79),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 15, right: 15),
                                  child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontFamily: 'Gilroy',
                                      ),
                                      children: [
                                        TextSpan(
                                          text:
                                              "We will send a Password Reset Link to\n",
                                          style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 80, 79, 79),
                                            fontFamily: 'Gilroy',
                                          ),
                                        ),
                                        TextSpan(
                                          text: email,
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 20, 204, 130),
                                            fontFamily: 'Gilroy',
                                          ), // Change color here
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 40,
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
                                    color:
                                        const Color.fromARGB(255, 80, 79, 79),
                                    fontFamily: 'Gilroy',
                                  ),
                                  decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                              255, 80, 79, 79),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide(
                                          color: const Color.fromARGB(
                                              255, 80, 79, 79),
                                        ),
                                      ),
                                      hintText: "Email",
                                      hintStyle: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 80, 79, 79),
                                        fontFamily: 'Gilroy',
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      )),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (_formkey.currentState!.validate()) {
                                      setState(() {
                                        email = emailcontroller.text;
                                      });
                                      resetPassword();
                                    }
                                  },
                                  child: Container(
                                    width: 140,
                                    padding: EdgeInsets.all(10),
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
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: Center(
                                      child: Text(
                                        "Send Email",
                                        style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            fontFamily: 'Gilroy',
                                            fontSize: 18.0,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 50.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, '/login');
                                      },
                                      child: Text(
                                        'Back To Login',
                                        style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 80, 79, 79),
                                          fontFamily: 'Gilroy',
                                          fontSize: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

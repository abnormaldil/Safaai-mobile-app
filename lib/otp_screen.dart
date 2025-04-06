import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safaai/login.dart';

class Otp extends StatelessWidget {
  const Otp({
    Key? key,
    required this.otpController,
  }) : super(key: key);
  final TextEditingController otpController;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: TextFormField(
        controller: otpController,
        keyboardType: TextInputType.number,
        style: TextStyle(
            color:
                const Color.fromARGB(255, 0, 0, 0)), // Set text color to white
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly
        ],
        decoration: InputDecoration(
          hintText: '-',
          hintStyle: TextStyle(
              color: Color.fromARGB(255, 42, 254, 169),
              fontFamily: "Gilroy",
              fontWeight: FontWeight.bold), // Set hint color to white
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromARGB(255, 38, 38, 38),
            ), // Set border color to white
            borderRadius: BorderRadius.circular(30.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: Color.fromARGB(
                    255, 19, 212, 151)), // Set focused border color to white
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
          if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
        onSaved: (value) {},
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  final EmailOTP myauth;
  final String userEmail;

  const OtpScreen({
    Key? key,
    required this.myauth,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otp1Controller = TextEditingController();
  TextEditingController otp2Controller = TextEditingController();
  TextEditingController otp3Controller = TextEditingController();
  TextEditingController otp4Controller = TextEditingController();

  String otpController = "1234";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Container(
        margin: EdgeInsets.only(left: 25, right: 25, top: 75),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 40,
              ),
              const Text(
                'Safaai',
                style: TextStyle(
                  fontSize: 25,
                  color: Color.fromARGB(255, 38, 38, 38),
                  fontFamily: 'AvantGardeLT',
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Image.asset(
                'assets/ver.png',
                width: 150,
                height: 150,
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Otp(
                    otpController: otp1Controller,
                  ),
                  Otp(
                    otpController: otp2Controller,
                  ),
                  Otp(
                    otpController: otp3Controller,
                  ),
                  Otp(
                    otpController: otp4Controller,
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Text(
                "Almost there!",
                style: TextStyle(
                    color: Color.fromARGB(255, 38, 38, 38),
                    fontSize: 60.0,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Gilroy"),
              ),
              const SizedBox(
                height: 5,
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
                        text: "We've sent a quick verification code to\n",
                        style: TextStyle(
                          color: Color.fromARGB(255, 38, 38, 38),
                          fontFamily: 'Gilroy',
                        ),
                      ),
                      TextSpan(
                        text: widget.userEmail,
                        style: TextStyle(
                          color: Color.fromARGB(255, 19, 212, 151),
                          fontFamily: 'Gilroy',
                        ), // Change color here
                      ),
                      TextSpan(
                        text: "\nEnter the code to get started.",
                        style: TextStyle(
                          color: Color.fromARGB(255, 38, 38, 38),
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                margin: EdgeInsets.only(left: 35, right: 35),
                width: MediaQuery.of(context).size.width, // Full width button
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 42, 254, 169),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: TextButton(
                    // Use TextButton instead of IconButton
                    onPressed: () async {
                      if (await widget.myauth.verifyOTP(
                              otp: otp1Controller.text +
                                  otp2Controller.text +
                                  otp3Controller.text +
                                  otp4Controller.text) ==
                          true) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("OTP is verified"),
                        ));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()));
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text("Invalid OTP"),
                        ));
                      }
                    },
                    child: Text(
                      "Verify",
                      style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 22.0,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Gilroy'),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text(
                    'Back to Signup',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Color.fromARGB(255, 42, 254, 169),
                      fontSize: 18,
                      fontFamily: 'Gilory',
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

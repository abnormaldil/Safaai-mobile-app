


import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser;
  String CreditBalance = '0';
  TextEditingController codeController = TextEditingController();
  Set<String> validCodes = {"SAF123", "SAF345", "SAF567", "SAF789"};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _incrementBalance(String code) async {
    final user = FirebaseAuth.instance.currentUser;
    if (validCodes.contains(code)) {
      try {
        if (user != null) {
          final userDocRef = _firestore.collection('users').doc(user.uid);

          await _firestore.runTransaction((transaction) async {
            final docSnapshot = await transaction.get(userDocRef);
            final int currentCreditBalance = docSnapshot.get('CreditBalance') ?? 0;
            final int newCreditBalance = currentCreditBalance + 10;

            transaction.update(userDocRef, {'CreditBalance': newCreditBalance});
          });

          setState(() {
            CreditBalance = (int.parse(CreditBalance) + 10).toString();
          });

          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Your token balance has been increased by 10.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (error) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('An error occurred: $error'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Invalid Code'),
            content: Text('The entered code is invalid. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  void _getBalance() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        final creditBalance = docSnapshot.get('CreditBalance') ?? 0;
        setState(() {
          CreditBalance = creditBalance.toString();
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _getBalance();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/home.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(110),
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        '$CreditBalance',
                        style: TextStyle(
                          fontSize: 90.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                                    child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: codeController,
                          style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter Unique Code',
                            labelStyle: TextStyle(
                              fontSize: 20.0,
                              color: Color(0xFFFFFFFF),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFffbe00),
                                width: 5.0,
                              ),
                              borderRadius: BorderRadius.circular(50),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Claim\t',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFFffbe00),
                            child: IconButton(
                              color: const Color.fromARGB(255, 29, 28, 28),
                              onPressed: () => _incrementBalance(codeController.text),
                              icon: Icon(Icons.chevron_right_rounded),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


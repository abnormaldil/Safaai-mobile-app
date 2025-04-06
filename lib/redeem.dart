import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:safaai/bottomnav.dart';
import 'package:safaai/profile.dart';
import 'package:lottie/lottie.dart';

class RedeemPage extends StatelessWidget {
  final User? user = FirebaseAuth.instance.currentUser;
  AudioPlayer _player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: user != null
          ? FirebaseFirestore.instance
              .collection('users')
              .doc(user!.email) // Use email instead of UID
              .snapshots()
          : null,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        Map<String, dynamic>? userData =
            snapshot.data?.data() as Map<String, dynamic>?;
        if (userData != null) {
          String cname = userData['Name'];
          int creditBalance = userData['CreditBalance'];
          int totalplastic = userData['totalplastic'];
          int totalearned = userData['totalearned'];

          return _buildRedeemUI(context, creditBalance, cname, totalplastic,
              totalearned, userData);
        } else {
          // Handle the case where user data is null (e.g., show an error message)
          print('Error: User data not found in Firestore');
          return Scaffold(
            body: Center(
              child: Text('Error: User data not found in Firestore'),
            ),
          );
        }
      },
    );
  }

  void showTopSnackBar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 85.0, // Adjust the top position as needed
        left: MediaQuery.of(context).size.width * 0.1,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the overlay after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      overlayEntry.remove();
    });
  }

  Widget _buildRedeemUI(BuildContext context, int creditBalance, String cname,
      int totalplastic, int totalearned, Map<String, dynamic> userData) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
      ),
      child: Scaffold(
        backgroundColor: Color.fromARGB(0, 30, 31, 33),
        appBar: AppBar(
          centerTitle: false,
          toolbarHeight: 100,
          backgroundColor: Color.fromARGB(0, 30, 31, 33),
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize
                  .min, // Ensures the column only takes the space it needs
              children: [
                Text(
                  "Hola,",
                  style: TextStyle(
                    fontSize: 26,
                    color: const Color.fromARGB(255, 80, 79, 79),
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  cname + "!",
                  style: TextStyle(
                    fontSize: 36,
                    color: const Color.fromARGB(255, 80, 79, 79),
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                  right: 10.0), // Add padding to the right
              child: IconButton(
                icon: Icon(
                  Icons.person_2_rounded,
                  color: const Color.fromARGB(255, 80, 79, 79),
                  size: 60,
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ProfilePage()));
                },
              ),
            ),
          ],
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.001),
              TweenAnimationBuilder(
                duration: Duration(seconds: 1), // Adjust animation duration
                tween: IntTween(
                    begin: 0,
                    end: creditBalance), // Tween from 0 to creditBalance
                builder: (context, int value, child) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        alignment: Alignment.center,
                        width: 380,
                        height: 340,
                        color: const Color.fromARGB(255, 36, 36, 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromARGB(255, 25, 255, 182)
                                        .withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 25,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color.fromARGB(255, 29, 213, 140),
                                    Color.fromARGB(255, 42, 254, 169),
                                    Color.fromARGB(255, 29, 213, 140),
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 45.0),
                                  Icon(
                                    FontAwesomeIcons.leaf,
                                    size: 50.0,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    value.toString(), // Animated value
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 70,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gilroy',
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // GestureDetector for "Redeem" button
                            GestureDetector(
                              onTap: () => _redeemCredits(
                                  context, creditBalance, userData),
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 110, vertical: 10),
                                padding: EdgeInsets.symmetric(
                                    vertical: 15), // Adjust padding for height
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      30), // Rounded corners
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(255, 37, 232, 154),
                                      Color.fromARGB(255, 42, 254, 169),
                                      Color.fromARGB(255, 29, 213, 140),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromARGB(255, 42, 254, 169)
                                          .withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 5,
                                      offset:
                                          Offset(0, 3), // Shadow positioning
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    'Redeem',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Gilroy',
                                      color: Colors.white, // White text
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 15,
              ),
              Column(
                children: [
                  // First Row - Total Deposits & Total Earnings
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // First Box - Total Deposits
                        Container(
                          width: 160,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 30, 30, 30),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 207, 207, 207)
                                    .withOpacity(0.5),
                                spreadRadius: 10,
                                blurRadius: 15,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<int>(
                                tween:
                                    IntTween(begin: 0, end: totalplastic ?? 0),
                                duration: Duration(milliseconds: 800),
                                builder: (context, value, child) {
                                  return Text(
                                    "$value",
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gilroy',
                                      color: const Color.fromARGB(
                                          255, 23, 228, 146),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Total\nDeposits",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gilroy',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),

                        // Second Box - Total Earnings
                        Container(
                          width: 160,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 30, 30, 30),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromARGB(255, 207, 207, 207)
                                    .withOpacity(0.5),
                                spreadRadius: 10,
                                blurRadius: 15,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TweenAnimationBuilder<int>(
                                tween:
                                    IntTween(begin: 0, end: totalearned ?? 0),
                                duration: Duration(milliseconds: 800),
                                builder: (context, value, child) {
                                  return Text(
                                    "$value",
                                    style: TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Gilroy',
                                      color: const Color.fromARGB(
                                          255, 23, 228, 146),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Total\nEarnings",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Gilroy',
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15), // Space between rows

                  // Second Row - NFC Order Button & Image
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            width: 180,
                            height:
                                195, // Increased height to accommodate image
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 30, 30, 30),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(255, 207, 207, 207)
                                          .withOpacity(0.5),
                                  spreadRadius: 10,
                                  blurRadius: 15,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // NFC Lottie Animation with Flexible Container
                                Flexible(
                                  child: Lottie.asset(
                                    'assets/nfc.json', // Lottie animation file
                                    height:
                                        90, // Adjusted height to fit properly
                                    width: 300,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                // Reduced space between animation and button
                                SizedBox(
                                  height: 20,
                                ),
                                // NFC Card Button
                                SizedBox(
                                  width: 120, // Ensures button takes full width
                                  child: SizedBox(
                                    width: 120,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showTopSnackBar(
                                            context, 'Coming Soon!');
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Color.fromARGB(255, 42, 241, 162),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 5,
                                            horizontal: 5), // Adjusted padding
                                      ),
                                      child: Text(
                                        'Order Your NFC',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Gilroy',
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(width: 15), // Space between button and image

                        // Right Column - Image
                        Expanded(
                          child: Container(
                            width: 180,
                            height: 195, // Increased height for better layout
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 30, 30, 30),
                              borderRadius: BorderRadius.circular(50),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(255, 207, 207, 207)
                                          .withOpacity(0.5),
                                  spreadRadius: 10,
                                  blurRadius: 15,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Image
                                Flexible(
                                  child: Lottie.asset(
                                    'assets/earth.json', // Lottie animation file
                                    height:
                                        150, // Adjusted height to fit properly
                                    width: 300,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                    height:
                                        8), // Spacing between image and text
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _redeemCredits(BuildContext context, int creditBalance,
      Map<String, dynamic> userData) async {
    int n = creditBalance % 100;
    int newn = creditBalance - n;
    if (creditBalance >= 100) {
      int redeemedCredit = newn ~/ 100;
      int newCreditBalance = n;

      // Reference to the user's document in Firestore
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(user!.email);

      // Update CreditBalance and increment totalearned
      FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(userDoc);

        if (!snapshot.exists) {
          throw Exception("User document does not exist!");
        }

        int currentTotalEarned =
            snapshot['totalearned'] ?? 0; // Fetch current totalearned

        transaction.update(userDoc, {
          'CreditBalance': newCreditBalance,
          'totalearned':
              currentTotalEarned + redeemedCredit, // Increment totalearned
        });

        userData['CreditBalance'] = newCreditBalance;
      }).then((_) async {
        Timestamp transactionTime = Timestamp.now();

        String upiId = userData['UpiId'];
        String email = userData['Email'];

        FirebaseFirestore.instance
            .collection('transactions')
            .doc(user!.email)
            .collection(user!.email!)
            .add({
          'RedeemAmount': redeemedCredit * 100,
          'Time': transactionTime,
          'Date': transactionTime.toDate(),
          'UpiId': upiId,
          'Email': email,
        }).then((_) async {
          var assetSource = AssetSource('claimed.mp3');
          await _player.play(assetSource);
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Success'),
                backgroundColor: Color.fromARGB(255, 42, 254, 169),
                content: Text('Redeemed $redeemedCredit Rupees!'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }).catchError((error) {
          print("Error saving transaction: $error");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred. Please try again.'),
            ),
          );
        });
      }).catchError((error) {
        print("Error updating user data: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while updating balance.'),
          ),
        );
      });
    } else {
      var assetSource = AssetSource('error.mp3');
      await _player.play(assetSource);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 42, 254, 169),
            title: Text(
              'Invalid Redemption!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Gilroy',
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, bottom: 10.0, left: 0.0, right: 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '•Minimum 100 Tokens Required for Redemption',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Gilroy',
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  Text(
                    '•Redeem in Multiples of 100',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Gilroy',
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Gilroy',
                    color: const Color.fromARGB(255, 80, 79, 79),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }
}

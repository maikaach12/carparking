import 'dart:math' as math;

import 'package:carparking/pages/login_signup/loginPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  ProfilePage({required this.userId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          userData = userDoc.data();
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> updateUserData() async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
        'name': userData!['name'],
        'email': userData!['email'],
        'familyName': userData!['familyName'],
        'phoneNumber': userData!['phoneNumber'],
        'carRegistration': userData!['carRegistration'],
        'driverLicense': userData!['driverLicense'],
        'idCard': userData!['idCard'],
        'age': userData!['age'],
        'desactiveparmoi': userData!['desactiveparmoi'], // Add this line
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User data updated successfully'),
        ),
      );
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  void _showEditDialog(String field) {
    TextEditingController controller =
        TextEditingController(text: userData![field]);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $field'),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter new value',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  userData![field] = controller.text;
                });
                updateUserData();
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> signOutAndNavigateToLogin(BuildContext context) async {
    try {
      // Update the 'desactiveparmoi' attribute
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({'desactiveparmoi': true});

      // Sign out the user
      await FirebaseAuth.instance.signOut();

      // Navigate to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  Widget topWidget(double screenWidth) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment(-0.2, -0.8),
            end: Alignment.bottomCenter,
            colors: [
              Color(0x007CBFCF),
              Color(0xB316BFC4),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomWidget(double screenWidth) {
    return Container(
      width: 1.5 * screenWidth,
      height: 1.5 * screenWidth,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(0.6, -1.1),
          end: Alignment(0.7, 0.8),
          colors: [
            Color(0xDB4BE8CC),
            Color(0x005CDBCF),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -0.2 * screenHeight,
            left: -0.2 * screenWidth,
            child: topWidget(screenWidth),
          ),
          Positioned(
            bottom: -0.4 * screenHeight,
            right: -0.4 * screenWidth,
            child: bottomWidget(screenWidth),
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/blue.png'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 3),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 250, 248, 248),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 50),
                      userData == null
                          ? Center(child: CircularProgressIndicator())
                          : Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Name: ${userData!['name']}'),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () =>
                                              _showEditDialog('name'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Email: ${userData!['email']}'),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () =>
                                              _showEditDialog('email'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Family Name: ${userData!['familyName']}'),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () =>
                                              _showEditDialog('familyName'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Phone Number: ${userData!['phoneNumber']}'),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () =>
                                              _showEditDialog('phoneNumber'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            'Car Registration: ${userData!['carRegistration']}'),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () =>
                                              _showEditDialog('driverLicense'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('ID Card: ${userData!['idCard']}'),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () =>
                                              _showEditDialog('idCard'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Age: ${userData!['age']}'),
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () =>
                                              _showEditDialog('age'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Deactivate Account'),
                                        Switch(
                                          value: userData!['desactiveparmoi'] ??
                                              false,
                                          onChanged: (value) async {
                                            bool confirmed = await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 250, 248, 248),
                                                  title: Text(
                                                    'Confirm Account Deactivation',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  content: Text(
                                                    'Are you sure you want to deactivate your account?',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.blue,
                                                        textStyle:
                                                            GoogleFonts.poppins(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      child: Text('Cancel'),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(false),
                                                    ),
                                                    TextButton(
                                                      style:
                                                          TextButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.blue,
                                                        textStyle:
                                                            GoogleFonts.poppins(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      child: Text('Confirm'),
                                                      onPressed: () =>
                                                          Navigator.of(context)
                                                              .pop(true),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );

                                            if (confirmed) {
                                              // Update the 'desactiveparmoi' attribute
                                              await FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(widget.userId)
                                                  .update({
                                                'desactiveparmoi': true
                                              });

                                              // Sign out the user
                                              await FirebaseAuth.instance
                                                  .signOut();

                                              // Navigate to the login screen
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginPage(),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

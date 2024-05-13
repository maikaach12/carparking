import 'dart:math' as math;
import 'package:carparking/pages/cote_admin/AdminDashboardPage.dart';
import 'package:carparking/pages/cote_user/map.dart';
import 'package:carparking/pages/cote_user/reclamationuser.dart';
import 'package:carparking/pages/login_signup/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

// import 'components/center_widget/center_widget.dart';
// import 'components/login_content.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _rememberMe = false;

  void signIn(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showErrorMessage(context, "Please enter email and password");
      return;
    }

    try {
      // Sign in with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Get user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      // Check user role
      String? role = userDoc.data()?['role'];

      // Check if user account is active
      bool active = userDoc.data()?['active'] ?? true;

      if (!active) {
        showErrorMessage(
          context,
          "Your account has been deactivated by the admin.",
        );
        return;
      }

      // Navigate to the appropriate page based on user role
      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboardPage()),
        );
      } else if (role != 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(),
          ),
        );
      } else {
        showErrorMessage(context, "Invalid user role");
      }
    } on FirebaseAuthException catch (e) {
      showErrorMessage(context, e.code);
    }
  }

  void showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.blue.withOpacity(0.5), // Change the background color
          title: Center(
            child: Text(
              message,
              style: GoogleFonts.montserrat(
                // Use the same font as the LoginPage
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          shape: RoundedRectangleBorder(
            // Add rounded corners
            borderRadius: BorderRadius.circular(15),
          ),
        );
      },
    );
  }

  void _forgotPassword(BuildContext context) {
    // Add your forgot password logic here
    // For example, you can show a dialog to reset the password
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: Text('Please enter your email to reset your password.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Add your reset password logic here
                Navigator.pop(context);
              },
              child: Text('Reset Password'),
            ),
          ],
        );
      },
    );
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
                image: AssetImage(
                    'lib/images/blue.png'), // Replace with your background image path
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
                      FittedBox(
                        child: Text(
                          "Parking.dz",
                          style: GoogleFonts.montserrat(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      FittedBox(
                        child: Text(
                          "Se connecter",
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: emailController,
                          style: TextStyle(color: Colors.blue),
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: TextStyle(color: Colors.black),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            prefixIcon: Icon(Icons.email, color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Password',
                            hintStyle: TextStyle(color: Colors.black),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            prefixIcon: Icon(Icons.lock, color: Colors.black),
                            suffixIcon: IconButton(
                              onPressed: () => _forgotPassword(context),
                              icon:
                                  Icon(Icons.help_outline, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
                          Text('Remember me'),
                        ],
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => signIn(context),
                        child: Text(
                          'Se connecter',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.withOpacity(0.5),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 40),
                          Text(
                            'Vous avez pas un compte ? ',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(width: 4), // Added space
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                color: Colors.black,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      )
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

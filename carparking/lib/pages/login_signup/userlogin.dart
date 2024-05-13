import 'package:carparking/pages/cote_user/map.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserLoginPage extends StatefulWidget {
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showErrorMessage(context, "Please enter email and password");
      return;
    }

    try {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

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
            context, "Your account has been deactivated by the admin.");
        return;
      }

      // Check if user is not an admin
      if (role != 'admin') {
        // Navigate to the Reser page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MapPage(),
          ),
        );
      } else {
        showErrorMessage(context, "You are not a user");
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
          backgroundColor: Colors.amber,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                hintText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => signUserIn(context),
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}

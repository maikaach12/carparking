import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carparking/componant/my_button.dart';
import 'package:carparking/componant/my_textfield.dart';
import 'package:carparking/pages/cote_user/map.dart';

class SignUpDetailsPage extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController idCardController = TextEditingController();
  final TextEditingController driverLicenseController = TextEditingController();
  final TextEditingController carRegistrationController =
      TextEditingController();
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneNumberController;

  SignUpDetailsPage({
    required this.emailController,
    required this.passwordController,
    required this.phoneNumberController,
  });

  void reserve(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': nameController.text,
        'age': ageController.text,
        'familyName': familyNameController.text,
        'idCard': idCardController.text,
        'driverLicense': driverLicenseController.text,
        'carRegistration': carRegistrationController.text,
        'email': emailController.text, // Ajout du champ email
        'phoneNumber': phoneNumberController.text,
        'role': 'user',
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(),
        ),
      );
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Text("Sign Up"),
                  SizedBox(height: 50),
                  MyTextField(
                    controller: nameController,
                    hintText: 'Name',
                    obscureText: false,
                  ),
                  SizedBox(height: 18),
                  MyTextField(
                    controller: ageController,
                    hintText: 'Age',
                    obscureText: false,
                  ),
                  SizedBox(height: 18),
                  MyTextField(
                    controller: familyNameController,
                    hintText: 'Family Name',
                    obscureText: false,
                  ),
                  SizedBox(height: 18),
                  MyTextField(
                    controller: idCardController,
                    hintText: 'ID Card',
                    obscureText: false,
                  ),
                  SizedBox(height: 18),
                  MyTextField(
                    controller: driverLicenseController,
                    hintText: 'Driver License',
                    obscureText: false,
                  ),
                  SizedBox(height: 18),
                  MyTextField(
                    controller: carRegistrationController,
                    hintText: 'Car Registration',
                    obscureText: false,
                  ),
                  SizedBox(height: 30),
                  MyButton(
                    onTap: () => reserve(context),
                    text: 'Reserver',
                  ),
                  SizedBox(height: 10),
                  Text("or continue with "),
                  Image.asset(
                    'lib/images/google.png',
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Back to Email and Password',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
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
    );
  }
}

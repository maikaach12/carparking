import 'package:carparking/pages/login_signup/Signupsuite.dart';
import 'package:flutter/material.dart';
import 'package:carparking/componant/my_button.dart';
import 'package:carparking/componant/my_textfield.dart';

class SignUpPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 50),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                      fontSize: 47,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 50),
                  MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                  ),
                  SizedBox(height: 18),
                  MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                  ),
                  SizedBox(height: 18),
                  MyTextField(
                    controller: phoneNumberController,
                    hintText: 'Phone Number',
                    obscureText: false,
                  ),
                  SizedBox(height: 30),
                  MyButton(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpDetailsPage(
                            emailController: emailController,
                            passwordController: passwordController,
                            phoneNumberController: phoneNumberController,
                          ),
                        ),
                      );
                    },
                    text: 'Continue',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

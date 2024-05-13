import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carparking/componant/my_button.dart';

class ProfilePage extends StatefulWidget {
  final String userId;

  ProfilePage({required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController familyNameController = TextEditingController();
  final TextEditingController idCardController = TextEditingController();
  final TextEditingController driverLicenseController = TextEditingController();
  final TextEditingController carRegistrationController =
      TextEditingController();

  bool isActive = true;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> getUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();

    final data = userData.data();
    if (data != null) {
      setState(() {
        nameController.text = data['name'] ?? '';
        ageController.text = data['age'] ?? '';
        familyNameController.text = data['familyName'] ?? '';
        idCardController.text = data['idCard'] ?? '';
        driverLicenseController.text = data['driverLicense'] ?? '';
        carRegistrationController.text = data['carRegistration'] ?? '';
        isActive = data['isActive'] ?? true;
      });
    }
  }

  void updateUserData(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .update({
      'name': nameController.text,
      'age': ageController.text,
      'familyName': familyNameController.text,
      'idCard': idCardController.text,
      'driverLicense': driverLicenseController.text,
      'carRegistration': carRegistrationController.text,
      'isActive': isActive,
    });

    _showSuccessMessage(context);
  }

  void _showSuccessMessage(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Modification successful!'),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void deleteAccount(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .delete();

    await FirebaseAuth.instance.currentUser?.delete().then((_) {
      // User is signed out, navigate to login page
      Navigator.pushReplacementNamed(context, '/userLoginPage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Delete Account'),
                    content:
                        Text('Are you sure you want to delete your account?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          deleteAccount(context);
                          Navigator.of(context).pop();
                        },
                        child: Text('Delete'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
              enabled: isActive,
            ),
            SizedBox(height: 18),
            TextField(
              controller: ageController,
              decoration: InputDecoration(
                labelText: 'Age',
              ),
              enabled: isActive,
            ),
            SizedBox(height: 18),
            TextField(
              controller: familyNameController,
              decoration: InputDecoration(
                labelText: 'Family Name',
              ),
              enabled: isActive,
            ),
            SizedBox(height: 18),
            TextField(
              controller: idCardController,
              decoration: InputDecoration(
                labelText: 'ID Card',
              ),
              enabled: isActive,
            ),
            SizedBox(height: 18),
            TextField(
              controller: driverLicenseController,
              decoration: InputDecoration(
                labelText: 'Driver License',
              ),
              enabled: isActive,
            ),
            SizedBox(height: 18),
            TextField(
              controller: carRegistrationController,
              decoration: InputDecoration(
                labelText: 'Car Registration',
              ),
              enabled: isActive,
            ),
            SizedBox(height: 18),
            Row(
              children: [
                Text('Account Status: '),
                Switch(
                  value: isActive,
                  onChanged: (value) {
                    setState(() {
                      isActive = value;
                    });
                  },
                ),
                Text(isActive ? 'Active' : 'Inactive'),
              ],
            ),
            SizedBox(height: 30),
            MyButton(
              onTap: () => updateUserData(context),
              text: 'Confirm',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carparking/componant/my_button.dart';

class ProfilePage extends StatefulWidget {
  final User user;

  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController;
  late TextEditingController ageController;
  late TextEditingController familyNameController;
  late TextEditingController idCardController;
  late TextEditingController driverLicenseController;
  late TextEditingController carRegistrationController;

  Map<String, bool> editModeMap = {
    'name': false,
    'age': false,
    'familyName': false,
    'idCard': false,
    'driverLicense': false,
    'carRegistration': false,
  };

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    ageController = TextEditingController();
    familyNameController = TextEditingController();
    idCardController = TextEditingController();
    driverLicenseController = TextEditingController();
    carRegistrationController = TextEditingController();
    getUserData();
  }

  Future<void> getUserData() async {
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .get();

    setState(() {
      nameController.text = userData['name'];
      ageController.text = userData['age'];
      familyNameController.text = userData['familyName'];
      idCardController.text = userData['idCard'];
      driverLicenseController.text = userData['driverLicense'];
      carRegistrationController.text = userData['carRegistration'];
    });
  }

  void updateUserData(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user.uid)
        .update({
      'name': nameController.text,
      'age': ageController.text,
      'familyName': familyNameController.text,
      'idCard': idCardController.text,
      'driverLicense': driverLicenseController.text,
      'carRegistration': carRegistrationController.text,
    });

    // Show a success message
    _showSuccessMessage(context);

    // Optionally, you can navigate to another page after updating data.
  }

  void _showSuccessMessage(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Modification successful!'),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to MapPage
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextFieldWithEditButton(
              controller: nameController,
              fieldName: 'name',
              hintText: 'Name',
            ),
            SizedBox(height: 18),
            _buildTextFieldWithEditButton(
              controller: ageController,
              fieldName: 'age',
              hintText: 'Age',
            ),
            SizedBox(height: 18),
            _buildTextFieldWithEditButton(
              controller: familyNameController,
              fieldName: 'familyName',
              hintText: 'Family Name',
            ),
            SizedBox(height: 18),
            _buildTextFieldWithEditButton(
              controller: idCardController,
              fieldName: 'idCard',
              hintText: 'ID Card',
            ),
            SizedBox(height: 18),
            _buildTextFieldWithEditButton(
              controller: driverLicenseController,
              fieldName: 'driverLicense',
              hintText: 'Driver License',
            ),
            SizedBox(height: 18),
            _buildTextFieldWithEditButton(
              controller: carRegistrationController,
              fieldName: 'carRegistration',
              hintText: 'Car Registration',
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

  Widget _buildTextFieldWithEditButton({
    required TextEditingController controller,
    required String fieldName,
    required String hintText,
  }) {
    return Row(
      children: [
        Expanded(
          child: editModeMap[fieldName] == true
              ? TextFormField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                  ),
                )
              : Text(controller.text),
        ),
        IconButton(
          icon: Icon(Icons.edit),
          onPressed: () {
            setState(() {
              editModeMap[fieldName] = true;
            });
          },
        ),
      ],
    );
  }
}

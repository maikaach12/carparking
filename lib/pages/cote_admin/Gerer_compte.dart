import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAccountsPage extends StatefulWidget {
  @override
  _ManageAccountsPageState createState() => _ManageAccountsPageState();
}

class _ManageAccountsPageState extends State<ManageAccountsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _toggleAccountStatus(
      String userId, String userEmail, bool active) async {
    try {
      // Get the current user
      User? currentUser = _auth.currentUser;

      if (currentUser == null) {
        // Show error message if no current user is found
        throw Exception('No authenticated user found');
      }

      // Check if the current user has the role "admin"
      DocumentSnapshot adminSnapshot =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!adminSnapshot.exists || adminSnapshot['role'] != 'admin') {
        // Show error message if current user is not an admin
        throw Exception(
            'Error updating account status: Current user is not an admin');
      }

      // Update the account status in Firestore
      await _firestore.collection('users').doc(userId).update({
        'active': active,
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'User account ${active ? 'activated' : 'deactivated'} successfully')),
      );
    } catch (e) {
      // Show error message with detailed error information
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating account status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Accounts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('role', isEqualTo: 'user')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot doc = snapshot.data!.docs[index];
              String userId = doc.id;
              String userEmail = doc['email'];

              return ListTile(
                title: Text(userEmail),
                trailing: IconButton(
                  icon: Icon(doc['active'] ? Icons.block : Icons.check_circle),
                  onPressed: () async {
                    bool active = !doc['active'];
                    await _toggleAccountStatus(userId, userEmail, active);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SupprimerParkingPage extends StatelessWidget {
  final DocumentSnapshot document;

  SupprimerParkingPage({required this.document});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supprimer le parking'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer le parking "${document['nom']}" ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Annuler'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _firestore
                        .collection('parkingu')
                        .doc(document.id)
                        .delete()
                        .then((_) {
                      Navigator.pop(context);
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Supprimer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:carparking/pages/cote_admin/AjouterParkingPage.dart';
import 'package:carparking/pages/cote_admin/ModifierParkingPage.dart';
import 'package:carparking/pages/cote_admin/SupprimerParkingPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_auth/firebase_auth.dart';

class GererParkingPage extends StatefulWidget {
  @override
  _GererParkingPageState createState() => _GererParkingPageState();
}

class _GererParkingPageState extends State<GererParkingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérer Parking'),
      ),
      body: Column(
        children: [
          // Bouton pour ajouter un nouveau parking
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AjouterParkingPage()),
              );
            },
            child: Text('Ajouter un parking'),
          ),
          // Liste des parkings existants
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('parkingu').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot document = snapshot.data!.docs[index];
                    return ListTile(
                      title: Text(document['nom']),
                      subtitle: Text('Places : ${document['place']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ModifierParkingPage(document: document),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SupprimerParkingPage(document: document),
                                ),
                              );
                              // Logique pour supprimer le parking
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
    );
  }
}

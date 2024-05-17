import 'package:carparking/pages/cote_admin/AjouterParkingPage.dart';
import 'package:carparking/pages/cote_admin/ModifierParkingPage.dart';
import 'package:carparking/pages/cote_admin/SupprimerParkingPage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GererParkingPage extends StatefulWidget {
  @override
  _GererParkingPageState createState() => _GererParkingPageState();
}

class _GererParkingPageState extends State<GererParkingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gérer Parking'),
        automaticallyImplyLeading: false, // Remove the back arrow
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AjouterParkingPage()),
              );
            },
            child: Text('Ajouter un parking'),
          ),
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
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text(document['nom']),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Capacité: ${document['capacite']}'),
                                  Text('Distance: ${document['distance']}'),
                                  Text('ID Admin: ${document['id_admin']}'),
                                  Text('Places: ${document['place']}'),
                                  Text(
                                      'Places Disponibles: ${document['placesDisponible']}'),
                                  Text(
                                      'Position: ${document['position'].toString()}'),
                                ],
                              ),
                            );
                          },
                        );
                      },
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

import 'package:carparking/pages/cote_user/reservation/reservation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListeParkingPage extends StatefulWidget {
  @override
  _ListeParkingPageState createState() => _ListeParkingPageState();
}

class _ListeParkingPageState extends State<ListeParkingPage> {
  final Stream<QuerySnapshot> _parkingsStream =
      FirebaseFirestore.instance.collection('parkingu').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des parkings'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _parkingsStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Une erreur s\'est produite : ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Chargement...');
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nom : ${data['nom']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('place: ${data['place']}'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReservationPage(
                                parkingId: document.id,
                              ),
                            ),
                          );
                        },
                        child: Text('Réserver une place'),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

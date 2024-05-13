import 'package:carparking/pages/cote_user/reservation/reservation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailParkingPage extends StatefulWidget {
  final String parkingId;

  DetailParkingPage({required this.parkingId});

  @override
  _DetailParkingPageState createState() => _DetailParkingPageState();
}

class _DetailParkingPageState extends State<DetailParkingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détail du parking'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('parkingu')
            .doc(widget.parkingId)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Une erreur s\'est produite : ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text('Chargement...');
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            children: [
              Text('Nom : ${data['nom']}'),
              Text('Nombre de places : ${data['nombrePlace']}'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReservationPage(parkingId: widget.parkingId),
                    ),
                  );
                },
                child: Text('Réserver une place'),
              ),
            ],
          );
        },
      ),
    );
  }
}

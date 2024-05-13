import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MesReservationsPage extends StatefulWidget {
  MesReservationsPage();

  @override
  _MesReservationsPageState createState() => _MesReservationsPageState();
}

class _MesReservationsPageState extends State<MesReservationsPage> {
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  String _getReservationStatus(
      Timestamp debutTimestamp, Timestamp finTimestamp) {
    DateTime currentTime = DateTime.now();
    DateTime debutTime = debutTimestamp.toDate();
    DateTime finTime = finTimestamp.toDate();

    if (currentTime.isBefore(debutTime) ||
        currentTime.isAtSameMomentAs(debutTime)) {
      return 'En cours';
    } else if (currentTime.isAfter(finTime)) {
      return 'Terminé';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Réservations', textAlign: TextAlign.center),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservationU')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final reservations = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reservations.length,
            itemBuilder: (context, index) {
              final reservation = reservations[index];
              final debutTimestamp = reservation['debut'];
              final finTimestamp = reservation['fin'];
              final idParking = reservation['idParking'];
              final idPlace = reservation['idPlace'];

              // Récupérer le nom du parking à partir de l'ID
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('parkingu')
                    .doc(idParking)
                    .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final parkingData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final nomParking = parkingData['nom'] ?? 'Parking inconnu';

                  return Card(
                    elevation: 2.0, // Ajout d'un peu d'ombre
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  nomParking,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                  ),
                                ),
                                Text(
                                  _getReservationStatus(
                                    debutTimestamp,
                                    finTimestamp,
                                  ),
                                  style: TextStyle(
                                    color: _getReservationStatus(
                                              debutTimestamp,
                                              finTimestamp,
                                            ) ==
                                            'En cours'
                                        ? Colors.blue
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              'ID Reservation: $idPlace',
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(
                              'Début: ${DateFormat('dd/MM/yyyy HH:mm').format(debutTimestamp.toDate())}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Fin: ${DateFormat('dd/MM/yyyy HH:mm').format(finTimestamp.toDate())}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.directions_car,
                                      color: Colors.blue,
                                      size: 16.0,
                                    ),
                                    SizedBox(width: 4.0),
                                    Text(
                                      reservation['matriculeEtMarque'],
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (_getReservationStatus(
                                  debutTimestamp, finTimestamp) ==
                              'En cours')
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('reservationU')
                                          .doc(reservation.id)
                                          .delete();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color.fromRGBO(25, 118, 210, 1),
                                    ),
                                    child: Text(
                                      'Annuler',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

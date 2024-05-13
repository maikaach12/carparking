import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MesReservationsPage extends StatefulWidget {
  MesReservationsPage();

  @override
  _MesReservationsPageState createState() => _MesReservationsPageState();
}

class _MesReservationsPageState extends State<MesReservationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes Réservations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('reservationU').snapshots(),
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
              final typeDemande = reservation['typePlace'];

              return Card(
                elevation: 2.0,
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      '$idPlace',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    'Début: ${DateFormat('dd/MM/yyyy HH:mm').format(debutTimestamp.toDate())}\nFin: ${DateFormat('dd/MM/yyyy HH:mm').format(finTimestamp.toDate())}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'ID Parking: $idParking\nID Place: $idPlace\nType Demande: $typeDemande',
                    style: TextStyle(fontSize: 12.0),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: () {
                      // Ajouter une action ici si nécessaire
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:carparking/pages/cote_user/reservation/reservation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListeParkingPage extends StatefulWidget {
  @override
  _ListeParkingPageState createState() => _ListeParkingPageState();
}

class _ListeParkingPageState extends State<ListeParkingPage> {
  final List<String> _sortOptions = [
    'Trier par alphabet',
    'Trier par distance'
  ];
  String _selectedSort = 'Trier par alphabet';
  String _searchQuery = '';

  Query<Map<String, dynamic>> _parkingsQuery() {
    Query<Map<String, dynamic>> query =
        FirebaseFirestore.instance.collection('parkingu').withConverter(
              fromFirestore: (snapshot, _) => snapshot.data()!,
              toFirestore: (data, _) => data,
            );

    if (_searchQuery.isNotEmpty) {
      query = query
          .where('`place`', isGreaterThanOrEqualTo: _searchQuery.toLowerCase())
          .where('`place`', isLessThan: '${_searchQuery.toLowerCase()}z');
    }
    if (_selectedSort == 'Trier par alphabet') {
      return query.orderBy('nom');
    } else {
      return query.orderBy('distance');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue, // Change the appBar background color
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Rechercher une place',
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
            fillColor: Colors.white30, // Change the TextField fill color
            filled: true,
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _selectedSort = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return _sortOptions.map((option) {
                return PopupMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _parkingsQuery().snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Text('Une erreur s\'est produite : ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator()); // Show a loading indicator
          }

          return ListView.separated(
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (context, index) =>
                Divider(), // Add a divider between items
            itemBuilder: (BuildContext context, int index) {
              DocumentSnapshot<Map<String, dynamic>> document =
                  snapshot.data!.docs[index];
              Map<String, dynamic> data = document.data()!;
              return ListTile(
                title: Text(
                  'Nom : ${data['nom']}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text('place: ${data['place']}'),
                trailing: ElevatedButton(
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
              );
            },
          );
        },
      ),
    );
  }
}

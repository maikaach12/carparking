import 'package:carparking/pages/cote_user/reservation/reservation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

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
          .where('place', isGreaterThanOrEqualTo: _searchQuery.toLowerCase())
          .where('place', isLessThan: '${_searchQuery.toLowerCase()}z');
    }
    if (_selectedSort == 'Trier par alphabet') {
      return query.orderBy('nom');
    } else {
      // Ensure that the 'distance' field exists in your Firestore documents
      // Order by 'distance' in ascending order to get the closest parking first
      return query.orderBy('distance', descending: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Colors.blue.shade700, // Change the appBar background color
        title: Text(
          'Liste des parkings',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _sortOptions.map((option) {
                        return ListTile(
                          title: Text(
                            option,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              color: _selectedSort == option
                                  ? const Color.fromRGBO(33, 150, 243, 1)
                                  : Colors.black,
                            ),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedSort = option;
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une place',
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.grey.shade600,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade600,
                ),
              ),
              style: GoogleFonts.montserrat(
                color: Colors.black,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _parkingsQuery().snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  return Text('Une erreur s\'est produite : ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Show a loading indicator
                }

                return ListView.separated(
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: Colors.grey.shade300,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    DocumentSnapshot<Map<String, dynamic>> document =
                        snapshot.data!.docs[index];
                    Map<String, dynamic> data = document.data()!;
                    return ListTile(
                      title: Text(
                        'Nom : ${data['nom']}',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Place: ${data['place']}',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
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
                        child: Text(
                          'Réserver',
                          style: GoogleFonts.montserrat(
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(33, 150, 243, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:carparking/pages/cote_admin/relamDETAIL.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReclamationAdminPage extends StatefulWidget {
  final String userId;

  ReclamationAdminPage({required this.userId});

  @override
  _ReclamationAdminPageState createState() => _ReclamationAdminPageState();
}

class _ReclamationAdminPageState extends State<ReclamationAdminPage> {
  int reclamationCount = 0;
  String adminEmail = 'admin@example.com';
  String userEmail = '';

  @override
  void initState() {
    super.initState();
    fetchReclamationCount();
    fetchUserEmail();
  }

  Future<void> fetchReclamationCount() async {
    final reclamationsQuery = await FirebaseFirestore.instance
        .collection('reclamations')
        .where('userId', isEqualTo: widget.userId)
        .get();
    setState(() {
      reclamationCount = reclamationsQuery.docs.length;
    });
  }

  Future<void> fetchUserEmail() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .get();
    if (userDoc.exists) {
      setState(() {
        userEmail = userDoc.data()?['email'] ?? '';
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchUserReservations() async {
    final reservationsQuery = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: widget.userId)
        .get();

    return reservationsQuery.docs.map((doc) => doc.data()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Réclamations Admin'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: Colors.grey[200],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Email Admin: $adminEmail'),
                SizedBox(height: 8.0),
                GestureDetector(
                  onTap: () {
                    fetchUserReservations().then((reservations) {
                      showDialog(
                        context: context,
                        builder: (context) => ReservationsDialog(
                          userEmail: userEmail,
                          reservations: reservations,
                        ),
                      );
                    });
                  },
                  child: Text(
                    'Email Utilisateur: $userEmail',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(height: 8.0),
                Text('Nombre de réclamations: $reclamationCount'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reclamations')
                  .where('userId', isEqualTo: widget.userId)
                  .where('status', isEqualTo: 'en attente')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Une erreur s\'est produite');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    if (data['type'] == 'Place réservée non disponible') {
                      return ListTile(
                        title: Text(data['type']),
                        subtitle: Text(data['description']),
                        onTap: () {
                          // Navigate to the new page
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReclamPageEmpty(),
                            ),
                          );
                        },
                      );
                    } else {
                      return ListTile(
                        title: Text(data['type']),
                        subtitle: Text(data['description']),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReclamationDetailsPage(
                                reclamationId: document.id,
                              ),
                            ),
                          );
                        },
                      );
                    }
                  }).toList(),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class ReclamationDetailsPage extends StatefulWidget {
  final String reclamationId;

  ReclamationDetailsPage({required this.reclamationId});

  @override
  _ReclamationDetailsPageState createState() => _ReclamationDetailsPageState();
}

class _ReclamationDetailsPageState extends State<ReclamationDetailsPage> {
  String reponse = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de la réclamation'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reclamations')
            .doc(widget.reclamationId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Une erreur s\'est produite');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          return Column(
            children: [
              Text('Type: ${data['type']}'),
              Text('Description: ${data['description']}'),
              TextField(
                onChanged: (value) {
                  setState(() {
                    reponse = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Réponse',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('reclamations')
                      .doc(widget.reclamationId)
                      .update({
                    'status': 'traitée',
                    'reponse': reponse,
                  });
                },
                child: Text('Marquer comme traitée'),
              ),
              ElevatedButton(
                onPressed: () {
                  FirebaseFirestore.instance
                      .collection('reclamations')
                      .doc(widget.reclamationId)
                      .update({
                    'status': 'clôturée',
                  });
                  Navigator.pop(context);
                },
                child: Text('Clôturer la réclamation'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ReservationsDialog extends StatelessWidget {
  final String userEmail;
  final List<Map<String, dynamic>> reservations;

  ReservationsDialog({
    required this.userEmail,
    required this.reservations,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Réservations de $userEmail'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: reservations.length,
          itemBuilder: (context, index) {
            final reservation = reservations[index];
            return ListTile(
              title: Text(reservation['title'] ?? ''),
              subtitle: Text(reservation['description'] ?? ''),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Fermer'),
        ),
      ],
    );
  }
}

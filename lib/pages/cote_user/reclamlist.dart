import 'package:carparking/pages/cote_user/reclmedit.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamationListPage extends StatefulWidget {
  final String userId;
  ReclamationListPage({required this.userId});

  @override
  _ReclamationListPageState createState() => _ReclamationListPageState();
}

class _ReclamationListPageState extends State<ReclamationListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes réclamations'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reclamations')
            .where('userId', isEqualTo: widget.userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Une erreur s\'est produite');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              String status = data['status'] ?? 'envoyé';
              return ListTile(
                title: Text(data['type']),
                subtitle: Text(data['description']),
                trailing: status == 'envoyé'
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Logique de modification de la réclamation
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ModifierReclamationPage(
                                    userId: widget.userId,
                                    reclamationId: document.id,
                                    typeProblem: data['type'],
                                    description: data['description'],
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Confirmer la suppression'),
                                    content: Text(
                                        'Êtes-vous sûr de vouloir supprimer cette réclamation ?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('Annuler'),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Ferme la boîte de dialogue
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Supprimer'),
                                        onPressed: () {
                                          // Logique de suppression de la réclamation
                                          // Supprimez le document de la collection "reclamations" dans Firestore
                                          document.reference.delete();

                                          Navigator.of(context)
                                              .pop(); // Ferme la boîte de dialogue
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      )
                    : Text('Réclamation en cours de traitement'),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

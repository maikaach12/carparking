/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjouterPlacePage extends StatefulWidget {
  final String parkingId;
  AjouterPlacePage({required this.parkingId});

  @override
  _AjouterPlacePageState createState() => _AjouterPlacePageState();
}

class _AjouterPlacePageState extends State<AjouterPlacePage> {
  final CollectionReference placesCollection =
      FirebaseFirestore.instance.collection('placeU');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter Places'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _ajouterPlaces();
          },
          child: Text('Ajouter 10 Places'),
        ),
      ),
    );
  }

  Future<void> _ajouterPlaces() async {
    try {
      // Récupérer le document parkingu correspondant
      final parkingDoc = await FirebaseFirestore.instance
          .collection('parkingu')
          .doc(widget.parkingId)
          .get();

      // Obtenir le nombre total de places existantes avec le même id_parking
      final placesQuery = await FirebaseFirestore.instance
          .collection('placeU')
          .where('id_parking', isEqualTo: widget.parkingId)
          .get();
      int nombrePlacesExistantes = placesQuery.docs.length;

      // Calculer le nouveau nombrePlace
      int nouveauNombrePlaces = nombrePlacesExistantes + 10;

      // Mettre à jour le nombrePlace dans le document parkingu
      await FirebaseFirestore.instance
          .collection('parkingu')
          .doc(widget.parkingId)
          .update({'nombrePlace': nouveauNombrePlaces});

      // Ajouter les 10 nouvelles places
      for (int i = 0; i < 10; i++) {
        await placesCollection.add({
          'id_parking': widget.parkingId,
          'status': 'disponible',
          'type': 'standard'
        });
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Places ajoutées'),
            content: Text('10 places ont été ajoutées avec succès.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text(
                'Une erreur s\'est produite lors de l\'ajout des places : $e'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPlacePage extends StatefulWidget {
  final String parkingId;

  AddPlacePage({required this.parkingId});

  @override
  _AddPlacePageState createState() => _AddPlacePageState();
}

class _AddPlacePageState extends State<AddPlacePage> {
  final _formKey = GlobalKey<FormState>();
  String _typePlace = 'standard';

  Future<void> _ajouterPlace() async {
    try {
      await FirebaseFirestore.instance.collection('placeU').add({
        'id_parking': widget.parkingId,
        'type': _typePlace,
        'reservations': [],
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Place ajoutée'),
            content: Text('La nouvelle place a été ajoutée avec succès.'),
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
                'Une erreur s\'est produite lors de l\'ajout de la place : $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une place'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _typePlace,
                decoration: InputDecoration(
                  labelText: 'Type de place',
                ),
                items: ['standard', 'handicapé'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _typePlace = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _ajouterPlace,
                child: Text('Ajouter la place'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

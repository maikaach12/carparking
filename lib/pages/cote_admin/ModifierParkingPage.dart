import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifierParkingPage extends StatefulWidget {
  final DocumentSnapshot document;

  ModifierParkingPage({required this.document});

  @override
  _ModifierParkingPageState createState() => _ModifierParkingPageState();
}

class _ModifierParkingPageState extends State<ModifierParkingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _nom, _place, _latitude, _longitude, _idAdmin;
  late int _capacite, _distance, _placesDisponible;

  @override
  void initState() {
    super.initState();
    _nom = widget.document['nom'];
    _place = widget.document['place'];
    _capacite = widget.document['capacite'];
    _distance = widget.document['distance'];
    _idAdmin = widget.document['id_admin'];
    _placesDisponible = widget.document['placesDisponible'];
    _latitude = widget.document['position'].latitude.toString();
    _longitude = widget.document['position'].longitude.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le parking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _nom,
                decoration: InputDecoration(labelText: 'Nom du parking'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un nom de parking';
                  }
                  return null;
                },
                onSaved: (value) => _nom = value!,
              ),
              TextFormField(
                initialValue: _place,
                decoration: InputDecoration(labelText: 'Place du parking'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer la place du parking';
                  }
                  return null;
                },
                onSaved: (value) => _place = value!,
              ),
              TextFormField(
                initialValue: _capacite.toString(),
                decoration: InputDecoration(labelText: 'Capacité'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer la capacité';
                  }
                  return null;
                },
                onSaved: (value) => _capacite = int.parse(value!),
              ),
              TextFormField(
                initialValue: _distance.toString(),
                decoration: InputDecoration(labelText: 'Distance'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer la distance';
                  }
                  return null;
                },
                onSaved: (value) => _distance = int.parse(value!),
              ),
              TextFormField(
                initialValue: _idAdmin,
                decoration: InputDecoration(labelText: 'ID Admin'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer l\'ID de l\'administrateur';
                  }
                  return null;
                },
                onSaved: (value) => _idAdmin = value!,
              ),
              TextFormField(
                initialValue: _placesDisponible.toString(),
                decoration: InputDecoration(labelText: 'Places disponibles'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le nombre de places disponibles';
                  }
                  return null;
                },
                onSaved: (value) => _placesDisponible = int.parse(value!),
              ),
              TextFormField(
                initialValue: _latitude,
                decoration: InputDecoration(labelText: 'Latitude'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer une latitude';
                  }
                  return null;
                },
                onSaved: (value) => _latitude = value!,
              ),
              TextFormField(
                initialValue: _longitude,
                decoration: InputDecoration(labelText: 'Longitude'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer une longitude';
                  }
                  return null;
                },
                onSaved: (value) => _longitude = value!,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _firestore
                        .collection('parkingu')
                        .doc(widget.document.id)
                        .update({
                      'nom': _nom,
                      'place': _place,
                      'capacite': _capacite,
                      'distance': _distance,
                      'id_admin': _idAdmin,
                      'placesDisponible': _placesDisponible,
                      'position': GeoPoint(
                          double.parse(_latitude), double.parse(_longitude)),
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Modifier'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

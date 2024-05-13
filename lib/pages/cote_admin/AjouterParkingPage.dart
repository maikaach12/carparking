import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AjouterParkingPage extends StatefulWidget {
  @override
  _AjouterParkingPageState createState() => _AjouterParkingPageState();
}

class _AjouterParkingPageState extends State<AjouterParkingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _nom, _place, _latitude, _longitude;

  late int _nbrplace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un parking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
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
                decoration: InputDecoration(labelText: 'place du parking'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer la place de parking';
                  }
                  return null;
                },
                onSaved: (value) => _place = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nombre de places'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer le nombre de places';
                  }
                  return null;
                },
                onSaved: (value) => _nbrplace = int.parse(value!),
              ),
              TextFormField(
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
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final User? user = _auth.currentUser;
                    final String? userId = user?.uid;
                    await _firestore.collection('parkingu').add({
                      'nom': _nom,
                      'place': _place,
                      'nombrePlace': _nbrplace,
                      'position': GeoPoint(
                          double.parse(_latitude), double.parse(_longitude)),
                      'id_admin': userId,
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text('Ajouter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

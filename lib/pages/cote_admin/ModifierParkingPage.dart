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
  late String _nom, _place, _latitude, _longitude;
  late int _nbrplace;

  @override
  void initState() {
    super.initState();
    _nom = widget.document['nom'];
    _place = widget.document['place'];
    _nbrplace = widget.document['nombrePlace'];
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
                initialValue: _nbrplace.toString(),
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
                      'nombrePlace': _nbrplace,
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AjouterPlacePage extends StatefulWidget {
  @override
  _AjouterPlacePageState createState() => _AjouterPlacePageState();
}

class _AjouterPlacePageState extends State<AjouterPlacePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _selectedParkingId;
  String? _selectedType;
  List<String> _parkingNames = [];
  List<String> _placeTypes = ['standard', 'Handicapé'];
  Map<String, String> _parkingIdMap = {};

  @override
  void initState() {
    super.initState();
    _fetchParkingNamesAndIds();
  }

  Future<void> _fetchParkingNamesAndIds() async {
    QuerySnapshot querySnapshot = await _firestore.collection('parkingu').get();
    List<String> parkingNames = [];
    Map<String, String> parkingIdMap = {};
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      String parkingName = document['nom'];
      String parkingId = document.id;
      parkingNames.add(parkingName);
      parkingIdMap[parkingName] = parkingId;
    }
    setState(() {
      _parkingNames = parkingNames;
      _parkingIdMap = parkingIdMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une place'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sélectionnez un parking'),
              DropdownButtonFormField<String>(
                value: _selectedParkingId,
                onChanged: (value) {
                  setState(() {
                    _selectedParkingId = value;
                  });
                },
                items: _parkingNames.map((name) {
                  return DropdownMenuItem<String>(
                    value: _parkingIdMap[name],
                    child: Text(name),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              Text('Sélectionnez le type de place'),
              DropdownButtonFormField<String>(
                value: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
                items: _placeTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _addPlace();
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

  Future<void> _addPlace() async {
    // Add the new place to the 'placeU' collection with a unique ID
    DocumentReference newPlaceRef = await _firestore.collection('placeU').add({
      'id_parking': _selectedParkingId,
      'type': _selectedType,
    });
    String newPlaceId = newPlaceRef.id;

    // Get the reference to the 'parkingu' document with the selected parking ID
    DocumentReference parkingRef =
        _firestore.collection('parkingu').doc(_selectedParkingId);

    // Get the current value of 'capacite' for the selected parking
    DocumentSnapshot parkingSnapshot = await parkingRef.get();
    int currentCapacite = parkingSnapshot.get('capacite') ?? 0;

    // Increment the 'capacite' value
    int newCapacite = currentCapacite + 1;

    // Update the 'parkingu' document with the new 'capacite' value
    await parkingRef.update({'capacite': newCapacite});

    // Update the 'placeU' document with the new ID
    await _firestore
        .collection('placeU')
        .doc(newPlaceId)
        .update({'id': newPlaceId});

    Navigator.pop(context);
  }
}

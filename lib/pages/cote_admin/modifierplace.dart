import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModifierPlacePage extends StatefulWidget {
  final DocumentSnapshot document;

  ModifierPlacePage({required this.document});

  @override
  _ModifierPlacePageState createState() => _ModifierPlacePageState();
}

class _ModifierPlacePageState extends State<ModifierPlacePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String? _selectedType;
  List<String> _placeTypes = ['Normal', 'Handicapé'];

  @override
  void initState() {
    super.initState();
    _selectedType = widget.document['type'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier la place'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID Parking: ${widget.document['id_parking']}'),
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
                    _updatePlace();
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

  Future<void> _updatePlace() async {
    await _firestore.collection('places').doc(widget.document.id).update({
      'type': _selectedType,
    });
    Navigator.pop(context);
  }
}

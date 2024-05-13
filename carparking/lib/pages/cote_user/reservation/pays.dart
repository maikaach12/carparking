import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final TextEditingController _locationController = TextEditingController();
  String _latitude = '';
  String _longitude = '';

  Future<void> _getLocationCoordinates() async {
    try {
      List<Location> locations =
          await locationFromAddress(_locationController.text);
      if (locations.isNotEmpty) {
        setState(() {
          _latitude = locations.first.latitude.toString();
          _longitude = locations.first.longitude.toString();
        });
      } else {
        setState(() {
          _latitude = '';
          _longitude = '';
        });
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erreur'),
            content: Text('Aucun résultat trouvé pour cette localisation.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erreur'),
          content: Text(
              'Une erreur s\'est produite lors de la récupération des coordonnées.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Localisation'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _locationController,
              decoration: InputDecoration(
                labelText: 'Entrez un pays ou une ville',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _getLocationCoordinates,
              child: Text('Obtenir les coordonnées'),
            ),
            SizedBox(height: 16.0),
            Text('Latitude: $_latitude'),
            Text('Longitude: $_longitude'),
          ],
        ),
      ),
    );
  }
}

import 'package:carparking/pages/cote_user/MesReservationsPage.dart';
import 'package:carparking/pages/cote_user/reservation/listeParking.dart';
import 'package:carparking/pages/cote_user/reservation/reservation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
/*import 'package:http/http.dart' as http;
import 'dart:convert';*/

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapPage(),
    );
  }
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  MapController _mapController = MapController();
  int _selectedIndex = 0;
  List<Marker> _markers = [];
  LatLng? _currentLocation;
  List<LatLng> _routePoints = [];
  double _distance = 0.0;
  int _duration = 0;
  PolylineLayer? _routeLayer;
  String _appBarTitle =
      'Cliquer pour afficher tous les parkings'; // Texte de l'AppBar

  @override
  void initState() {
    super.initState();
    _fetchPlacesFromFirebase();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final currentPosition = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation =
          LatLng(currentPosition.latitude, currentPosition.longitude);
      _mapController.move(_currentLocation!, 15.0);
    });
  }

  void _fetchPlacesFromFirebase() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('parkingu').get();
    List<Marker> markers = [];

    snapshot.docs.forEach((doc) {
      String name = doc['nom'];
      String place = doc['place'];
      String parkingId = doc.id; // Récupérer l'ID du document

      GeoPoint position = doc['position'];
      LatLng latLng = LatLng(position.latitude, position.longitude);

      markers.add(
        Marker(
          width: 80,
          height: 80,
          point: latLng,
          child: GestureDetector(
            onTap: () {
              _showPlaceInfo(
                  name, place, latLng, parkingId); // Passer l'ID du parking
            },
            child: Icon(
              Icons.location_on,
              color: Color.fromARGB(255, 95, 87, 182),
              size: 36,
            ),
          ),
        ),
      );
    });

    setState(() {
      _markers = markers;
    });
  }

  void _showPlaceInfo(
      String NamePark, String NamePlace, LatLng placeLatLng, String parkingId) {
    _calculateRouteAndDrawLine(placeLatLng);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Place Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: $NamePark'),
            SizedBox(height: 8.0),
            Text('Place: $NamePlace'),
            SizedBox(height: 8.0),
            Text('Distance: ${(_distance / 1000).toStringAsFixed(2)} km'),
            SizedBox(height: 8.0),
            Text('Duration: $_duration minutes'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _drawRoute();
            },
            child: Text('Itinéraire'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Fermer la boîte de dialogue
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReservationPage(
                    parkingId: parkingId, // Passer l'ID du parking
                  ),
                ),
              );
            },
            child: Text('Réserver'),
          ),
        ],
      ),
    );
  }

  void _calculateRouteAndDrawLine(LatLng destination) {
    if (_currentLocation != null) {
      setState(() {
        _routePoints = [_currentLocation!, destination];
        _distance =
            calculateDistance(destination.latitude, destination.longitude);
        _duration = calculateDuration(_distance);
      });
    }
  }

  void _drawRoute() {
    if (_routePoints.isNotEmpty) {
      setState(() {
        _routeLayer = PolylineLayer(
          polylines: [
            Polyline(
              points: _routePoints,
              color: Colors.blue,
              strokeWidth: 4,
            ),
          ],
        );
      });
    }
  }

  double calculateDistance(double lat, double lon) {
    double distance = 0.0;
    if (_currentLocation != null) {
      distance = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        lat,
        lon,
      );
    }
    return distance;
  }

  int calculateDuration(double distance) {
    double averageSpeed = 50.0;
    double distanceInKm = distance / 1000.0;
    double timeInHours = distanceInKm / averageSpeed;
    int timeInMinutes = (timeInHours * 60).round();
    return timeInMinutes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          IconButton(
            icon: Icon(Icons.local_parking),
            onPressed: () {
              // Naviguer vers la page ListeParkingPage
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ListeParkingPage()),
              );
            },
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: _currentLocation ?? LatLng(36.7212737, 3.1892409),
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
            markers: _markers,
          ),
          MarkerLayer(
            markers: [
              if (_currentLocation != null)
                Marker(
                  width: 80,
                  height: 80,
                  point: _currentLocation!,
                  child: Icon(
                    Icons.my_location,
                    color: Colors.red,
                    size: 36,
                  ),
                ),
            ],
          ),
          if (_routeLayer != null) _routeLayer!,
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Mes réservations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Naviguer vers la page "Mes réservations"
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MesReservationsPage()),
      );
    }
  }

  @override
  void didUpdateWidget(covariant MapPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 13.0);
    }
  }
}

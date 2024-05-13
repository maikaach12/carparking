import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:cron/cron.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<DocumentSnapshot> _parkings = [];
  late Timer _timer;
  TextEditingController _dateController = TextEditingController();
  TextEditingController _heureDebutController = TextEditingController();
  TextEditingController _heureFinController = TextEditingController();
  late final DateFormat dateFormat;
  late final DateFormat dateTimeFormat;
  late Cron _cron;

  _MapPageState() {
    initializeDateFormatting('fr', null);
    dateFormat = DateFormat('dd/MM/yyyy', 'fr');
    dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm', 'fr');
  }

  @override
  void initState() {
    super.initState();
    _getParkings();
    _checkCurrentAvailability();
    _startAutomaticUpdate();
  }

  @override
  void dispose() {
    _timer.cancel();
    _cron.close();
    super.dispose();
  }

  Future<void> _getParkings() async {
    _firestore.collection('parking').snapshots().listen((snapshot) {
      setState(() {
        _parkings = snapshot.docs;
      });
    });

    for (DocumentSnapshot parking in _parkings) {
      String parkingId = parking.id;
      _startTimer(parkingId);
    }
  }

  void _startTimer(String parkingId) {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      _updateAvailableSpots(parkingId);
    });
  }

  void _startAutomaticUpdate() {
    _cron = Cron();
    _cron.schedule(Schedule.parse('*/1 * * * *'), () async {
      await _updateAvailableSpotsAutomatically();
    });
  }

  Future<void> _updateAvailableSpotsAutomatically() async {
    for (DocumentSnapshot parking in _parkings) {
      String parkingId = parking.id;
      _updateAvailableSpots(parkingId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parkings'),
      ),
      body: ListView.builder(
        itemCount: _parkings.length,
        itemBuilder: (context, index) {
          final parking = _parkings[index];
          final capacite = parking['capacite'];
          final nom = parking['nom'];
          final placesDisponible = parking['placesDisponible'];
          return Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(3.0, 3.0),
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nom,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text('Capacité : $capacite'),
                SizedBox(height: 8.0),
                Text('Places disponibles : $placesDisponible'),
                SizedBox(height: 8.0),
                ElevatedButton(
                  onPressed: () {
                    _showReservationForm(parking);
                  },
                  child: Text('Réserver'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showReservationForm(DocumentSnapshot parking) {
    showDialog(
      context: context,
      builder: (context) {
        String _typePlace = 'normal';

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Réserver une place'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Parking: ${parking['nom'] ?? ''}'),
                    TextField(
                      controller: _dateController,
                      decoration: InputDecoration(
                        labelText: 'Date de réservation',
                      ),
                      onChanged: (value) {
                        _updateAvailableSpots(parking.id);
                      },
                    ),
                    TextField(
                      controller: _heureDebutController,
                      decoration: InputDecoration(
                        labelText: 'Heure de début',
                      ),
                      onChanged: (value) {
                        _updateAvailableSpots(parking.id);
                      },
                    ),
                    TextField(
                      controller: _heureFinController,
                      decoration: InputDecoration(
                        labelText: 'Heure de fin',
                      ),
                      onChanged: (value) {
                        _updateAvailableSpots(parking.id);
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _typePlace,
                      decoration: InputDecoration(
                        labelText: 'Type de place',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'normal',
                          child: Text('Normal'),
                        ),
                        DropdownMenuItem(
                          value: 'handicap',
                          child: Text('Pour handicapé'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _typePlace = value!;
                        });
                      },
                    ),
                    FutureBuilder<int>(
                      future: _checkAvailability(
                        parking.id,
                        _dateController.text,
                        _heureDebutController.text,
                        _heureFinController.text,
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          return Text('Places restantes : ${snapshot.data}');
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    _reserveSpot(
                      parking.id,
                      _dateController.text,
                      _heureDebutController.text,
                      _heureFinController.text,
                      _typePlace,
                    );
                    Navigator.of(context).pop();
                  },
                  child: Text('Réserver'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Annuler'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _reserveSpot(
    String parkingId,
    String dateReservationString,
    String heureDebutString,
    String heureFinString,
    String typePlace,
  ) {
    String heureDebutOnly = heureDebutString.split(' ')[1];
    String heureFinOnly = heureFinString.split(' ')[1];
    DateTime heureDebutDateTime = DateFormat('HH:mm').parse(heureDebutOnly);
    DateTime heureFinDateTime = DateFormat('HH:mm').parse(heureFinOnly);
    DateTime dateReservation = dateFormat.parse(dateReservationString);

    Timestamp heureDebutTimestamp = Timestamp.fromMillisecondsSinceEpoch(
        dateReservation.millisecondsSinceEpoch +
            Duration(
                    hours: heureDebutDateTime.hour,
                    minutes: heureDebutDateTime.minute)
                .inMilliseconds);
    Timestamp heureFinTimestamp = Timestamp.fromMillisecondsSinceEpoch(
        dateReservation.millisecondsSinceEpoch +
            Duration(
                    hours: heureFinDateTime.hour,
                    minutes: heureFinDateTime.minute)
                .inMilliseconds);
    _firestore.collection('reservations').add({
      'dateReservation': dateFormat.parse(dateReservationString).toUtc(),
      'heureDebut': heureDebutTimestamp,
      'heureFin': heureFinTimestamp,
      'parkingId': parkingId,
      'typePlace': typePlace,
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Réservation effectuée avec succès.'),
        ),
      );
      _updateAvailableSpots(parkingId);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la réservation.'),
        ),
      );
    });
  }

  Future<int> _checkAvailability(
    String parkingId,
    String dateReservationString,
    String heureDebutString,
    String heureFinString,
  ) async {
    DateTime? heureDebut;
    DateTime? heureFin;

    try {
      String heureDebutOnly = heureDebutString.split(' ')[1];
      String heureFinOnly = heureFinString.split(' ')[1];

      heureDebut = DateFormat('HH:mm').parse(heureDebutOnly);
      heureFin = DateFormat('HH:mm').parse(heureFinOnly);
    } catch (e) {
      print('Erreur de format pour les heures : $e');
    }

    if (heureDebut == null || heureFin == null) {
      return 0; // Retourner 0 en cas d'erreur de format
    }

    QuerySnapshot reservationsSnapshot = await _firestore
        .collection('reservations')
        .where('parkingId', isEqualTo: parkingId)
        .where('dateReservation', isEqualTo: dateReservationString)
        .get();

    int placesReservees = 0;
    for (QueryDocumentSnapshot reservation in reservationsSnapshot.docs) {
      DateTime reservationDebut =
          (reservation['heureDebut'] as Timestamp).toDate();
      DateTime reservationFin = (reservation['heureFin'] as Timestamp).toDate();

      if ((heureDebut.isBefore(reservationFin) ||
              heureDebut == reservationFin) &&
          (heureFin.isAfter(reservationDebut) ||
              heureFin == reservationDebut)) {
        placesReservees += 1;
      }
    }

    DocumentSnapshot parkingSnapshot =
        await _firestore.collection('parking').doc(parkingId).get();
    int capacite = parkingSnapshot['capacite'];

    int placesDisponibles = capacite - placesReservees;
    return placesDisponibles;
  }

  void _updateAvailableSpots(String parkingId) async {
    try {
      QuerySnapshot reservationsSnapshot = await _firestore
          .collection('reservations')
          .where('parkingId', isEqualTo: parkingId)
          .get();

      int placesReserveesEnCours = 0;
      DateTime currentDateTime = DateTime.now();

      for (QueryDocumentSnapshot reservation in reservationsSnapshot.docs) {
        DateTime reservationDebut =
            (reservation['heureDebut'] as Timestamp).toDate();
        DateTime reservationFin =
            (reservation['heureFin'] as Timestamp).toDate();
        DateTime dateReservation =
            (reservation['dateReservation'] as Timestamp).toDate();

        if (currentDateTime.isAfter(reservationDebut) &&
            currentDateTime.isBefore(reservationFin) &&
            _isSameDay(dateReservation, currentDateTime)) {
          placesReserveesEnCours += 1;
        }
      }

      DocumentSnapshot parkingSnapshot =
          await _firestore.collection('parking').doc(parkingId).get();
      if (!parkingSnapshot.exists) {
        throw Exception('Le parking $parkingId n\'existe pas.');
      }
      int capacite = parkingSnapshot['capacite'];

      int placesDisponibles = capacite - placesReserveesEnCours;

      await _firestore
          .collection('parking')
          .doc(parkingId)
          .update({'placesDisponible': placesDisponibles});
    } catch (error) {
      print('Erreur lors de la mise à jour des places disponibles : $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erreur lors de la mise à jour des places disponibles.'),
        ),
      );
    }
  }

  Future<void> _checkCurrentAvailability() async {
    for (DocumentSnapshot parking in _parkings) {
      String parkingId = parking.id;
      _updateAvailableSpots(parkingId);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

void main() {
  runApp(MaterialApp(
    home: MapPage(),
  ));
}
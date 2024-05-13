import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ReservationPage extends StatefulWidget {
  final String parkingId;
  ReservationPage({required this.parkingId});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();
  Timestamp? _debutReservation;
  Timestamp? _finReservation;
  String _typePlace = 'standard';
  int _placesDisponibles = 0;

  late StreamSubscription<QuerySnapshot> _placesSubscription;

  @override
  void initState() {
    super.initState();
    _recupererNombrePlacesDisponibles();
    _placesSubscription = FirebaseFirestore.instance
        .collection('placeU')
        .where('id_parking', isEqualTo: widget.parkingId)
        .where('type', isEqualTo: _typePlace)
        .snapshots()
        .listen((querySnapshot) {
      int placesReservees = 0;
      final now = Timestamp.fromDate(DateTime.now());

      for (final placesDoc in querySnapshot.docs) {
        final reservations =
            placesDoc.data()['reservations'] as List<dynamic>? ?? [];
        for (final reservation in reservations) {
          final debutReservation = reservation['debut'] as Timestamp;
          final finReservation = reservation['fin'] as Timestamp;

          if (debutReservation.toDate().isAfter(now.toDate())) {
            placesReservees++;
          } else if (finReservation.toDate().isAfter(now.toDate())) {
            placesReservees++;
          }
        }
      }

      setState(() {
        _placesDisponibles = querySnapshot.docs.length - placesReservees;
      });
    });
  }

  @override
  void dispose() {
    _placesSubscription.cancel();
    super.dispose();
  }

  Future<void> _recupererNombrePlacesDisponibles() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('placeU')
        .where('id_parking', isEqualTo: widget.parkingId)
        .where('type', isEqualTo: _typePlace)
        .get();

    int placesReservees = 0;
    final now = Timestamp.fromDate(DateTime.now());

    for (final placesDoc in querySnapshot.docs) {
      final reservations =
          placesDoc.data()['reservations'] as List<dynamic>? ?? [];
      for (final reservation in reservations) {
        final debutReservation = reservation['debut'] as Timestamp;
        final finReservation = reservation['fin'] as Timestamp;

        if (debutReservation.toDate().isAfter(now.toDate())) {
          placesReservees++;
        } else if (finReservation.toDate().isAfter(now.toDate())) {
          placesReservees++;
        }
      }
    }

    setState(() {
      _placesDisponibles = querySnapshot.docs.length - placesReservees;
    });
  }

  Future<void> _selectDebutReservation(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _debutReservation = Timestamp.fromDate(DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          ));
        });
      }
    }
  }

  Future<void> _selectFinReservation(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _debutReservation?.toDate() ?? DateTime.now(),
      firstDate: _debutReservation?.toDate() ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _finReservation = Timestamp.fromDate(DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          ));
        });
      }
    }
  }

  Future<void> _reserverPlace() async {
    String? placesAttribueId;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('placeU')
          .where('id_parking', isEqualTo: widget.parkingId)
          .where('type', isEqualTo: _typePlace)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        bool chevauchementTotal = false;

        for (final placesDoc in querySnapshot.docs) {
          placesAttribueId = placesDoc.id;

          final reservationsExistantes = placesDoc.data()['reservations'] ?? [];
          chevauchementTotal = false;
          for (final reservation in reservationsExistantes) {
            final debutExistante = reservation['debut'].toDate();
            final finExistante = reservation['fin'].toDate();

            if ((_debutReservation!.toDate().isBefore(finExistante) &&
                    _debutReservation!.toDate().isAfter(debutExistante)) ||
                (_finReservation!.toDate().isBefore(finExistante) &&
                    _finReservation!.toDate().isAfter(debutExistante)) ||
                (_debutReservation!.toDate().isAtSameMomentAs(debutExistante) &&
                    _finReservation!.toDate().isAtSameMomentAs(finExistante)) ||
                (_debutReservation!.toDate().isBefore(debutExistante) &&
                    _finReservation!.toDate().isAfter(finExistante))) {
              chevauchementTotal = true;
              break;
            }
          }

          if (!chevauchementTotal) {
            await placesDoc.reference.update({
              'reservations': FieldValue.arrayUnion([
                {
                  'debut': _debutReservation,
                  'fin': _finReservation,
                }
              ])
            });

            await FirebaseFirestore.instance.collection('reservationU').add({
              'idParking': widget.parkingId,
              'debut': _debutReservation,
              'fin': _finReservation,
              'typePlace': _typePlace,
              'idPlace': placesAttribueId,
            });

            setState(() {
              _placesDisponibles--;
            });

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Réservation effectuée'),
                  content: Text(
                      'Votre réservation a été effectuée avec succès. La place attribuée est : $placesAttribueId\n\nPlaces disponibles : $_placesDisponibles'),
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
            return;
          }
        }

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Aucune place disponible'),
              content: Text(
                  'Désolé, aucune place n\'est actuellement disponible pour la période sélectionnée sans chevauchement de réservation.'),
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
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Aucune place disponible'),
              content: Text(
                  'Désolé, aucune place du type "$_typePlace" n\'est actuellement disponible pour la période sélectionnée.'),
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
    } catch (e) {
      // Gérer l'erreur ici
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content:
                Text('Une erreur s\'est produite lors de la réservation : $e'),
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
        title: Text('Réservation d\'une place'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Début de la réservation'),
                  ElevatedButton(
                    onPressed: () => _selectDebutReservation(context),
                    child: Text(_debutReservation != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(_debutReservation!.toDate())
                        : 'Sélectionner la date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Fin de la réservation'),
                  ElevatedButton(
                    onPressed: () => _selectFinReservation(context),
                    child: Text(_finReservation != null
                        ? DateFormat('dd/MM/yyyy HH:mm')
                            .format(_finReservation!.toDate())
                        : 'Sélectionner la date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
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
                    _recupererNombrePlacesDisponibles();
                  });
                },
              ),
              SizedBox(height: 20),
              Text('Places disponibles : $_placesDisponibles'),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _reserverPlace();
                  }
                },
                child: Text('Réserver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

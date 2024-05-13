// debut_reservation_page.dart
import 'package:flutter/material.dart';
import 'package:your_app/pages/fin_reservation_page.dart';

class DebutReservationPage extends StatefulWidget {
  @override
  _DebutReservationPageState createState() => _DebutReservationPageState();
}

class _DebutReservationPageState extends State<DebutReservationPage> {
  DateTime? _debutReservation;

  void _selectDebutReservation(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _debutReservation = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Début de la réservation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _selectDebutReservation(context),
              child: Text(_debutReservation != null
                  ? _debutReservation.toString()
                  : 'Sélectionner la date'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _debutReservation != null
                  ? () {
                      // Navigate to the next step (FinReservationPage)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FinReservationPage(
                            debutReservation: _debutReservation!,
                          ),
                        ),
                      );
                    }
                  : null,
              child: Text('Suivant'),
            ),
          ],
        ),
      ),
    );
  }
}

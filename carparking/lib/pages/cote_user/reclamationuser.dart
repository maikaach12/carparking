import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reclamation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReclamationPage(user: FirebaseAuth.instance.currentUser),
    );
  }
}

class ReclamationPage extends StatefulWidget {
  final User? user;

  ReclamationPage({Key? key, this.user}) : super(key: key);

  @override
  _ReclamationPageState createState() => _ReclamationPageState();
}

class _ReclamationPageState extends State<ReclamationPage> {
  final TextEditingController descriptionController = TextEditingController();
  String? selectedTypeProblem;
  List<String>? descriptions;
  String? otherDescription;

  Map<String, List<String>> typeProblemDescriptions = {
    'Place réservée non disponible': [
      "Le parking est complet.",
      "Toutes les places réservées sont occupées.",
      "Les places de parking sont bloquées par des véhicules mal garés.",
      "Les places de parking réservées aux personnes handicapées sont occupées par des véhicules non autorisés."
    ],
    'Problème de paiement': [
      "Erreur lors de la transaction de paiement.",
      "Paiement refusé sans raison apparente.",
      "Double débit sur la carte de crédit.",
      "Impossible de finaliser la transaction."
    ],
    'Problème de sécurité': [
      "Éclairage insuffisant dans le parking.",
      "Absence de caméras de surveillance.",
      "Présence de personnes suspectes dans le parking.",
      "Portes d'accès non sécurisées ou endommagées."
    ],
    'Difficulté daccès': [
      "Congestion du trafic à l'entrée du parking.",
      "Feux de signalisation défectueux.",
      "Entrée bloquée par des travaux de construction.",
      "Problèmes de circulation interne dans le parking."
    ],
    'Problème de réservation de handicap': [
      "Place de parking réservée occupée par un véhicule non autorisé.",
      "Absence de signalisation appropriée pour les places handicapées.",
      "Manque de respect des règles de stationnement pour les personnes handicapées.",
      "Difficulté à accéder aux places réservées en raison d'obstacles."
    ],
  };

  Future<void> submitReclamation(BuildContext context) async {
    if (selectedTypeProblem == 'Other') {
      if (otherDescription == null || otherDescription!.isEmpty) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Please enter a message for the admin'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
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

    try {
      String userId = widget.user!.uid;
      DateTime now = DateTime.now();

      await FirebaseFirestore.instance.collection('reclamation').add({
        'idUtilisateur': userId,
        'description': selectedTypeProblem == 'Other'
            ? otherDescription
            : descriptions![0],
        'statut': 'En attente',
        'dateCreation': now,
        'dateDerniereMiseAJour': now,
        'typeProbleme': selectedTypeProblem,
      });

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Your reclamation has been submitted.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      descriptionController.clear();
      selectedTypeProblem = null;
      descriptions = null;
      otherDescription = null;
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred. Please try again later.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
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
        title: Text('Reclamation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OtherProblemTextField(
              onChanged: (value) {
                setState(() {
                  otherDescription = value;
                });
              },
            ),
            DropdownButtonFormField<String>(
              value: selectedTypeProblem,
              onChanged: (value) {
                setState(() {
                  selectedTypeProblem = value;
                  descriptions = typeProblemDescriptions[value];
                  descriptions!.insert(0, value!);
                });
                descriptionController.clear();
              },
              decoration: InputDecoration(
                labelText: 'Type of Problem',
                border: OutlineInputBorder(),
              ),
              items: typeProblemDescriptions.keys.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
            ),
            SizedBox(height: 16.0),
            descriptions != null
                ? DropdownButtonFormField<String>(
                    value: descriptions!.isNotEmpty ? descriptions![0] : null,
                    onChanged: (value) {
                      if (descriptions != null &&
                          descriptions!.contains(value)) {
                        setState(() {
                          final index = descriptions!.indexOf(value!);
                          descriptions!.removeAt(index);
                          descriptions!.insert(0, value);
                        });
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    items: descriptions!.map((description) {
                      return DropdownMenuItem<String>(
                        value: description,
                        child: Text(description),
                      );
                    }).toList(),
                  )
                : Container(),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => submitReclamation(context),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class OtherProblemTextField extends StatefulWidget {
  final ValueChanged<String?> onChanged;
  OtherProblemTextField({required this.onChanged});

  @override
  _OtherProblemTextFieldState createState() => _OtherProblemTextFieldState();
}

class _OtherProblemTextFieldState extends State<OtherProblemTextField> {
  final TextEditingController _otherDescriptionController =
      TextEditingController();

  bool _isTextFieldVisible = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          title: Text('Autre'),
          trailing: IconButton(
            icon: Icon(_isTextFieldVisible ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() {
                _isTextFieldVisible = !_isTextFieldVisible;
              });
            },
          ),
        ),
        _isTextFieldVisible
            ? TextField(
                controller: _otherDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Enter your custom problem description',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  widget.onChanged(value);
                },
              )
            : Container(),
      ],
    );
  }
}

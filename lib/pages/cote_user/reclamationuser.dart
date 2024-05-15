import 'dart:math' as math;
import 'package:carparking/pages/cote_user/reclamlist.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReclamationPage extends StatefulWidget {
  final String userId;

  ReclamationPage({required this.userId});

  @override
  _ReclamationPageState createState() => _ReclamationPageState(userId);
}

class _ReclamationPageState extends State<ReclamationPage> {
  final String userId;
  _ReclamationPageState(this.userId);
  int _currentIndex = 0;

  final Map<String, List<String>> typeProblemDescriptions = {
    'Place réservée non disponible': [
      "Ma place réservée est occupée.",
      "Ma place réservée est bloquée par des véhicules mal garés.",
      //"Les places de parking réservées aux personnes handicapées sont occupées par des véhicules non autorisés."
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

  String? selectedTypeProblem;
  String? selectedDescription;
  String? otherDescription;
  String? reclamationId;

  Widget topWidget(double screenWidth) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment(-0.2, -0.8),
            end: Alignment.bottomCenter,
            colors: [
              Color(0x007CBFCF),
              Color(0xB316BFC4),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomWidget(double screenWidth) {
    return Container(
      width: 1.5 * screenWidth,
      height: 1.5 * screenWidth,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(0.6, -1.1),
          end: Alignment(0.7, 0.8),
          colors: [
            Color(0xDB4BE8CC),
            Color(0x005CDBCF),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -0.2 * screenHeight,
            left: -0.2 * screenWidth,
            child: topWidget(screenWidth),
          ),
          Positioned(
            bottom: -0.4 * screenHeight,
            right: -0.4 * screenWidth,
            child: bottomWidget(screenWidth),
          ),
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/blue.png'),
                fit: BoxFit.cover,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 13, vertical: 3),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 250, 248, 248),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: EdgeInsets.all(20),
                child: _currentIndex == 0
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '1. Sélectionnez le type de réclamation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.grey,
                                ),
                              ),
                              child: DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  border: InputBorder.none,
                                ),
                                value: selectedTypeProblem,
                                onChanged: (value) {
                                  setState(() {
                                    selectedTypeProblem = value;
                                    selectedDescription = null;
                                    otherDescription = null;
                                  });
                                },
                                items: typeProblemDescriptions.keys.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 16),
                            if (selectedTypeProblem != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '2. Sélectionnez une description',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: DropdownButtonFormField<String>(
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        border: InputBorder.none,
                                      ),
                                      value: selectedDescription,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedDescription = value;
                                          otherDescription = null;
                                        });
                                      },
                                      items: typeProblemDescriptions[
                                              selectedTypeProblem]!
                                          .map((description) {
                                        return DropdownMenuItem<String>(
                                          value: description,
                                          child: Text(description),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  if (selectedDescription == null)
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            otherDescription = value;
                                          });
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 8,
                                          ),
                                          hintText:
                                              'Entrez une description personnalisée',
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 16),
                                  SizedBox(height: 32),
                                  ElevatedButton(
                                    onPressed: submitReclamation,
                                    child: Text('Soumettre la réclamation'),
                                  )
                                ],
                              )
                            else
                              ReclamationListPage(userId: widget.userId),
                          ],
                        ),
                      )
                    : ReclamationListPage(userId: widget.userId),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Nouvelle réclamation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Mes réclamations',
          ),
        ],
      ),
    );
  }

  void submitReclamation() {
    // Enregistrer la réclamation dans Firestore
    FirebaseFirestore.instance.collection('reclamations').add({
      'type': selectedTypeProblem,
      'description': selectedDescription ?? otherDescription,
      'userId': widget.userId, // Use the userId from the widget parameter
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'en attente',
    });

    // Réinitialiser les champs
    setState(() {
      selectedTypeProblem = null;
      selectedDescription = null;
      otherDescription = null;
      reclamationId = null;
    });

    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Réclamation enregistrée avec succès'),
      ),
    );
  }
}

import 'package:carparking/pages/cote_admin/listuser.dart';
import 'package:carparking/pages/cote_admin/reclamation_admin.dart';
import 'package:flutter/material.dart';
import 'package:carparking/pages/cote_admin/Gerer_compte.dart';
import 'package:carparking/pages/cote_admin/Gerer_parking.dart';
import 'package:carparking/pages/cote_admin/Reclamationadmin.dart';

class AdminDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau de bord administrateur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageAccountsPage(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Gérer Compte',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GererParkingPage(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Gérer Parking',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 20),
            /* ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GererPlacesPage(),
                  ),
                );
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Gerer les places',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),              },*/

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UsersListPage(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Réclamation',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

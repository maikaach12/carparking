import 'package:carparking/pages/cote_admin/listuser.dart';
import 'package:carparking/pages/cote_admin/reclamation_admin.dart';
import 'package:flutter/material.dart';
import 'package:carparking/pages/cote_admin/Gerer_compte.dart';
import 'package:carparking/pages/cote_admin/Gerer_parking.dart';
import 'package:carparking/pages/cote_admin/Reclamationadmin.dart';

class AdminDashboardPage extends StatefulWidget {
  final String userId;
  final String userEmail;

  AdminDashboardPage({required this.userId, required this.userEmail});
  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _showSidebar = false;
  Widget _currentPage =
      Center(child: Text('Bienvenue sur le tableau de bord administrateur'));

  void _navigateTo(Widget page) {
    setState(() {
      _currentPage = page;
      _showSidebar = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: _showSidebar ? 250 : 0,
                child: Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      UserAccountsDrawerHeader(
                        accountName: Text(widget.userEmail),
                        accountEmail: Text(widget.userId),
                        currentAccountPicture: CircleAvatar(
                          child: Text('ADMIN'),
                        ),
                      ),
                      ListTile(
                        title: Text('Gérer Compte'),
                        onTap: () {
                          _navigateTo(ManageAccountsPage());
                        },
                      ),
                      ListTile(
                        title: Text('Gérer Parking'),
                        onTap: () {
                          _navigateTo(GererParkingPage());
                        },
                      ),
                      ListTile(
                        title: Text('Gérer Réclamation'),
                        onTap: () {
                          _navigateTo(UsersListPage());
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Navbar(
                      onMenuTap: () {
                        setState(() {
                          _showSidebar = !_showSidebar;
                        });
                      },
                      onHomeTap: () {
                        _navigateTo(Center(
                            child: Text(
                                'Bienvenue sur le tableau de bord administrateur')));
                      },
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: _currentPage,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            child: MouseRegion(
              opaque: false,
              onHover: (_) {
                setState(() {
                  _showSidebar = true;
                });
              },
              onExit: (_) {
                setState(() {
                  _showSidebar = false;
                });
              },
              child: Container(
                width: 10,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Navbar extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onHomeTap;

  Navbar({required this.onMenuTap, required this.onHomeTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.grey[200],
      child: Row(
        children: [
          IconButton(
            onPressed: onMenuTap,
            icon: Icon(Icons.menu),
          ),
          Spacer(),
          IconButton(
            onPressed: onHomeTap,
            icon: Icon(Icons.home),
          ),
        ],
      ),
    );
  }
}

class NavbarItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  NavbarItem({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

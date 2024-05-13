// Importations
import 'package:carparking/firebase_options.dart';
import 'package:carparking/pages/login_signup/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Fonction principale
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// Application MyApp
class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CarParking.dz',
        home: AuthPage());
  }
}

// AuthPage pour gérer l'authentification

// Page de connexion de l'administrateur




// Page d'inscription de l'utilisateur

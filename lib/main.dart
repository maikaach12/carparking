// Importations
import 'package:carparking/pages/login_signup/firstPage.dart';
import 'package:carparking/pages/login_signup/sign_up.dart';
import 'package:carparking/test_paiement/creteproduct.dart';
import 'package:carparking/firebase_options.dart';
import 'package:carparking/pages/checkout.dart';
import 'package:carparking/pages/cote_user/reservation/checkout.dart';
import 'package:carparking/pages/cote_user/reservation/paiement.dart';
import 'package:carparking/pages/cote_user/reservation/paiementonline.dart';
import 'package:carparking/pages/login_signup/auth_page.dart';
import 'package:carparking/pages/login_signup/loginPage.dart';
import 'package:carparking/test_paiement/customer.dart';
import 'package:carparking/test_paiement/productlist.dart';
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
        home: FirstPage()
        //PaiementOnlinePage(reservationId: 'rYYqO8wzkDp9Q8Qq6GAp', )

        );
  }
}

// AuthPage pour gérer l'authentification

// Page de connexion de l'administrateur




// Page d'inscription de l'utilisateur

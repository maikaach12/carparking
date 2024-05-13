// File generated by FlutterFire CLI.
// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBLbuOs7HAogf7ixd8odmUTOHc68RIxAaw',
    appId: '1:625483831682:web:8fc12d620f386cdfc5179b',
    messagingSenderId: '625483831682',
    projectId: 'carparking-ec2e9',
    authDomain: 'carparking-ec2e9.firebaseapp.com',
    storageBucket: 'carparking-ec2e9.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBhcP5eJ5OYaXoiTu215YC6ttcCb5rQ1HQ',
    appId: '1:625483831682:android:16cf083d760e53a5c5179b',
    messagingSenderId: '625483831682',
    projectId: 'carparking-ec2e9',
    storageBucket: 'carparking-ec2e9.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATcvf57V5y2vSaoN5bBs-lh0ukWSoA144',
    appId: '1:625483831682:ios:0741df816bfa1b9cc5179b',
    messagingSenderId: '625483831682',
    projectId: 'carparking-ec2e9',
    storageBucket: 'carparking-ec2e9.appspot.com',
    iosBundleId: 'com.example.carparking',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyATcvf57V5y2vSaoN5bBs-lh0ukWSoA144',
    appId: '1:625483831682:ios:0741df816bfa1b9cc5179b',
    messagingSenderId: '625483831682',
    projectId: 'carparking-ec2e9',
    storageBucket: 'carparking-ec2e9.appspot.com',
    iosBundleId: 'com.example.carparking',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBLbuOs7HAogf7ixd8odmUTOHc68RIxAaw',
    appId: '1:625483831682:web:185ff5b2f4a3bf1bc5179b',
    messagingSenderId: '625483831682',
    projectId: 'carparking-ec2e9',
    authDomain: 'carparking-ec2e9.firebaseapp.com',
    storageBucket: 'carparking-ec2e9.appspot.com',
  );
}

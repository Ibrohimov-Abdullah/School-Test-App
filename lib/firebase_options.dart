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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyDQbqZXEZRUEw2PxzK5bfJCEQWhB3uNXSo',
    appId: '1:952999834474:web:1a1f9f040fec58cfdeab13',
    messagingSenderId: '952999834474',
    projectId: 'school-test-app-7d951',
    authDomain: 'school-test-app-7d951.firebaseapp.com',
    storageBucket: 'school-test-app-7d951.firebasestorage.app',
    measurementId: 'G-F9Z3389BSF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhivVHvnCkLnp8eO2QLjhkml8azV76NVs',
    appId: '1:952999834474:android:194f7adbf8a8d5e1deab13',
    messagingSenderId: '952999834474',
    projectId: 'school-test-app-7d951',
    storageBucket: 'school-test-app-7d951.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBtPs40GKu7Lk9gLzAl192NHkE65qw2B-g',
    appId: '1:952999834474:ios:4b08ff7e3c51b2cadeab13',
    messagingSenderId: '952999834474',
    projectId: 'school-test-app-7d951',
    storageBucket: 'school-test-app-7d951.firebasestorage.app',
    iosBundleId: 'com.example.schoolTestApp',
  );
}

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
    apiKey: 'AIzaSyCVc4i8QW571sUUw_XAeNLzrsZzwE408i8',
    appId: '1:430197957945:web:410936a82b671da0a8b4e8',
    messagingSenderId: '430197957945',
    projectId: 'newpet-2453f',
    authDomain: 'newpet-2453f.firebaseapp.com',
    storageBucket: 'newpet-2453f.firebasestorage.app',
    measurementId: 'G-S0DV7B9J79',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBIHcTYU9eeHf9mn4i9nLi-EiDm5HefTJw',
    appId: '1:430197957945:android:d7e11c933ac36feba8b4e8',
    messagingSenderId: '430197957945',
    projectId: 'newpet-2453f',
    storageBucket: 'newpet-2453f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDSLWIhdyQDcUUAOsZ1_hShgGHKtNpRhUE',
    appId: '1:430197957945:ios:7027d28210ae90c8a8b4e8',
    messagingSenderId: '430197957945',
    projectId: 'newpet-2453f',
    storageBucket: 'newpet-2453f.firebasestorage.app',
    iosBundleId: 'com.example.youssef',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDSLWIhdyQDcUUAOsZ1_hShgGHKtNpRhUE',
    appId: '1:430197957945:ios:7027d28210ae90c8a8b4e8',
    messagingSenderId: '430197957945',
    projectId: 'newpet-2453f',
    storageBucket: 'newpet-2453f.firebasestorage.app',
    iosBundleId: 'com.example.youssef',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCVc4i8QW571sUUw_XAeNLzrsZzwE408i8',
    appId: '1:430197957945:web:877a72289587f5f9a8b4e8',
    messagingSenderId: '430197957945',
    projectId: 'newpet-2453f',
    authDomain: 'newpet-2453f.firebaseapp.com',
    storageBucket: 'newpet-2453f.firebasestorage.app',
    measurementId: 'G-8SV60MXN5M',
  );
}

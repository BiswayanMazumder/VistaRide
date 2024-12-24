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
    apiKey: 'AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI',
    appId: '1:1025680611513:web:224258f15cffa8fa1ea368',
    messagingSenderId: '1025680611513',
    projectId: 'vistafeedd',
    authDomain: 'vistafeedd.firebaseapp.com',
    storageBucket: 'vistafeedd.appspot.com',
    measurementId: 'G-4ZTPSHCN45',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6NjVZRN9pMg8FyHuWaTM6YCgAPo6jYv4',
    appId: '1:1025680611513:android:42b9cea3210b414c1ea368',
    messagingSenderId: '1025680611513',
    projectId: 'vistafeedd',
    storageBucket: 'vistafeedd.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBJHzDF5H6Y8Ihp6yUh4ltP-I-bHPnfYLs',
    appId: '1:1025680611513:ios:f1c2626b0efcc5651ea368',
    messagingSenderId: '1025680611513',
    projectId: 'vistafeedd',
    storageBucket: 'vistafeedd.appspot.com',
    androidClientId: '1025680611513-700mqqp5me1ktsj0jmr7btg2hej9qubk.apps.googleusercontent.com',
    iosClientId: '1025680611513-1arni48h8dofhu096otgl02grkvjqe5f.apps.googleusercontent.com',
    iosBundleId: 'com.example.vistaride',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBJHzDF5H6Y8Ihp6yUh4ltP-I-bHPnfYLs',
    appId: '1:1025680611513:ios:f1c2626b0efcc5651ea368',
    messagingSenderId: '1025680611513',
    projectId: 'vistafeedd',
    storageBucket: 'vistafeedd.appspot.com',
    androidClientId: '1025680611513-700mqqp5me1ktsj0jmr7btg2hej9qubk.apps.googleusercontent.com',
    iosClientId: '1025680611513-1arni48h8dofhu096otgl02grkvjqe5f.apps.googleusercontent.com',
    iosBundleId: 'com.example.vistaride',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA5h_ElqdgLrs6lXLgwHOfH9Il5W7ARGiI',
    appId: '1:1025680611513:web:0f8c6be4228dba901ea368',
    messagingSenderId: '1025680611513',
    projectId: 'vistafeedd',
    authDomain: 'vistafeedd.firebaseapp.com',
    storageBucket: 'vistafeedd.appspot.com',
    measurementId: 'G-ZFRR1BZQFV',
  );

}
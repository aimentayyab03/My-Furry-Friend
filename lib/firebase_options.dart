
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
    apiKey: 'AIzaSyCx_M69H6N8tsN6fw0kZlYdzXR6c-8m2eM',
    appId: '1:994906740658:android:bffcc76e999223e4c2f6ab',
    messagingSenderId: '324931038039',
    projectId: 'my-furry-friend-fyp1',
    authDomain: 'my-furry-friend-fyp1.firebaseapp.com',
    storageBucket: 'my-furry-friend-fyp1.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCx_M69H6N8tsN6fw0kZlYdzXR6c-8m2eM',
    appId: '1:994906740658:android:bffcc76e999223e4c2f6ab',
    messagingSenderId: '324931038039',
    projectId: 'my-furry-friend-fyp1',
    storageBucket: 'my-furry-friend-fyp1.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCx_M69H6N8tsN6fw0kZlYdzXR6c-8m2eM',
    appId: '1:994906740658:android:bffcc76e999223e4c2f6ab',
    messagingSenderId: '324931038039',
    projectId: 'my-furry-friend-fyp1',
    storageBucket: 'my-furry-friend-fyp1.firebasestorage.app',
    iosBundleId: 'com.example.fypTwo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCx_M69H6N8tsN6fw0kZlYdzXR6c-8m2eM',
    appId: '1:994906740658:android:bffcc76e999223e4c2f6ab',
    messagingSenderId: '324931038039',
    projectId: 'my-furry-friend-fyp1',
    storageBucket: 'my-furry-friend-fyp1.firebasestorage.app',
    iosBundleId: 'com.example.fypTwo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCx_M69H6N8tsN6fw0kZlYdzXR6c-8m2eM',
    appId: '1:994906740658:android:bffcc76e999223e4c2f6ab',
    messagingSenderId: '324931038039',
    projectId: 'my-furry-friend-fyp1',
    authDomain: 'my-furry-friend-fyp1.firebaseapp.com',
    storageBucket: 'my-furry-friend-fyp1.firebasestorage.app',
  );

}
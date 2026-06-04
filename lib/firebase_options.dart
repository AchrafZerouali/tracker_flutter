import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'Configure Android avec: flutterfire configure',
        );
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return apple;
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Configure Linux avec: flutterfire configure',
        );
      default:
        throw UnsupportedError('Plateforme non supportée.');
    }
  }

  static const FirebaseOptions apple = FirebaseOptions(
    apiKey: 'AIzaSyCD8hXb8LgScXEXEiAl80URplolkIAzV28',
    appId: '1:801831492617:ios:7eff7ed1c72da15ff4acd8',
    messagingSenderId: '801831492617',
    projectId: 'tracker-flutter-55384',
    storageBucket: 'tracker-flutter-55384.firebasestorage.app',
    iosBundleId: 'com.example.trackerFlutter',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAEihFW2NWhEicfMRr5KRTTqFVruB8toag',
    appId: '1:801831492617:web:f7e82fb00fdef0daf4acd8',
    messagingSenderId: '801831492617',
    projectId: 'tracker-flutter-55384',
    authDomain: 'tracker-flutter-55384.firebaseapp.com',
    storageBucket: 'tracker-flutter-55384.firebasestorage.app',
    measurementId: 'G-RWR2M3BYZD',
  );
}

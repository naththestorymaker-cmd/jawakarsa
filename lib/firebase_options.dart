import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions tidak tersedia untuk platform ini. '
          'Jalankan flutterfire configure.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME_apiKey',
    appId: 'REPLACE_ME_appId',
    messagingSenderId: 'REPLACE_ME_senderId',
    projectId: 'REPLACE_ME_projectId',
    authDomain: 'REPLACE_ME_projectId.firebaseapp.com',
    storageBucket: 'REPLACE_ME_projectId.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME_apiKey',
    appId: 'REPLACE_ME_appId',
    messagingSenderId: 'REPLACE_ME_senderId',
    projectId: 'REPLACE_ME_projectId',
    storageBucket: 'REPLACE_ME_projectId.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME_apiKey',
    appId: 'REPLACE_ME_appId',
    messagingSenderId: 'REPLACE_ME_senderId',
    projectId: 'REPLACE_ME_projectId',
    storageBucket: 'REPLACE_ME_projectId.appspot.com',
    iosBundleId: 'com.example.jawakarsa',
  );
}

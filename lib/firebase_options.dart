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
    apiKey: 'AIzaSyA1TfyMKLVvRbNMP1swuEh-Jf-Wf78G-Rg',
    appId: '1:606535605182:web:218da88f313192ec6d77ef',
    messagingSenderId: '606535605182',
    projectId: 'jawakarsa-59a61',
    authDomain: 'jawakarsa-59a61.firebaseapp.com',
    storageBucket: 'jawakarsa-59a61.firebasestorage.app',
    measurementId: 'G-1T01XQX6E9',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDrfNMrwUHzAAwDIBgrG4ZIUDOx7pGy53k',
    appId: '1:606535605182:android:d2ee32c6125bc5576d77ef',
    messagingSenderId: '606535605182',
    projectId: 'jawakarsa-59a61',
    storageBucket: 'jawakarsa-59a61.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME_apiKey',
    appId: 'REPLACE_ME_appId',
    messagingSenderId: 'REPLACE_ME_senderId',
    projectId: 'jawakarsa-59a61',
    storageBucket: 'jawakarsa-59a61.firebasestorage.app',
    iosBundleId: 'com.example.jawakarsa',
  );
}

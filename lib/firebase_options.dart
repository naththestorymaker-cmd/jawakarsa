// File ini dibuat sebagai template.
// Untuk menggunakan Firebase, ikuti langkah:
//
// 1. Buka https://console.firebase.google.com
// 2. Buat project baru (atau gunakan yang sudah ada)
// 3. Di project, pilih "Add app" → Android → isi package name: com.example.jawakarsa
// 4. Download google-services.json, taruh di android/app/
// 5. Jalankan: dart pub global activate flutterfire_cli
//              flutterfire configure
//    Perintah itu akan me-overwrite file ini dengan nilai yang benar.
//
// Selama file ini berisi nilai dummy, FirebaseApp TIDAK akan diinisialisasi
// dan app akan berjalan dalam mode lokal (UUID tanpa Firebase).

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

  // ── Ganti semua nilai "REPLACE_ME_*" dengan output flutterfire configure ──

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

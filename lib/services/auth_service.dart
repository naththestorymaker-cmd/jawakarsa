import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawakarsa/services/network_service.dart';

const _kUserId = 'user_id';
const _kUserName = 'user_name';
const _kUserEmail = 'user_email';
const _kUserPhotoUrl = 'user_photo_url';
const _kAuthProvider = 'auth_provider';

const _kGoogleServerClientId =
    '606535605182-b5ilkrg1jkon9c7rl141eq8suhh87i0v.apps.googleusercontent.com';

bool _isFirebaseConfigured() {
  try {
    FirebaseAuth.instance;
    return true;
  } catch (_) {
    return false;
  }
}

String _generateLocalUid() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int b) => b.toRadixString(16).padLeft(2, '0');
  final b = bytes;
  return '${hex(b[0])}${hex(b[1])}${hex(b[2])}${hex(b[3])}-'
      '${hex(b[4])}${hex(b[5])}-'
      '${hex(b[6])}${hex(b[7])}-'
      '${hex(b[8])}${hex(b[9])}-'
      '${hex(b[10])}${hex(b[11])}${hex(b[12])}${hex(b[13])}${hex(b[14])}${hex(b[15])}';
}

class GoogleSignInResult {
  const GoogleSignInResult({
    required this.uid,
    required this.displayName,
    this.email,
    this.photoUrl,
  });

  final String uid;
  final String displayName;
  final String? email;
  final String? photoUrl;
}

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.name,
    this.email,
    this.photoUrl,
    this.isGoogleUser = false,
  });

  final String uid;
  final String name;
  final String? email;
  final String? photoUrl;
  final bool isGoogleUser;
}

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<GoogleSignInResult?> signInWithGoogle() async {
    if (!await NetworkService.instance.hasInternet(forceRefresh: true)) {
      throw const NoInternetException();
    }

    if (!_isFirebaseConfigured()) {
      throw StateError('Firebase belum dikonfigurasi pada perangkat ini.');
    }

    if (kIsWeb) {
      try {
        final provider = GoogleAuthProvider()
          ..setCustomParameters({'prompt': 'select_account'});
        final credential = await FirebaseAuth.instance
            .signInWithPopup(provider)
            .timeout(const Duration(seconds: 45));
        final user = credential.user;
        if (user == null) return null;

        return GoogleSignInResult(
          uid: user.uid,
          displayName: user.displayName ?? '',
          email: user.email,
          photoUrl: user.photoURL,
        );
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-closed-by-user' ||
            e.code == 'cancelled-popup-request' ||
            e.code == 'user-cancelled') {
          return null;
        }
        rethrow;
      }
    }

    final googleSignIn = GoogleSignIn(serverClientId: _kGoogleServerClientId);
    final googleUser = await googleSignIn.signIn().timeout(
      const Duration(seconds: 45),
    );
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication.timeout(
      const Duration(seconds: 15),
    );
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCred = await FirebaseAuth.instance
        .signInWithCredential(credential)
        .timeout(const Duration(seconds: 15));
    final user = userCred.user;
    if (user == null) return null;

    return GoogleSignInResult(
      uid: user.uid,
      displayName: user.displayName ?? googleUser.displayName ?? '',
      email: user.email ?? googleUser.email,
      photoUrl: user.photoURL ?? googleUser.photoUrl,
    );
  }

  Future<String> completeGoogleOnboarding(
    GoogleSignInResult account,
    String nickname,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final cleanName = nickname.trim();

    await prefs.setString(_kUserId, account.uid);
    await prefs.setString(_kUserName, cleanName);
    await prefs.setString(_kAuthProvider, 'google');
    if (account.email != null && account.email!.isNotEmpty) {
      await prefs.setString(_kUserEmail, account.email!);
    } else {
      await prefs.remove(_kUserEmail);
    }
    if (account.photoUrl != null && account.photoUrl!.isNotEmpty) {
      await prefs.setString(_kUserPhotoUrl, account.photoUrl!);
    } else {
      await prefs.remove(_kUserPhotoUrl);
    }

    if (_isFirebaseConfigured() &&
        await NetworkService.instance.hasInternet()) {
      try {
        await FirebaseAuth.instance.currentUser
            ?.updateDisplayName(cleanName)
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
    }

    return account.uid;
  }

  Future<UserProfile> linkGoogleToCurrentProfile(
    GoogleSignInResult account,
  ) async {
    final existingName = await getSavedName();
    final effectiveName =
        (existingName != null && existingName.trim().isNotEmpty)
        ? existingName.trim()
        : (account.displayName.trim().isNotEmpty
              ? account.displayName.trim()
              : 'Penjelajah');

    await completeGoogleOnboarding(account, effectiveName);
    return UserProfile(
      uid: account.uid,
      name: effectiveName,
      email: account.email,
      photoUrl: account.photoUrl,
      isGoogleUser: true,
    );
  }

  Future<String> signInAndSaveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    String uid;

    if (_isFirebaseConfigured() &&
        await NetworkService.instance.hasInternet()) {
      try {
        final credential = await FirebaseAuth.instance
            .signInAnonymously()
            .timeout(const Duration(seconds: 4));
        uid = credential.user!.uid;
      } catch (_) {
        uid = _generateLocalUid();
      }
    } else {
      uid = _generateLocalUid();
    }

    await prefs.setString(_kUserId, uid);
    await prefs.setString(_kUserName, name.trim());
    await prefs.setString(_kAuthProvider, 'guest');
    await prefs.remove(_kUserEmail);
    await prefs.remove(_kUserPhotoUrl);

    return uid;
  }

  Future<void> updateNickname(String newName) async {
    final cleanName = newName.trim();
    if (cleanName.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kUserName, cleanName);

    if (_isFirebaseConfigured() &&
        await NetworkService.instance.hasInternet()) {
      try {
        await FirebaseAuth.instance.currentUser
            ?.updateDisplayName(cleanName)
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
    }
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kUserName);
    if (name == null || name.isEmpty) return null;

    final uid = prefs.getString(_kUserId) ?? '';
    final provider = prefs.getString(_kAuthProvider) ?? 'guest';
    return UserProfile(
      uid: uid,
      name: name,
      email: prefs.getString(_kUserEmail),
      photoUrl: prefs.getString(_kUserPhotoUrl),
      isGoogleUser: provider == 'google',
    );
  }

  Future<String?> getSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName);
  }

  Future<String?> getSavedUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserId);
  }

  Future<bool> isOnboarded() async {
    final name = await getSavedName();
    return name != null && name.isNotEmpty;
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
    await prefs.remove(_kUserName);
    await prefs.remove(_kUserEmail);
    await prefs.remove(_kUserPhotoUrl);
    await prefs.remove(_kAuthProvider);

    if (!kIsWeb) {
      try {
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn().timeout(
          const Duration(seconds: 2),
        )) {
          await googleSignIn.signOut().timeout(const Duration(seconds: 3));
        }
      } catch (_) {}
    }

    if (_isFirebaseConfigured()) {
      try {
        await FirebaseAuth.instance.signOut().timeout(
          const Duration(seconds: 3),
        );
      } catch (_) {}
    }
  }
}

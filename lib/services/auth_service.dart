import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kUserId = 'user_id';
const _kUserName = 'user_name';

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

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<String> signInAndSaveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    String uid;

    if (_isFirebaseConfigured()) {
      try {
        final credential = await FirebaseAuth.instance.signInAnonymously();
        uid = credential.user!.uid;
      } catch (e) {
        uid = _generateLocalUid();
      }
    } else {
      uid = _generateLocalUid();
    }

    await prefs.setString(_kUserId, uid);
    await prefs.setString(_kUserName, name.trim());

    return uid;
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
    if (_isFirebaseConfigured()) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
    }
  }
}

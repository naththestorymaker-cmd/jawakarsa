import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kunci SharedPreferences
const _kUserId = 'user_id';
const _kUserName = 'user_name';

/// Cek apakah Firebase sudah dikonfigurasi (bukan nilai placeholder).
bool _isFirebaseConfigured() {
  // firebase_options.dart menyimpan 'REPLACE_ME_*' saat belum dikonfigurasi.
  // Cara paling aman: coba akses FirebaseAuth.instance — jika belum ada app
  // yang diinisialisasi, kita tangkap exception-nya.
  try {
    FirebaseAuth.instance; // akan throw jika belum di-init
    return true;
  } catch (_) {
    return false;
  }
}

/// Membuat UUID sederhana v4 sebagai fallback lokal.
String _generateLocalUid() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // variant
  String hex(int b) => b.toRadixString(16).padLeft(2, '0');
  final b = bytes;
  return '${hex(b[0])}${hex(b[1])}${hex(b[2])}${hex(b[3])}-'
      '${hex(b[4])}${hex(b[5])}-'
      '${hex(b[6])}${hex(b[7])}-'
      '${hex(b[8])}${hex(b[9])}-'
      '${hex(b[10])}${hex(b[11])}${hex(b[12])}${hex(b[13])}${hex(b[14])}${hex(b[15])}';
}

/// Service untuk autentikasi anonim dan persistensi data pengguna.
///
/// Flow:
///   1. Panggil [signInAndSaveName] dengan nama yang diinput pengguna.
///   2. Jika Firebase tersedia → [signInAnonymously] untuk mendapat UID unik.
///   3. Jika belum → buat UUID lokal sebagai fallback.
///   4. Simpan UID + nama ke [SharedPreferences].
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  /// Sign-in anonim + simpan nama ke SharedPreferences.
  /// Mengembalikan UID yang digunakan (Firebase UID atau UUID lokal).
  Future<String> signInAndSaveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    String uid;

    if (_isFirebaseConfigured()) {
      try {
        final credential = await FirebaseAuth.instance.signInAnonymously();
        uid = credential.user!.uid;
      } catch (e) {
        // Firebase ada tapi sign-in gagal (misalnya anonymous auth belum aktif)
        uid = _generateLocalUid();
      }
    } else {
      uid = _generateLocalUid();
    }

    await prefs.setString(_kUserId, uid);
    await prefs.setString(_kUserName, name.trim());

    return uid;
  }

  /// Ambil nama yang sudah tersimpan. Null jika belum pernah login.
  Future<String?> getSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserName);
  }

  /// Ambil UID yang sudah tersimpan. Null jika belum pernah login.
  Future<String?> getSavedUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kUserId);
  }

  /// Apakah user sudah pernah set nama (sudah melewati personalization).
  Future<bool> isOnboarded() async {
    final name = await getSavedName();
    return name != null && name.isNotEmpty;
  }

  /// Hapus data user (untuk keperluan logout / reset).
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

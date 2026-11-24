import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jawakarsa/models/game_score.dart';
import 'package:jawakarsa/services/auth_service.dart';
import 'package:jawakarsa/services/network_service.dart';

enum GameType { kanvas, tts, cocok }

const _kScoresKey = 'local_leaderboard';

class ScoreService {
  ScoreService._();
  static final ScoreService instance = ScoreService._();

  static const int rewardPerGame = 50;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _firestoreSub;
  final _controller = _LeaderboardController();

  bool get isFirebaseReady {
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> submitScore(GameType type, int score) async {
    final uid = await AuthService.instance.getSavedUid();
    final name = await AuthService.instance.getSavedName();
    if (uid == null || name == null) return;

    final prefs = await SharedPreferences.getInstance();
    final all = _loadAll(prefs);

    final existing = all.firstWhere(
      (e) => e.uid == uid,
      orElse: () => GameScore(uid: uid, name: name, totalScore: 0),
    );

    final updated = existing.copyWith(
      kanvasScore: type == GameType.kanvas
          ? existing.kanvasScore + score
          : null,
      ttsScore: type == GameType.tts ? existing.ttsScore + score : null,
      cocokScore: type == GameType.cocok ? existing.cocokScore + score : null,
      updatedAt: DateTime.now(),
    );

    all.removeWhere((e) => e.uid == uid);
    all.add(updated);
    all.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    await prefs.setString(
      _kScoresKey,
      jsonEncode(all.map((e) => e.toLocalMap()).toList()),
    );
    _notifyListeners(all);

    if (isFirebaseReady && await NetworkService.instance.hasInternet()) {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('leaderboard')
            .doc(uid);

        final firestoreData = <String, dynamic>{
          'uid': uid,
          'name': name,
          'totalScore': updated.totalScore,
          'kanvasScore': updated.kanvasScore,
          'ttsScore': updated.ttsScore,
          'cocokScore': updated.cocokScore,
          'updatedAt': FieldValue.serverTimestamp(),
        };

        await docRef
            .set(firestoreData, SetOptions(merge: true))
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Sinkronisasi Firestore tertunda (offline/izin): $e');
      }
    }
  }

  List<GameScore> _loadAll(SharedPreferences prefs) {
    final raw = prefs.getString(_kScoresKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => GameScore.fromLocalMap(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<GameScore>> leaderboardStream() {
    _initStreamIfNeeded();
    return _controller.stream;
  }

  void _initStreamIfNeeded() {
    if (isFirebaseReady && _firestoreSub == null) {
      try {
        _firestoreSub = FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('totalScore', descending: true)
            .limit(100)
            .snapshots()
            .listen(
              (snapshot) async {
                final scores = snapshot.docs
                    .map((doc) => GameScore.fromFirestore(doc.data(), doc.id))
                    .toList();

                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                  _kScoresKey,
                  jsonEncode(scores.map((e) => e.toLocalMap()).toList()),
                );

                _controller.add(scores);
              },
              onError: (Object error) async {
                debugPrint(
                  'Error Firestore stream: $error. Beralih ke data lokal.',
                );
                final prefs = await SharedPreferences.getInstance();
                _controller.add(_loadAll(prefs));
              },
            );
        return;
      } catch (e) {
        debugPrint('Gagal inisialisasi Firestore stream: $e');
      }
    }

    refreshLeaderboard();
  }

  void _notifyListeners(List<GameScore> scores) {
    _controller.add(scores);
  }

  Future<void> refreshLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();

    if (isFirebaseReady && await NetworkService.instance.hasInternet()) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('leaderboard')
            .orderBy('totalScore', descending: true)
            .limit(100)
            .get()
            .timeout(const Duration(seconds: 5));

        if (snap.docs.isNotEmpty) {
          final scores = snap.docs
              .map((doc) => GameScore.fromFirestore(doc.data(), doc.id))
              .toList();

          await prefs.setString(
            _kScoresKey,
            jsonEncode(scores.map((e) => e.toLocalMap()).toList()),
          );
          _controller.add(scores);
          return;
        }
      } catch (e) {
        debugPrint('Refresh Firestore error: $e. Menggunakan cache lokal.');
      }
    }

    final all = _loadAll(prefs);
    _controller.add(all);
  }

  Future<List<GameScore>> getLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    return _loadAll(prefs);
  }

  static int findRank(String? uid, List<GameScore> scores) {
    if (uid == null || scores.isEmpty) return 0;
    final idx = scores.indexWhere((e) => e.uid == uid);
    return idx >= 0 ? idx + 1 : 0;
  }
}

class _LeaderboardController {
  final _listeners = <void Function(List<GameScore>)>[];
  List<GameScore> _last = [];

  Stream<List<GameScore>> get stream => Stream.multi((controller) {
    controller.add(_last);
    void listener(List<GameScore> data) {
      controller.add(data);
    }

    _listeners.add(listener);
    controller.onCancel = () => _listeners.remove(listener);
  });

  void add(List<GameScore> data) {
    _last = data;
    for (final l in List.of(_listeners)) {
      l(data);
    }
  }
}

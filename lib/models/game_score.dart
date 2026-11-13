class GameScore {
  const GameScore({
    required this.uid,
    required this.name,
    required this.totalScore,
    this.kanvasScore = 0,
    this.ttsScore = 0,
    this.cocokScore = 0,
    this.updatedAt,
  });

  final String uid;
  final String name;
  final int totalScore;
  final int kanvasScore;
  final int ttsScore;
  final int cocokScore;
  final DateTime? updatedAt;

  factory GameScore.fromLocalMap(Map<String, dynamic> d) => GameScore(
        uid: d['uid'] as String? ?? '',
        name: d['name'] as String? ?? 'Anonim',
        totalScore: (d['totalScore'] as num?)?.toInt() ?? 0,
        kanvasScore: (d['kanvasScore'] as num?)?.toInt() ?? 0,
        ttsScore: (d['ttsScore'] as num?)?.toInt() ?? 0,
        cocokScore: (d['cocokScore'] as num?)?.toInt() ?? 0,
        updatedAt: d['updatedAt'] != null
            ? DateTime.tryParse(d['updatedAt'] as String)
            : null,
      );

  Map<String, dynamic> toLocalMap() => {
        'uid': uid,
        'name': name,
        'totalScore': totalScore,
        'kanvasScore': kanvasScore,
        'ttsScore': ttsScore,
        'cocokScore': cocokScore,
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory GameScore.fromFirestore(Map<String, dynamic> d, String docId) {
    DateTime? parsedDate;
    final rawDate = d['updatedAt'];
    if (rawDate != null) {
      if (rawDate is DateTime) {
        parsedDate = rawDate;
      } else if (rawDate is String) {
        parsedDate = DateTime.tryParse(rawDate);
      } else {
        // Objek Timestamp dari Firestore
        try {
          // ignore: avoid_dynamic_calls
          parsedDate = rawDate.toDate() as DateTime?;
        } catch (_) {}
      }
    }

    return GameScore(
      uid: (d['uid'] as String?)?.isNotEmpty == true
          ? d['uid'] as String
          : docId,
      name: d['name'] as String? ?? 'Pengunjung',
      totalScore: (d['totalScore'] as num?)?.toInt() ?? 0,
      kanvasScore: (d['kanvasScore'] as num?)?.toInt() ?? 0,
      ttsScore: (d['ttsScore'] as num?)?.toInt() ?? 0,
      cocokScore: (d['cocokScore'] as num?)?.toInt() ?? 0,
      updatedAt: parsedDate,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'name': name,
        'totalScore': totalScore,
        'kanvasScore': kanvasScore,
        'ttsScore': ttsScore,
        'cocokScore': cocokScore,
      };

  GameScore copyWith({
    int? kanvasScore,
    int? ttsScore,
    int? cocokScore,
    DateTime? updatedAt,
  }) {
    final k = kanvasScore ?? this.kanvasScore;
    final t = ttsScore ?? this.ttsScore;
    final c = cocokScore ?? this.cocokScore;
    return GameScore(
      uid: uid,
      name: name,
      totalScore: k + t + c,
      kanvasScore: k,
      ttsScore: t,
      cocokScore: c,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

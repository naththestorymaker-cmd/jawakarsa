class KnowledgeFact {
  const KnowledgeFact({
    required this.key,
    required this.value,
  });

  final String key;
  final String value;

  factory KnowledgeFact.fromJson(Map<String, dynamic> json) {
    return KnowledgeFact(
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'value': value,
      };
}

class RelatedTopic {
  const RelatedTopic({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory RelatedTopic.fromJson(Map<String, dynamic> json) {
    return RelatedTopic(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
      };
}

class KnowledgeMedia {
  const KnowledgeMedia({
    required this.type,
    required this.url,
  });

  final String type;
  final String url;

  factory KnowledgeMedia.fromJson(Map<String, dynamic> json) {
    return KnowledgeMedia(
      type: json['type'] as String? ?? 'image',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'url': url,
      };
}

class KnowledgeItem {
  const KnowledgeItem({
    required this.id,
    required this.category,
    required this.title,
    required this.thumbnailUrl,
    required this.originRegion,
    required this.overview,
    required this.keyFacts,
    required this.relatedTopics,
    required this.media,
  });

  final String id;
  final String category;
  final String title;
  final String thumbnailUrl;
  final String originRegion;
  final String overview;
  final List<KnowledgeFact> keyFacts;
  final List<RelatedTopic> relatedTopics;
  final List<KnowledgeMedia> media;

  String get resolvedThumbnailUrl {
    final cleanPath = thumbnailUrl.replaceAll('\\', '/').trim();
    if (cleanPath.isNotEmpty) return cleanPath;

    switch (category.toUpperCase()) {
      case 'ARSITEKTUR & TATA RUANG':
        return 'assets/images/header/rumah_tradisional_joglo.webp';
      case 'MUSIK & LARAS TRADISIONAL':
        return 'assets/images/header/gamelan_slendro_pelog.webp';
      case 'SENI PERTUNJUKAN & SASTRA':
        return 'assets/images/header/wayang_kulit_purwa.webp';
      case 'KRIYA & FILOSOFI':
        return 'assets/images/header/keris.webp';
      case 'BUSANA & SIMBOLOGI':
        return 'assets/images/header/batik_parang_pedalaman.webp';
      case 'SEJARAH & TOKOH BANGSA':
        return 'assets/images/header/diponegoro.webp';
      case 'MITOLOGI & SPIRITUALITAS':
        return 'assets/images/header/wayang_kulit_purwa.webp';
      case 'RITUAL & UPACARA DAUR HIDUP':
        return 'assets/images/header/ruwatan_murwakala.webp';
      default:
        return 'assets/images/header/keris.webp';
    }
  }

  factory KnowledgeItem.fromJson(Map<String, dynamic> json) {
    return KnowledgeItem(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? 'BUDAYA JAWA',
      title: json['title'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      originRegion: json['origin_region'] as String? ?? 'Tanah Jawa',
      overview: json['overview'] as String? ?? '',
      keyFacts: (json['key_facts'] as List<dynamic>? ?? [])
          .map((e) => KnowledgeFact.fromJson(e as Map<String, dynamic>))
          .toList(),
      relatedTopics: (json['related_topics'] as List<dynamic>? ?? [])
          .map((e) => RelatedTopic.fromJson(e as Map<String, dynamic>))
          .toList(),
      media: (json['media'] as List<dynamic>? ?? [])
          .map((e) => KnowledgeMedia.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'title': title,
        'thumbnail_url': thumbnailUrl,
        'origin_region': originRegion,
        'overview': overview,
        'key_facts': keyFacts.map((e) => e.toJson()).toList(),
        'related_topics': relatedTopics.map((e) => e.toJson()).toList(),
        'media': media.map((e) => e.toJson()).toList(),
      };
}

String? extractYouTubeId(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return null;
  if (uri.host.contains('youtu.be')) {
    return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
  } else if (uri.host.contains('youtube.com')) {
    return uri.queryParameters['v'];
  }
  return null;
}
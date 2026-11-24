import 'package:flutter_test/flutter_test.dart';
import 'package:jawakarsa/data/knowledge_data.dart';
import 'package:jawakarsa/models/knowledge_item.dart';

void main() {
  group('Instant Knowledge Card dataset & search', () {
    final allItems = KnowledgeData.allItems;

    test('dataset size is within expected curated bounds', () {
      expect(allItems.length, greaterThanOrEqualTo(30));
      expect(allItems.length, lessThanOrEqualTo(55));
    });

    test('all items have unique IDs, valid fields, and valid related topics', () {
      final idSet = <String>{};
      for (final item in allItems) {
        expect(
          idSet.add(item.id),
          isTrue,
          reason: 'ID duplikat ditemukan: ${item.id}',
        );
        expect(item.title, isNotEmpty);
        expect(item.category, isNotEmpty);
        expect(item.overview.length, greaterThanOrEqualTo(50));
        expect(item.keyFacts, isNotEmpty);

        for (final rel in item.relatedTopics) {
          final target = KnowledgeData.findById(rel.id);
          expect(
            target,
            isNotNull,
            reason:
                'Related topic ID "${rel.id}" di item "${item.title}" tidak ditemukan',
          );
        }
      }
    });

    test(
      'local search finds Keris, Aji Saka, Ruwatan, and category filter',
      () {
        final kerisResults = KnowledgeData.search('Keris');
        expect(kerisResults, isNotEmpty);
        expect(kerisResults.any((e) => e.title.contains('Keris')), isTrue);

        final ajiSakaResults = KnowledgeData.search('Aji Saka');
        expect(ajiSakaResults, isNotEmpty);
        expect(ajiSakaResults.any((e) => e.title.contains('Aji Saka')), isTrue);

        final ruwatanResults = KnowledgeData.search('Ruwatan');
        expect(ruwatanResults, isNotEmpty);
        expect(ruwatanResults.any((e) => e.title.contains('Ruwatan')), isTrue);

        final kriyaFiltered = KnowledgeData.search(
          '',
          categoryFilter: 'KRIYA & FILOSOFI',
        );
        expect(kriyaFiltered, isNotEmpty);
        expect(
          kriyaFiltered.every((e) => e.category == 'KRIYA & FILOSOFI'),
          isTrue,
        );
      },
    );

    test('KnowledgeItem JSON serialization roundtrip preserves data', () {
      final sample = allItems.first;
      final reconstructed = KnowledgeItem.fromJson(sample.toJson());
      expect(reconstructed.id, sample.id);
      expect(reconstructed.title, sample.title);
      expect(reconstructed.keyFacts.length, sample.keyFacts.length);
      expect(reconstructed.relatedTopics.length, sample.relatedTopics.length);
    });
  });
}

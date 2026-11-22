import 'package:jawakarsa/data/knowledge_data.dart';
import 'package:jawakarsa/models/knowledge_item.dart';

void main() {
  print('=== MENJALANKAN UJI COBA INSTANT KNOWLEDGE CARD ===\n');

  final allItems = KnowledgeData.allItems;
  print('[TEST 1] Ukuran & Kelengkapan Dataset Lokal:');
  print('Jumlah total entri terdaftar: ${allItems.length}');
  assert(allItems.length >= 30, 'Dataset harus mencakup setidaknya 30 entri');
  assert(allItems.length <= 55, 'Dataset tidak boleh melebihi batas 55 entri');
  print('✓ Ukuran dataset valid (${allItems.length} entri terkurasi)');

  print('\n[TEST 2] Verifikasi Keunikan ID & Format Data:');
  final idSet = <String>{};
  for (final item in allItems) {
    assert(!idSet.contains(item.id), 'ID duplikat ditemukan: ${item.id}');
    idSet.add(item.id);
    assert(item.title.isNotEmpty, 'Judul tidak boleh kosong untuk ID: ${item.id}');
    assert(item.category.isNotEmpty, 'Kategori tidak boleh kosong untuk ID: ${item.id}');
    assert(item.overview.length >= 50, 'Overview harus mendalam (minimal 50 karakter) untuk: ${item.title}');
    assert(item.keyFacts.isNotEmpty, 'Key facts harus terisi untuk: ${item.title}');
  }
  print('✓ Seluruh ${allItems.length} entri memiliki ID unik dan data terstruktur valid');

  print('\n[TEST 3] Verifikasi Integritas Jalur Eksplorasi (Related Topics):');
  int totalLinks = 0;
  for (final item in allItems) {
    for (final rel in item.relatedTopics) {
      totalLinks++;
      final target = KnowledgeData.findById(rel.id);
      assert(target != null,
          'Related topic ID "${rel.id}" di item "${item.title}" tidak ditemukan di database!');
    }
  }
  print('✓ Seluruh $totalLinks relasi related topics terhubung silang dengan valid');

  print('\n[TEST 4] Pengujian Pencarian Lokal:');
  final kerisResults = KnowledgeData.search('Keris');
  assert(kerisResults.isNotEmpty, 'Pencarian "Keris" harus menghasilkan entri');
  assert(kerisResults.any((e) => e.title.contains('Keris')), 'Hasil harus memuat Keris & Tosan Aji');
  print('✓ Pencarian "Keris": ${kerisResults.length} hasil ditemukan');

  final ajiSakaResults = KnowledgeData.search('Aji Saka');
  assert(ajiSakaResults.isNotEmpty, 'Pencarian "Aji Saka" harus menghasilkan entri');
  assert(ajiSakaResults.any((e) => e.title.contains('Aji Saka')), 'Hasil harus memuat Aji Saka & Aksara Jawa');
  print('✓ Pencarian "Aji Saka": ${ajiSakaResults.length} hasil ditemukan');

  final ruwatanResults = KnowledgeData.search('Ruwatan');
  assert(ruwatanResults.isNotEmpty, 'Pencarian "Ruwatan" harus menghasilkan entri');
  assert(ruwatanResults.any((e) => e.title.contains('Ruwatan')), 'Hasil harus memuat Ruwatan Murwakala');
  print('✓ Pencarian "Ruwatan": ${ruwatanResults.length} hasil ditemukan');

  final kriyaFiltered = KnowledgeData.search('', categoryFilter: 'KRIYA & FILOSOFI');
  assert(kriyaFiltered.isNotEmpty, 'Filter kategori harus menghasilkan entri');
  assert(kriyaFiltered.every((e) => e.category == 'KRIYA & FILOSOFI'),
      'Semua hasil harus berkategori KRIYA & FILOSOFI');
  print('✓ Filter kategori KRIYA & FILOSOFI: ${kriyaFiltered.length} entri');

  print('\n[TEST 5] Pengujian Serialization & Deserialization:');
  final sample = allItems.first;
  final jsonMap = sample.toJson();
  final reconstructed = KnowledgeItem.fromJson(jsonMap);
  assert(reconstructed.id == sample.id);
  assert(reconstructed.title == sample.title);
  assert(reconstructed.keyFacts.length == sample.keyFacts.length);
  assert(reconstructed.relatedTopics.length == sample.relatedTopics.length);
  print('✓ Roundtrip JSON serialization/deserialization valid');

  print('\n=====================================================');
  print('=== SEMUA UJI COBA KNOWLEDGE CARD 100% SUKSES     ===');
  print('=====================================================');
}


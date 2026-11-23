import 'package:flutter/material.dart';
import 'package:jawakarsa/core/app_colors.dart';

class FactItem {
  const FactItem({
    required this.category,
    required this.question,
    required this.answer,
    required this.accentColor,
  });

  final String category;
  final String question;
  final String answer;
  final Color accentColor;
}

const List<FactItem> allFacts = [
  FactItem(
    category: 'Kuliner',
    accentColor: AppColors.rubyRed,
    question: 'Makanan apa yang namanya lahir dari pertanyaan "Ini apa?"',
    answer:
        'Kipo! Jajanan mungil khas Kotagede, Yogyakarta. Namanya berasal dari ungkapan Jawa "iki opo?" karena orang-orang penasaran dengan bentuknya yang unik.',
  ),
  FactItem(
    category: 'Bahasa',
    accentColor: AppColors.mallardish,
    question:
        'Mengapa penutur asli Jawa pun bisa salah menggunakan tingkatan bahasanya sendiri?',
    answer:
        'Kosakata Krama tidak sekadar versi "halus" dari Ngoko. Banyak kata Krama punya bentuk dan makna yang sama sekali berbeda, sehingga penutur yang jarang menggunakannya sering tertukar.',
  ),
  FactItem(
    category: 'Batik',
    accentColor: AppColors.goldVarnishBrown,
    question: 'Bisakah motif batik "berbicara" soal status sosial pemakainya?',
    answer:
        'Ya! Dalam tradisi keraton Jawa, pola dan warna batik tertentu berfungsi sebagai kode sosial — memberi petunjuk tentang asal daerah, kesempatan pemakaian, bahkan derajat pemakainya.',
  ),
  FactItem(
    category: 'Wayang',
    accentColor: AppColors.rubyRed,
    question:
        'Apakah semua wayang Jawa bercerita tentang Mahabharata atau Ramayana?',
    answer:
        'Tidak. Wayang Gedhog mengangkat cerita Panji, sementara Wayang Krucil menceritakan Damarwulan. Dunia wayang Jawa punya kisah-kisah lokal yang kaya di luar dua wiracarita besar itu.',
  ),
  FactItem(
    category: 'Batik',
    accentColor: AppColors.goldVarnishBrown,
    question:
        'Benarkah motif Parang dulunya dilarang dipakai sembarangan orang?',
    answer:
        'Benar. Motif Parang secara adat hanya boleh dikenakan keluarga kerajaan Jawa. Meski kini aturannya sudah longgar, di lingkungan keraton pantangan itu masih tetap dijaga.',
  ),
  FactItem(
    category: 'Arsitektur',
    accentColor: AppColors.mallardish,
    question:
        'Ruang manakah di rumah Jawa tradisional yang paling "angker" sekaligus sakral?',
    answer:
        'Senthong tengah. Ruang tersembunyi ini dikaitkan dengan Dewi Sri, dewi padi, dan sering digunakan untuk menyimpan benda-benda yang dianggap keramat atau benih padi pilihan.',
  ),
  FactItem(
    category: 'Kuliner',
    accentColor: AppColors.rubyRed,
    question: 'Dari mana asal kata "Gudeg", makanan ikonik Yogyakarta?',
    answer:
        'Dari kata "hangudeg" dalam bahasa Jawa, artinya mengaduk. Merujuk pada proses memasak nangka muda yang harus diaduk terus-menerus selama berjam-jam hingga matang sempurna.',
  ),
  FactItem(
    category: 'Bahasa',
    accentColor: AppColors.mallardish,
    question: 'Apakah aksara Jawa (Hanacaraka) masih diajarkan di sekolah?',
    answer:
        'Ya, terutama di Jawa Tengah dan Yogyakarta sebagai muatan lokal wajib. Aksara ini memiliki 20 huruf dasar dengan sistem pasangan dan sandangan yang unik.',
  ),
  FactItem(
    category: 'Wayang',
    accentColor: AppColors.rubyRed,
    question:
        'Kenapa dalang wayang kulit bisa memainkan ratusan karakter sendirian?',
    answer:
        'Dalang menghafal ratusan karakter dengan "antawacana" — seni perbedaan suara dan dialog khas tiap tokoh. Latihan sejak kecil bisa memakan waktu belasan tahun untuk benar-benar mahir.',
  ),
  FactItem(
    category: 'Arsitektur',
    accentColor: AppColors.mallardish,
    question: 'Mengapa atap Joglo berbentuk menjulang tinggi di tengahnya?',
    answer:
        'Puncak Joglo (tumpang sari) yang tinggi melambangkan gunung suci, tempat bersemayamnya para dewa. Semakin banyak susunan tumpangnya, semakin tinggi status pemilik rumah.',
  ),
];

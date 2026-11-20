enum PasanganPosition {
  sejajar('Sejajar (Di Kanan Aksara Mati)'),
  bawah('Menggantung (Di Bawah Aksara Mati)'),
  bawahNaik('Di Bawah & Melengkung Naik');

  const PasanganPosition(this.description);
  final String description;
}

class AksaraItem {
  const AksaraItem({
    required this.index,
    required this.carakan,
    required this.pasanganChar,
    required this.latinCarakan,
    required this.latinPasangan,
    required this.pasanganPosition,
    required this.barisTitle,
    required this.barisMeaning,
    required this.exampleAksara,
    required this.exampleLatin,
    required this.exampleMeaning,
  });

  final int index;
  final String carakan;
  final String pasanganChar;
  final String latinCarakan;
  final String latinPasangan;
  final PasanganPosition pasanganPosition;
  final String barisTitle;
  final String barisMeaning;
  final String exampleAksara;
  final String exampleLatin;
  final String exampleMeaning;

  /// Merender wujud pasangan murni menggunakan Non-Breaking Space + Pangkon + Carakan
  /// agar mesin OpenType (HarfBuzz) menampilkan bentuk Pasangan tanpa lingkaran putus-putus.
  String get pasanganDisplay => '\u00A0\uA9C0$pasanganChar';

  /// Contoh penggunaan pasangan dalam rangkaian aksara (misal: ꦤ + ꧀ + aksara)
  String get pasanganInContext => 'ꦤ\uA9C0$pasanganChar';
}

const List<AksaraItem> hanacarakaList = [
  // ── BARIS 1: HANA CARAKA ("Ada utusan") ──────────────────────────────────
  AksaraItem(
    index: 1,
    carakan: 'ꦲ',
    pasanganChar: 'ꦲ',
    latinCarakan: 'ha',
    latinPasangan: 'h',
    pasanganPosition: PasanganPosition.sejajar,
    barisTitle: 'Hana Caraka',
    barisMeaning: 'Ada utusan (kehidupan/napas yang diamanahkan)',
    exampleAksara: 'ꦲꦠꦶ',
    exampleLatin: 'hati',
    exampleMeaning: 'Kalbu / Perasaan',
  ),
  AksaraItem(
    index: 2,
    carakan: 'ꦤ',
    pasanganChar: 'ꦤ',
    latinCarakan: 'na',
    latinPasangan: 'n',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Hana Caraka',
    barisMeaning: 'Ada utusan (kehidupan/napas yang diamanahkan)',
    exampleAksara: 'ꦤꦒꦫ',
    exampleLatin: 'nagara',
    exampleMeaning: 'Negara / Kerajaan',
  ),
  AksaraItem(
    index: 3,
    carakan: 'ꦕ',
    pasanganChar: 'ꦕ',
    latinCarakan: 'ca',
    latinPasangan: 'c',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Hana Caraka',
    barisMeaning: 'Ada utusan (kehidupan/napas yang diamanahkan)',
    exampleAksara: 'ꦕꦪ',
    exampleLatin: 'caya',
    exampleMeaning: 'Cahaya / Sinar',
  ),
  AksaraItem(
    index: 4,
    carakan: 'ꦫ',
    pasanganChar: 'ꦫ',
    latinCarakan: 'ra',
    latinPasangan: 'r',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Hana Caraka',
    barisMeaning: 'Ada utusan (kehidupan/napas yang diamanahkan)',
    exampleAksara: 'ꦫꦱ',
    exampleLatin: 'rasa',
    exampleMeaning: 'Rasa / Olah batin',
  ),
  AksaraItem(
    index: 5,
    carakan: 'ꦏ',
    pasanganChar: 'ꦏ',
    latinCarakan: 'ka',
    latinPasangan: 'k',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Hana Caraka',
    barisMeaning: 'Ada utusan (kehidupan/napas yang diamanahkan)',
    exampleAksara: 'ꦏꦂꦱ',
    exampleLatin: 'karsa',
    exampleMeaning: 'Kehendak / Niat luhur',
  ),

  // ── BARIS 2: DATA SAWALA ("Saling berselisih") ───────────────────────────
  AksaraItem(
    index: 6,
    carakan: 'ꦢ',
    pasanganChar: 'ꦢ',
    latinCarakan: 'da',
    latinPasangan: 'd',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Data Sawala',
    barisMeaning: 'Saling berselisih dalam mempertahankan amanah',
    exampleAksara: 'ꦢꦭꦤ꧀',
    exampleLatin: 'dalan',
    exampleMeaning: 'Jalan kehidupan',
  ),
  AksaraItem(
    index: 7,
    carakan: 'ꦠ',
    pasanganChar: 'ꦠ',
    latinCarakan: 'ta',
    latinPasangan: 't',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Data Sawala',
    barisMeaning: 'Saling berselisih dalam mempertahankan amanah',
    exampleAksara: 'ꦠꦩꦤ꧀',
    exampleLatin: 'taman',
    exampleMeaning: 'Taman keasrian',
  ),
  AksaraItem(
    index: 8,
    carakan: 'ꦱ',
    pasanganChar: 'ꦱ',
    latinCarakan: 'sa',
    latinPasangan: 's',
    pasanganPosition: PasanganPosition.sejajar,
    barisTitle: 'Data Sawala',
    barisMeaning: 'Saling berselisih dalam mempertahankan amanah',
    exampleAksara: 'ꦱꦸꦂꦪ',
    exampleLatin: 'surya',
    exampleMeaning: 'Matahari',
  ),
  AksaraItem(
    index: 9,
    carakan: 'ꦮ',
    pasanganChar: 'ꦮ',
    latinCarakan: 'wa',
    latinPasangan: 'w',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Data Sawala',
    barisMeaning: 'Saling berselisih dalam mempertahankan amanah',
    exampleAksara: 'ꦮꦪꦁ',
    exampleLatin: 'wayang',
    exampleMeaning: 'Bayangan kehidupan',
  ),
  AksaraItem(
    index: 10,
    carakan: 'ꦭ',
    pasanganChar: 'ꦭ',
    latinCarakan: 'la',
    latinPasangan: 'l',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Data Sawala',
    barisMeaning: 'Saling berselisih dalam mempertahankan amanah',
    exampleAksara: 'ꦭꦏꦸ',
    exampleLatin: 'laku',
    exampleMeaning: 'Perilaku / Tirakat',
  ),

  // ── BARIS 3: PADHA JAYANYA ("Sama digdayanya") ───────────────────────────
  AksaraItem(
    index: 11,
    carakan: 'ꦥ',
    pasanganChar: 'ꦥ',
    latinCarakan: 'pa',
    latinPasangan: 'p',
    pasanganPosition: PasanganPosition.sejajar,
    barisTitle: 'Padha Jayanya',
    barisMeaning: 'Sama-sama kuat dan teguh memegang prinsip',
    exampleAksara: 'ꦥꦢ',
    exampleLatin: 'pada',
    exampleMeaning: 'Setara / Bait tembang',
  ),
  AksaraItem(
    index: 12,
    carakan: 'ꦝ',
    pasanganChar: 'ꦝ',
    latinCarakan: 'dha',
    latinPasangan: 'dh',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Padha Jayanya',
    barisMeaning: 'Sama-sama kuat dan teguh memegang prinsip',
    exampleAksara: 'ꦝꦝ',
    exampleLatin: 'dhadha',
    exampleMeaning: 'Dada / Kelapangan hati',
  ),
  AksaraItem(
    index: 13,
    carakan: 'ꦗ',
    pasanganChar: 'ꦗ',
    latinCarakan: 'ja',
    latinPasangan: 'j',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Padha Jayanya',
    barisMeaning: 'Sama-sama kuat dan teguh memegang prinsip',
    exampleAksara: 'ꦗꦮ',
    exampleLatin: 'jawa',
    exampleMeaning: 'Tanah Jawa / Mengerti',
  ),
  AksaraItem(
    index: 14,
    carakan: 'ꦪ',
    pasanganChar: 'ꦪ',
    latinCarakan: 'ya',
    latinPasangan: 'y',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Padha Jayanya',
    barisMeaning: 'Sama-sama kuat dan teguh memegang prinsip',
    exampleAksara: 'ꦪꦸꦏ꧀ꦠꦶ',
    exampleLatin: 'yukti',
    exampleMeaning: 'Kebenaran sejati',
  ),
  AksaraItem(
    index: 15,
    carakan: 'ꦚ',
    pasanganChar: 'ꦚ',
    latinCarakan: 'nya',
    latinPasangan: 'ny',
    pasanganPosition: PasanganPosition.bawahNaik,
    barisTitle: 'Padha Jayanya',
    barisMeaning: 'Sama-sama kuat dan teguh memegang prinsip',
    exampleAksara: 'ꦚꦠ',
    exampleLatin: 'nyata',
    exampleMeaning: 'Nyata / Kebenaran',
  ),

  // ── BARIS 4: MAGA BATHANGA ("Inilah jasadnya") ───────────────────────────
  AksaraItem(
    index: 16,
    carakan: 'ꦩ',
    pasanganChar: 'ꦩ',
    latinCarakan: 'ma',
    latinPasangan: 'm',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Maga Bathanga',
    barisMeaning: 'Kembali ke pangkuan Sang Pencipta dalam kepasrahan',
    exampleAksara: 'ꦩꦠ',
    exampleLatin: 'mata',
    exampleMeaning: 'Mata / Pandangan batin',
  ),
  AksaraItem(
    index: 17,
    carakan: 'ꦒ',
    pasanganChar: 'ꦒ',
    latinCarakan: 'ga',
    latinPasangan: 'g',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Maga Bathanga',
    barisMeaning: 'Kembali ke pangkuan Sang Pencipta dalam kepasrahan',
    exampleAksara: 'ꦒꦸꦫꦸ',
    exampleLatin: 'guru',
    exampleMeaning: 'Pendidik / Digugu lan ditiru',
  ),
  AksaraItem(
    index: 18,
    carakan: 'ꦧ',
    pasanganChar: 'ꦧ',
    latinCarakan: 'ba',
    latinPasangan: 'b',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Maga Bathanga',
    barisMeaning: 'Kembali ke pangkuan Sang Pencipta dalam kepasrahan',
    exampleAksara: 'ꦧꦱ',
    exampleLatin: 'basa',
    exampleMeaning: 'Bahasa / Tata krama',
  ),
  AksaraItem(
    index: 19,
    carakan: 'ꦛ',
    pasanganChar: 'ꦛ',
    latinCarakan: 'tha',
    latinPasangan: 'th',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Maga Bathanga',
    barisMeaning: 'Kembali ke pangkuan Sang Pencipta dalam kepasrahan',
    exampleAksara: 'ꦛꦸꦏꦸꦭ꧀',
    exampleLatin: 'thukul',
    exampleMeaning: 'Tumbuh bersemi',
  ),
  AksaraItem(
    index: 20,
    carakan: 'ꦔ',
    pasanganChar: 'ꦔ',
    latinCarakan: 'nga',
    latinPasangan: 'ng',
    pasanganPosition: PasanganPosition.bawah,
    barisTitle: 'Maga Bathanga',
    barisMeaning: 'Kembali ke pangkuan Sang Pencipta dalam kepasrahan',
    exampleAksara: 'ꦔꦪꦺꦴꦒꦾ',
    exampleLatin: 'ngayogya',
    exampleMeaning: 'Indah / Damai sejahtera',
  ),
];

/// Mesin transliterasi otomatis Latin ke Aksara Jawa (Unicode U+A980..U+A9DF).
/// Mendukung konsonan rangkap (ng, ny, dh, th, kh, sy), cakra (-r-), pengkal (-y-),
/// sandhangan swara (i, u, e, é, o), panyigeg wanda (-ng, -r, -h), pasangan otomatis,
/// dan angka Jawa.
class AksaraTransliterator {
  AksaraTransliterator._();

  static const Map<String, String> _consonantMap = {
    'ny': 'ꦚ',
    'ng': 'ꦔ',
    'dh': 'ꦝ',
    'th': 'ꦛ',
    'kh': 'ꦏ꦳',
    'sy': 'ꦱ꦳',
    'dz': 'ꦢ꦳',
    'h': 'ꦲ',
    'n': 'ꦤ',
    'c': 'ꦕ',
    'r': 'ꦫ',
    'k': 'ꦏ',
    'q': 'ꦏ',
    'd': 'ꦢ',
    't': 'ꦠ',
    's': 'ꦱ',
    'w': 'ꦮ',
    'l': 'ꦭ',
    'p': 'ꦥ',
    'f': 'ꦥ꦳',
    'v': 'ꦥ꦳',
    'j': 'ꦗ',
    'z': 'ꦗ꦳',
    'y': 'ꦪ',
    'm': 'ꦩ',
    'g': 'ꦒ',
    'b': 'ꦧ',
  };

  static const Map<String, String> _vowelSignMap = {
    'a': '',
    'i': 'ꦶ',
    'u': 'ꦸ',
    'e': 'ꦼ',
    'é': 'ꦺ',
    'è': 'ꦺ',
    'o': 'ꦺꦴ',
  };

  static const Map<String, String> _digitMap = {
    '0': '꧐',
    '1': '꧑',
    '2': '꧒',
    '3': '꧓',
    '4': '꧔',
    '5': '꧕',
    '6': '꧖',
    '7': '꧗',
    '8': '꧘',
    '9': '꧙',
  };

  static bool _isVowel(String ch) =>
      ch == 'a' ||
      ch == 'i' ||
      ch == 'u' ||
      ch == 'e' ||
      ch == 'é' ||
      ch == 'è' ||
      ch == 'o';

  /// Mengonversi teks Latin menjadi Aksara Jawa secara real-time.
  static String toJavanese(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';

    final words = trimmed.split(RegExp(r'\s+'));
    final convertedWords = words.map(_convertWord).where((w) => w.isNotEmpty);
    return convertedWords.join(' ');
  }

  static String _convertWord(String rawWord) {
    // Normalisasi huruf kecil dan ganti 'x' -> 'ks'
    final s = rawWord
        .toLowerCase()
        .replaceAll('x', 'ks')
        .replaceAll(RegExp(r'[^a-z0-9éè]'), '');
    if (s.isEmpty) return '';

    final buf = StringBuffer();
    int i = 0;
    final len = s.length;
    bool openConsonant = false; // Apakah baru saja menulis konsonan tanpa vokal

    while (i < len) {
      final ch = s[i];

      // 1. Angka
      if (_digitMap.containsKey(ch)) {
        if (openConsonant) {
          buf.write('꧀');
          openConsonant = false;
        }
        buf.write(_digitMap[ch]);
        i++;
        continue;
      }

      // 2. Vokal mandiri (di awal kata atau setelah vokal lain)
      if (_isVowel(ch)) {
        if (openConsonant) {
          // Tempelkan sandhangan vokal pada konsonan sebelumnya
          buf.write(_vowelSignMap[ch] ?? '');
          openConsonant = false;
        } else {
          // Vokal di awal suku kata -> gunakan 'ha' (ꦲ) + sandhangan
          buf.write('ꦲ');
          buf.write(_vowelSignMap[ch] ?? '');
        }
        i++;
        continue;
      }

      // 3. Cek konsonan digraf (2 huruf: ng, ny, dh, th, kh, sy, dz)
      String? token;
      int tokenLen = 1;
      if (i + 1 < len) {
        final pair = s.substring(i, i + 2);
        if (_consonantMap.containsKey(pair)) {
          token = pair;
          tokenLen = 2;
        }
      }
      token ??= _consonantMap.containsKey(ch) ? ch : null;

      if (token == null) {
        i++;
        continue;
      }

      final nextIdx = i + tokenLen;
      final hasNext = nextIdx < len;
      final nextChar = hasNext ? s[nextIdx] : '';

      // Cek apakah konsonan ini merupakan penutup suku kata (panyigeging wanda: -ng, -r, -h)
      // Syarat: tidak diikuti oleh vokal (di akhir kata atau diikuti konsonan lain)
      final followedByVowel = hasNext && _isVowel(nextChar);

      if (!followedByVowel) {
        // Apabila sebelumnya masih ada konsonan terbuka (tanpa vokal), beri vokal bawaan 'a'
        // kecuali kita sedang berada di kluster konsonan.
        if (token == 'ng' && !openConsonant) {
          buf.write('ꦁ'); // Cecak (-ng)
          i += tokenLen;
          continue;
        }
        if (token == 'r' && !openConsonant) {
          buf.write('ꦂ'); // Layar (-r)
          i += tokenLen;
          continue;
        }
        if (token == 'h' && !openConsonant) {
          buf.write('ꦃ'); // Wignyan (-h)
          i += tokenLen;
          continue;
        }
      }

      // Cek sandhangan wyanjana (Cakra '-r-' atau Pengkal '-y-') setelah konsonan terbuka
      if (openConsonant && followedByVowel) {
        if (token == 'r') {
          buf.write('ꦿ'); // Cakra
          buf.write(_vowelSignMap[nextChar] ?? '');
          openConsonant = false;
          i = nextIdx + 1;
          continue;
        }
        if (token == 'y') {
          buf.write('ꦾ'); // Pengkal
          buf.write(_vowelSignMap[nextChar] ?? '');
          openConsonant = false;
          i = nextIdx + 1;
          continue;
        }
      }

      // Jika konsonan sebelumnya belum mendapat vokal, matikan dengan Pangkon (꧀)
      // sehingga konsonan sekarang otomatis berubah menjadi Pasangan!
      if (openConsonant) {
        buf.write('꧀');
        openConsonant = false;
      }

      // Tulis aksara konsonan sekarang
      buf.write(_consonantMap[token]);
      openConsonant = true;
      i += tokenLen;
    }

    // Jika di akhir kata masih ada konsonan mati (selain ng, r, h yang sudah jadi panyigeg)
    if (openConsonant) {
      buf.write('꧀');
    }

    return buf.toString();
  }
}

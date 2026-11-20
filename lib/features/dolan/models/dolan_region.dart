import 'package:flutter/material.dart';

enum DolanCategory {
  sejarah('Cagar Sejarah & Museum', Icons.account_balance_rounded),
  kuliner('Kuliner Tradisional Khas', Icons.restaurant_rounded),
  wisata('Destinasi Wisata Populer', Icons.landscape_rounded);

  const DolanCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

class DolanPlace {
  const DolanPlace({
    required this.name,
    required this.category,
    required this.location,
    required this.description,
    required this.mapsQuery,
    this.rating = 4.8,
  });

  final String name;
  final DolanCategory category;
  final String location;
  final String description;
  final String mapsQuery;
  final double rating;

  String get googleMapsUrl {
    final encoded = Uri.encodeComponent(mapsQuery);
    return 'https://www.google.com/maps/search/?api=1&query=$encoded';
  }
}

class DolanRegion {
  const DolanRegion({
    required this.id,
    required this.name,
    required this.nickname,
    required this.capital,
    required this.places,
  });

  final int id;
  final String name;
  final String nickname;
  final String capital;
  final List<DolanPlace> places;

  List<DolanPlace> getPlacesByCategory(DolanCategory category) {
    return places.where((p) => p.category == category).toList();
  }
}

const List<DolanRegion> dolanRegions = [
  // 1. BANTEN
  DolanRegion(
    id: 1,
    name: 'Banten',
    nickname: 'Tanah Para Jawara & Kesultanan Bahari',
    capital: 'Serang',
    places: [
      DolanPlace(
        name: 'Keraton Kaibon & Benteng Speelwijk',
        category: DolanCategory.sejarah,
        location: 'Kasemen, Kota Serang, Banten',
        description: 'Sisa kemegahan Kesultanan Banten abad ke-19 yang dikelilingi kanal air dan benteng bersejarah VOC.',
        mapsQuery: 'Keraton Kaibon Banten Lama',
        rating: 4.7,
      ),
      DolanPlace(
        name: 'Museum Situs Kepurbakalaan Banten',
        category: DolanCategory.sejarah,
        location: 'Kawasan Banten Lama, Kota Serang',
        description: 'Menyimpan ribuan artefak keramik Dinasti Ming, senjata tradisional, dan mata uang kuno Banten.',
        mapsQuery: 'Museum Situs Kepurbakalaan Banten Lama',
        rating: 4.6,
      ),
      DolanPlace(
        name: 'Sate Bandeng Ibu Amenah',
        category: DolanCategory.kuliner,
        location: 'Jl. Ki Masjong No. 22, Kota Serang',
        description: 'Kuliner khas raja Banten berupa olahan daging bandeng tanpa duri berpadu rempah santan gurih.',
        mapsQuery: 'Sate Bandeng Ibu Amenah Serang',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Rabeg Khas Banten H. Naswi',
        category: DolanCategory.kuliner,
        location: 'Magersari, Kota Serang, Banten',
        description: 'Semur kambing aromatik dengan rempah pala, kayu manis, dan cabai rawit warisan Sultan Maulana Hasanuddin.',
        mapsQuery: 'Rabeg Khas Banten H Naswi Serang',
        rating: 4.7,
      ),
      DolanPlace(
        name: 'Taman Nasional Ujung Kulon',
        category: DolanCategory.wisata,
        location: 'Kec. Sumur, Kabupaten Pandeglang',
        description: 'Situs Warisan Dunia UNESCO habitat badak Jawa bercula satu dengan pantai perawan dan hutan tropis.',
        mapsQuery: 'Taman Nasional Ujung Kulon Pandeglang',
        rating: 4.9,
      ),
      DolanPlace(
        name: 'Kampung Adat Baduy Luar',
        category: DolanCategory.wisata,
        location: 'Kanekes, Leuwidamar, Lebak, Banten',
        description: 'Wisata budaya kearifan lokal suku Baduy yang menjaga kelestarian alam dan menolak modernisasi berlebih.',
        mapsQuery: 'Desa Adat Kanekes Baduy Lebak',
        rating: 4.9,
      ),
    ],
  ),

  // 2. DKI JAKARTA
  DolanRegion(
    id: 2,
    name: 'DKI Jakarta',
    nickname: 'Ibu Kota Bersejarah & Muara Budaya Betawi',
    capital: 'Jakarta Pusat',
    places: [
      DolanPlace(
        name: 'Museum Sejarah Jakarta (Fatahillah)',
        category: DolanCategory.sejarah,
        location: 'Kawasan Kota Tua, Jakarta Barat',
        description: 'Gedung bekas Balai Kota Batavia abad ke-18 yang menyimpan sejarah kota Jakarta dan penjara bawah tanah.',
        mapsQuery: 'Museum Fatahillah Kota Tua Jakarta',
        rating: 4.7,
      ),
      DolanPlace(
        name: 'Pelabuhan Sunda Kelapa',
        category: DolanCategory.sejarah,
        location: 'Penjaringan, Jakarta Utara',
        description: 'Pelabuhan tua berusia lebih dari 800 tahun tempat sandar perahu layar tradisional Phinisi Bugis.',
        mapsQuery: 'Pelabuhan Sunda Kelapa Jakarta Utara',
        rating: 4.6,
      ),
      DolanPlace(
        name: 'Kerak Telor Bang Sape\'i',
        category: DolanCategory.kuliner,
        location: 'Kawasan Monas & Setu Babakan, Jakarta',
        description: 'Kuliner ikonik Betawi dari beras ketan, telur bebek, ebi sangrai, dan serundeng kelapa gurih.',
        mapsQuery: 'Kerak Telor Betawi Setu Babakan',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Soto Betawi H. Husein Manggarai',
        category: DolanCategory.kuliner,
        location: 'Jl. Padang Panjang No. 6B, Jakarta Selatan',
        description: 'Soto kuah santan dan susu legendaris dengan potongan daging sapi empuk serta emping renyah.',
        mapsQuery: 'Soto Betawi H Husein Manggarai',
        rating: 4.9,
      ),
      DolanPlace(
        name: 'Perkampungan Budaya Betawi Setu Babakan',
        category: DolanCategory.wisata,
        location: 'Srengseng Sawah, Jagakarsa, Jakarta Selatan',
        description: 'Cagar budaya Betawi tepi danau tempat mempelajari tari topeng, rumah kebaya, dan membuat bir pletok.',
        mapsQuery: 'Setu Babakan Pusat Budaya Betawi Jakarta Selatan',
        rating: 4.7,
      ),
      DolanPlace(
        name: 'Taman Mini Indonesia Indah (TMII)',
        category: DolanCategory.wisata,
        location: 'Cipayung, Jakarta Timur',
        description: 'Taman rekreasi budaya seluas 150 hektar yang merangkum anjungan rumah adat 38 provinsi di Indonesia.',
        mapsQuery: 'Taman Mini Indonesia Indah TMII',
        rating: 4.8,
      ),
    ],
  ),

  // 3. JAWA BARAT
  DolanRegion(
    id: 3,
    name: 'Jawa Barat',
    nickname: 'Bumi Parahyangan & Tatar Pasundan Nan Asri',
    capital: 'Bandung',
    places: [
      DolanPlace(
        name: 'Gedung Sate Bandung',
        category: DolanCategory.sejarah,
        location: 'Jl. Diponegoro No. 22, Citarum, Bandung',
        description: 'Ikon arsitektur neo-klasik bercampur elemen lokal yang dibangun tahun 1920 dengan museum interaktif.',
        mapsQuery: 'Gedung Sate Bandung',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Keraton Kasepuhan Cirebon',
        category: DolanCategory.sejarah,
        location: 'Jl. Kasepuhan No. 43, Lemahwungkuk, Cirebon',
        description: 'Keraton tertua di Cirebon didirikan 1445 oleh Pangeran Cakrabuana dengan kereta kencana legendaris Singa Barwang.',
        mapsQuery: 'Keraton Kasepuhan Cirebon',
        rating: 4.7,
      ),
      DolanPlace(
        name: 'Nasi Jamblang Mang Dul',
        category: DolanCategory.kuliner,
        location: 'Jl. DR. Cipto Mangunkusumo No. 8, Cirebon',
        description: 'Nasi pulen beralas daun jati khas Cirebon dengan puluhan lauk seperti sotong hitam, semur lidah, dan perkedel.',
        mapsQuery: 'Nasi Jamblang Mang Dul Cirebon',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Batagor Riri Bandung',
        category: DolanCategory.kuliner,
        location: 'Jl. Burangrang No. 41, Malabar, Bandung',
        description: 'Bakso tahu goreng ikan tenggiri renyah berpadu saus kacang gurih pedas dan kucuran jeruk limau.',
        mapsQuery: 'Batagor Riri Burangrang Bandung',
        rating: 4.7,
      ),
      DolanPlace(
        name: 'Kawah Putih Ciwidey',
        category: DolanCategory.wisata,
        location: 'Sugihmukti, Pasirjambu, Bandung',
        description: 'Danau kawah vulkanik berwarna putih kehijauan yang eksotis di ketinggian 2.434 mdpl.',
        mapsQuery: 'Kawah Putih Ciwidey Bandung',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Little Venice Puncak',
        category: DolanCategory.wisata,
        location: 'Batulawang, Cipanas, Cianjur, Jawa Barat',
        description: 'Objek wisata kanal ala Venesia di pegunungan sejuk tanah Jawa dengan wahana gondola.',
        mapsQuery: 'Little Venice Puncak Cianjur',
        rating: 4.6,
      ),
    ],
  ),

  // 4. JAWA TENGAH
  DolanRegion(
    id: 4,
    name: 'Jawa Tengah',
    nickname: 'Jantung Kebudayaan & Mahakarya Candi Luhur',
    capital: 'Semarang',
    places: [
      DolanPlace(
        name: 'Candi Borobudur',
        category: DolanCategory.sejarah,
        location: 'Borobudur, Magelang, Jawa Tengah',
        description: 'Candi Buddha terbesar di dunia abad ke-8 peninggalan Dinasti Syailendra, situs Warisan Dunia UNESCO.',
        mapsQuery: 'Candi Borobudur Magelang',
        rating: 4.9,
      ),
      DolanPlace(
        name: 'Lawang Sewu Semarang',
        category: DolanCategory.sejarah,
        location: 'Jl. Pemuda No. 160, Sekayu, Kota Semarang',
        description: 'Gedung bersejarah megah era kolonial berarsitektur seribu pintu bekas kantor pusat NIS (Kereta Api Hindia Belanda).',
        mapsQuery: 'Lawang Sewu Semarang',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Lumpia Semarang Gang Lombok No. 11',
        category: DolanCategory.kuliner,
        location: 'Gang Lombok No. 11, Purwodinatan, Semarang',
        description: 'Kedai lumpia tertua di Semarang sejak 1870 dengan isian rebung manis gurih, udang, dan telur.',
        mapsQuery: 'Lumpia Gang Lombok No 11 Semarang',
        rating: 4.9,
      ),
      DolanPlace(
        name: 'Nasi Liwet Wongso Lemu Solo',
        category: DolanCategory.kuliner,
        location: 'Jl. Teuku Umar, Keprabon, Banjarsari, Surakarta',
        description: 'Nasi gurih masak santan disajikan di atas pincuk daun pisang dengan sayur labu siam dan areh santan kental.',
        mapsQuery: 'Nasi Liwet Wongso Lemu Solo',
        rating: 4.7,
      ),
      DolanPlace(
        name: 'Dataran Tinggi Dieng & Telaga Warna',
        category: DolanCategory.wisata,
        location: 'Kejajar, Kabupaten Wonosobo, Jawa Tengah',
        description: 'Negeri di atas awan dengan kawah aktif Sikidang, telaga warna-warni, serta kompleks candi Hindu tertua di Jawa.',
        mapsQuery: 'Telaga Warna Dataran Tinggi Dieng Wonosobo',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Taman Nasional Karimunjawa',
        category: DolanCategory.wisata,
        location: 'Kepulauan Karimunjawa, Jepara, Jawa Tengah',
        description: 'Gugusan pulau surga bahari di Laut Jawa dengan terumbu karang indah, penangkaran hiu, dan pantai pasir putih.',
        mapsQuery: 'Karimunjawa Jepara Jawa Tengah',
        rating: 4.9,
      ),
    ],
  ),

  // 5. D.I. YOGYAKARTA
  DolanRegion(
    id: 5,
    name: 'D.I. Yogyakarta',
    nickname: 'Kota Pelajar, Kasultanan & Keraton Mataram',
    capital: 'Yogyakarta',
    places: [
      DolanPlace(
        name: 'Keraton Ngayogyakarta Hadiningrat',
        category: DolanCategory.sejarah,
        location: 'Jl. Rotowijayan Blok No. 1, Panembahan, Kraton',
        description: 'Pusat kebudayaan Jawa yang masih aktif dipimpin Sultan, menyimpan ribuan pusaka, wayang, dan gamelan sakral.',
        mapsQuery: 'Keraton Ngayogyakarta Hadiningrat',
        rating: 4.9,
      ),
      DolanPlace(
        name: 'Taman Sari Water Castle',
        category: DolanCategory.sejarah,
        location: 'Patehan, Kraton, Kota Yogyakarta',
        description: 'Istana pemandian putri kerajaan abad ke-18 dengan lorong bawah air dan arsitektur perpaduan Jawa-Portugis.',
        mapsQuery: 'Taman Sari Water Castle Yogyakarta',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Gudeg Yu Djum Wijilan 167',
        category: DolanCategory.kuliner,
        location: 'Jl. Wijilan No. 167, Panembahan, Kraton, Yogyakarta',
        description: 'Ikon kuliner Yogyakarta berbahan nangka muda manis dimasak kendil kayu bakar semalaman bersama krecek pedas.',
        mapsQuery: 'Gudeg Yu Djum Wijilan 167 Yogyakarta',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Mangut Lele Mbah Marto',
        category: DolanCategory.kuliner,
        location: 'Jl. Sewon Indah, Panggungharjo, Bantul, DIY',
        description: 'Kuliner ndeso legendaris: ikan lele asap disiram kuah santan cabai rawit merah membakar lidah langsung dari pawon.',
        mapsQuery: 'Mangut Lele Mbah Marto Bantul Yogyakarta',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Candi Prambanan',
        category: DolanCategory.wisata,
        location: 'Bokoharjo, Prambanan, Sleman, D.I. Yogyakarta',
        description: 'Candi Hindu terindah di Asia Tenggara setinggi 47 meter yang diakui UNESCO dan panggung sendratari Ramayana.',
        mapsQuery: 'Candi Prambanan Sleman Yogyakarta',
        rating: 4.9,
      ),
      DolanPlace(
        name: 'Tebing Breksi & Hutan Pinus Mangunan',
        category: DolanCategory.wisata,
        location: 'Sambirejo, Prambanan, Sleman, DIY',
        description: 'Tebing batu kapur purba berukir relief wayang raksasa dengan panorama megah Candi Prambanan dan Gunung Merapi.',
        mapsQuery: 'Tebing Breksi Sleman Yogyakarta',
        rating: 4.7,
      ),
    ],
  ),

  // 6. JAWA TIMUR
  DolanRegion(
    id: 6,
    name: 'Jawa Timur',
    nickname: 'Bumi Majapahit & Pesona Gunung Eksotis',
    capital: 'Surabaya',
    places: [
      DolanPlace(
        name: 'Museum Majapahit Trowulan',
        category: DolanCategory.sejarah,
        location: 'Jl. Pendopo Agung, Trowulan, Mojokerto, Jatim',
        description: 'Pusat situs purbakala bekas ibu kota Kemaharajaan Majapahit abad ke-13 yang menguasai Nusantara.',
        mapsQuery: 'Museum Trowulan Majapahit Mojokerto',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Candi Penataran Blitar',
        category: DolanCategory.sejarah,
        location: 'Penataran, Nglegok, Kabupaten Blitar, Jawa Timur',
        description: 'Kompleks candi Hindu terbesar di Jawa Timur peninggalan Singasari hingga Majapahit berlatar Gunung Kelud.',
        mapsQuery: 'Candi Penataran Blitar Jawa Timur',
        rating: 4.7,
      ),
      DolanPlace(
        name: 'Rawon Nguling Surabaya',
        category: DolanCategory.kuliner,
        location: 'Jl. Rajawali No. 77, Krembangan, Surabaya',
        description: 'Sup daging sapi kuah hitam rempah kluwek khas Jawa Timur beraroma gurih sedap disajikan bersama telur asin.',
        mapsQuery: 'Rawon Nguling Surabaya',
        rating: 4.9,
      ),
      DolanPlace(
        name: 'Bakso Presiden Malang',
        category: DolanCategory.kuliner,
        location: 'Jl. Batanghari No. 5, Rampal Celaket, Klojen, Malang',
        description: 'Sensasi makan bakso urat kenyal dan pangsit goreng legendaris tepat di samping bantalan rel kereta api aktif.',
        mapsQuery: 'Bakso Presiden Malang',
        rating: 4.8,
      ),
      DolanPlace(
        name: 'Gunung Bromo & Lautan Pasir',
        category: DolanCategory.wisata,
        location: 'Taman Nasional Bromo Tengger Semeru, Jatim',
        description: 'Matahari terbit dramatis di atas kaldera purba, lautan pasir berbisik, dan kawah aktif suku Tengger.',
        mapsQuery: 'Gunung Bromo Lautan Pasir',
        rating: 4.9,
      ),
      DolanPlace(
        name: 'Kawah Ijen & Blue Fire',
        category: DolanCategory.wisata,
        location: 'Perbatasan Banyuwangi - Bondowoso, Jawa Timur',
        description: 'Fenomena api biru alami terlangka di dunia dan danau kawah asam toska terbesar di ketinggian 2.386 mdpl.',
        mapsQuery: 'Kawah Ijen Banyuwangi',
        rating: 4.9,
      ),
    ],
  ),
];

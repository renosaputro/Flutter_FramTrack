class CropDatabase {
  CropDatabase._();

  static const List<CropType> daftarTanaman = [
    CropType(
      nama: 'Cabai Rawit',
      kategori: 'Sayuran',
      durasiPanenHari: 90,
      emoji: '🌶️',
    ),
    CropType(
      nama: 'Cabai Merah',
      kategori: 'Sayuran',
      durasiPanenHari: 100,
      emoji: '🌶️',
    ),
    CropType(
      nama: 'Tomat',
      kategori: 'Sayuran',
      durasiPanenHari: 75,
      emoji: '🍅',
    ),
    CropType(
      nama: 'Terong',
      kategori: 'Sayuran',
      durasiPanenHari: 70,
      emoji: '🍆',
    ),
    CropType(
      nama: 'Selada',
      kategori: 'Sayuran',
      durasiPanenHari: 30,
      emoji: '🥬',
    ),
    CropType(
      nama: 'Kangkung',
      kategori: 'Sayuran',
      durasiPanenHari: 25,
      emoji: '🥬',
    ),
    CropType(
      nama: 'Bayam',
      kategori: 'Sayuran',
      durasiPanenHari: 25,
      emoji: '🥬',
    ),
    CropType(
      nama: 'Sawi',
      kategori: 'Sayuran',
      durasiPanenHari: 30,
      emoji: '🥬',
    ),
    CropType(
      nama: 'Buncis',
      kategori: 'Sayuran',
      durasiPanenHari: 60,
      emoji: '🫘',
    ),
    CropType(
      nama: 'Kacang Panjang',
      kategori: 'Sayuran',
      durasiPanenHari: 55,
      emoji: '🫘',
    ),
    CropType(
      nama: 'Mentimun',
      kategori: 'Sayuran',
      durasiPanenHari: 45,
      emoji: '🥒',
    ),
    CropType(
      nama: 'Labu Siam',
      kategori: 'Sayuran',
      durasiPanenHari: 90,
      emoji: '🎃',
    ),
    CropType(
      nama: 'Wortel',
      kategori: 'Sayuran',
      durasiPanenHari: 80,
      emoji: '🥕',
    ),
    CropType(
      nama: 'Brokoli',
      kategori: 'Sayuran',
      durasiPanenHari: 70,
      emoji: '🥦',
    ),
    CropType(
      nama: 'Semangka',
      kategori: 'Buah',
      durasiPanenHari: 80,
      emoji: '🍉',
    ),
    CropType(nama: 'Melon', kategori: 'Buah', durasiPanenHari: 75, emoji: '🍈'),
    CropType(
      nama: 'Stroberi',
      kategori: 'Buah',
      durasiPanenHari: 90,
      emoji: '🍓',
    ),
    CropType(
      nama: 'Pepaya',
      kategori: 'Buah',
      durasiPanenHari: 270,
      emoji: '🥭',
    ),
    CropType(
      nama: 'Padi',
      kategori: 'Pangan',
      durasiPanenHari: 120,
      emoji: '🌾',
    ),
    CropType(
      nama: 'Jagung',
      kategori: 'Pangan',
      durasiPanenHari: 90,
      emoji: '🌽',
    ),
    CropType(
      nama: 'Kedelai',
      kategori: 'Pangan',
      durasiPanenHari: 80,
      emoji: '🫘',
    ),
    CropType(
      nama: 'Jahe',
      kategori: 'Rempah',
      durasiPanenHari: 240,
      emoji: '🫚',
    ),
    CropType(
      nama: 'Kunyit',
      kategori: 'Rempah',
      durasiPanenHari: 240,
      emoji: '🫚',
    ),
    CropType(
      nama: 'Bawang Merah',
      kategori: 'Rempah',
      durasiPanenHari: 60,
      emoji: '🧅',
    ),
    CropType(
      nama: 'Bawang Putih',
      kategori: 'Rempah',
      durasiPanenHari: 90,
      emoji: '🧄',
    ),
    CropType(
      nama: 'Serai',
      kategori: 'Rempah',
      durasiPanenHari: 120,
      emoji: '🌿',
    ),
    CropType(
      nama: 'Basil',
      kategori: 'Herbs',
      durasiPanenHari: 30,
      emoji: '🌿',
    ),
    CropType(nama: 'Mint', kategori: 'Herbs', durasiPanenHari: 30, emoji: '🌿'),
    CropType(
      nama: 'Rosemary',
      kategori: 'Herbs',
      durasiPanenHari: 90,
      emoji: '🌿',
    ),
    CropType(
      nama: 'Daun Bawang',
      kategori: 'Herbs',
      durasiPanenHari: 45,
      emoji: '🌿',
    ),
  ];

  static CropType? findByName(String nama) {
    try {
      return daftarTanaman.firstWhere(
        (c) => c.nama.toLowerCase() == nama.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  static List<CropType> byKategori(String kategori) {
    return daftarTanaman.where((c) => c.kategori == kategori).toList();
  }

  static List<String> get kategoriList {
    return daftarTanaman.map((c) => c.kategori).toSet().toList();
  }
}

class CropType {
  final String nama;
  final String kategori;
  final int durasiPanenHari;
  final String emoji;

  const CropType({
    required this.nama,
    required this.kategori,
    required this.durasiPanenHari,
    required this.emoji,
  });
}

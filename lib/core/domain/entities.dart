import 'package:equatable/equatable.dart';

enum CropHealthStatus {
  sehat,
  hamaPenyakit,
  layu,
  tidakDiketahui,
}

enum CropLifecycleStatus {
  semai,
  vegetatif,
  generatif,
  panen,
  selesai,
}

enum ActivityType {
  penyiraman,
  pemupukan,
  pestisida,
  penyiangan,
  pemangkasan,
  lainnya,
}

class Crop extends Equatable {
  final String id;
  final String nama;
  final String jenisTanaman;
  final String varietas;
  final String? namaLahan;
  final String? lokasiPlot;
  final DateTime tanggalSemai;
  final DateTime? tanggalTanam;
  final DateTime estimasiPanen;
  final int durasiHariPanen;
  final CropHealthStatus healthStatus;
  final CropLifecycleStatus lifecycleStatus;
  final String? fotoTerakhir;
  final double? tinggiBatang; 
  final int? jumlahDaun;
  final List<String> fotoTimeline;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Crop({
    required this.id,
    required this.nama,
    required this.jenisTanaman,
    required this.varietas,
    this.namaLahan,
    this.lokasiPlot,
    required this.tanggalSemai,
    this.tanggalTanam,
    required this.estimasiPanen,
    required this.durasiHariPanen,
    this.healthStatus = CropHealthStatus.sehat,
    this.lifecycleStatus = CropLifecycleStatus.semai,
    this.fotoTerakhir,
    this.tinggiBatang,
    this.jumlahDaun,
    this.fotoTimeline = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  double get progress {
    final totalDays = estimasiPanen.difference(tanggalSemai).inDays;
    if (totalDays <= 0) return 1.0;
    final elapsedDays = DateTime.now().difference(tanggalSemai).inDays;
    return (elapsedDays / totalDays).clamp(0.0, 1.0);
  }
  int get hariKe => DateTime.now().difference(tanggalSemai).inDays;
  int get sisaHariPanen {
    final remaining = estimasiPanen.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  Crop copyWith({
    String? id,
    String? nama,
    String? jenisTanaman,
    String? varietas,
    String? namaLahan,
    String? lokasiPlot,
    DateTime? tanggalSemai,
    DateTime? tanggalTanam,
    DateTime? estimasiPanen,
    int? durasiHariPanen,
    CropHealthStatus? healthStatus,
    CropLifecycleStatus? lifecycleStatus,
    String? fotoTerakhir,
    double? tinggiBatang,
    int? jumlahDaun,
    List<String>? fotoTimeline,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Crop(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      jenisTanaman: jenisTanaman ?? this.jenisTanaman,
      varietas: varietas ?? this.varietas,
      namaLahan: namaLahan ?? this.namaLahan,
      lokasiPlot: lokasiPlot ?? this.lokasiPlot,
      tanggalSemai: tanggalSemai ?? this.tanggalSemai,
      tanggalTanam: tanggalTanam ?? this.tanggalTanam,
      estimasiPanen: estimasiPanen ?? this.estimasiPanen,
      durasiHariPanen: durasiHariPanen ?? this.durasiHariPanen,
      healthStatus: healthStatus ?? this.healthStatus,
      lifecycleStatus: lifecycleStatus ?? this.lifecycleStatus,
      fotoTerakhir: fotoTerakhir ?? this.fotoTerakhir,
      tinggiBatang: tinggiBatang ?? this.tinggiBatang,
      jumlahDaun: jumlahDaun ?? this.jumlahDaun,
      fotoTimeline: fotoTimeline ?? this.fotoTimeline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, nama, updatedAt];
}

class ActivityLog extends Equatable {
  final String id;
  final String cropId;
  final ActivityType tipe;
  final DateTime tanggal;
  final String? catatan;
  final String? foto;
  final CropHealthStatus? statusKesehatan;
  final String? jenisPupuk;
  final double? dosisPupuk; 
  final String? jenisPestisida;
  final double? konsentrasi;
  final double? tinggiBatang;
  final int? jumlahDaun;

  const ActivityLog({
    required this.id,
    required this.cropId,
    required this.tipe,
    required this.tanggal,
    this.catatan,
    this.foto,
    this.statusKesehatan,
    this.jenisPupuk,
    this.dosisPupuk,
    this.jenisPestisida,
    this.konsentrasi,
    this.tinggiBatang,
    this.jumlahDaun,
  });

  @override
  List<Object?> get props => [id, cropId, tanggal];
}

class HarvestResult extends Equatable {
  final String id;
  final String cropId;
  final DateTime tanggalPanen;
  final double beratKg;
  final int? jumlahBuah;
  final String kualitas;
  final double? hargaJualPerKg;
  final String? foto;
  final String? catatan;
  final int rating;

  const HarvestResult({
    required this.id,
    required this.cropId,
    required this.tanggalPanen,
    required this.beratKg,
    this.jumlahBuah,
    required this.kualitas,
    this.hargaJualPerKg,
    this.foto,
    this.catatan,
    this.rating = 3,
  });

  double? get totalPendapatan =>
      hargaJualPerKg != null ? beratKg * hargaJualPerKg! : null;

  @override
  List<Object?> get props => [id, cropId, tanggalPanen];
}

class FarmField extends Equatable {
  final String id;
  final String nama;
  final String? deskripsi;
  final String? lokasi;

  const FarmField({
    required this.id,
    required this.nama,
    this.deskripsi,
    this.lokasi,
  });

  @override
  List<Object?> get props => [id, nama];
}

class FarmReminder extends Equatable {
  final String id;
  final String? cropId;
  final String judul;
  final String? deskripsi;
  final DateTime waktu;
  final bool sudahSelesai;
  final bool isOtomatis;

  const FarmReminder({
    required this.id,
    this.cropId,
    required this.judul,
    this.deskripsi,
    required this.waktu,
    this.sudahSelesai = false,
    this.isOtomatis = false,
  });

  @override
  List<Object?> get props => [id, waktu, sudahSelesai];
}

class DailyTask extends Equatable {
  final String id;
  final String cropId;
  final String cropNama;
  final String deskripsi;
  final ActivityType tipe;
  final bool selesai;
  final DateTime jadwal;

  const DailyTask({
    required this.id,
    required this.cropId,
    required this.cropNama,
    required this.deskripsi,
    required this.tipe,
    this.selesai = false,
    required this.jadwal,
  });

  @override
  List<Object?> get props => [id, selesai];
}

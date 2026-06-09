import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/entities.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;
  DocumentReference get _userDoc => _db.collection('users').doc(_uid);
  CollectionReference get _cropsCol => _userDoc.collection('crops');
  CollectionReference get _fieldsCol => _userDoc.collection('fields');
  CollectionReference get _remindersCol => _userDoc.collection('reminders');
  
  CollectionReference _activitiesCol(String cropId) =>
      _cropsCol.doc(cropId).collection('activities');

  CollectionReference _harvestsCol(String cropId) =>
      _cropsCol.doc(cropId).collection('harvests');

  Future<void> saveUserProfile({
    required String name,
    required String email,
    String? photoUrl,
  }) async {
    await _userDoc.set({
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>?> watchUserProfile() {
    return _userDoc.snapshots().map(
      (snap) => snap.data() as Map<String, dynamic>?,
    );
  }

  Future<String> addCrop(Crop crop) async {
    final doc = _cropsCol.doc(crop.id);
    await doc.set(_cropToMap(crop));
    return doc.id;
  }

  Future<void> updateCrop(Crop crop) async {
    await _cropsCol.doc(crop.id).update(_cropToMap(crop));
  }

  Future<void> deleteCrop(String cropId) async {
    await _cropsCol.doc(cropId).delete();
  }

  Stream<List<Crop>> watchActiveCrops() {
    return _cropsCol
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => _cropFromDoc(d))
              .where((c) => c.lifecycleStatus != CropLifecycleStatus.selesai)
              .toList(),
        );
  }

  Stream<List<Crop>> watchAllCrops() {
    return _cropsCol
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _cropFromDoc(d)).toList());
  }

  Future<Crop?> getCrop(String cropId) async {
    final doc = await _cropsCol.doc(cropId).get();
    if (!doc.exists) return null;
    return _cropFromDoc(doc);
  }

  Future<void> markCropHarvested(String cropId) async {
    await _cropsCol.doc(cropId).update({
      'lifecycleStatus': 'selesai',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> addActivity(ActivityLog log) async {
    await _activitiesCol(log.cropId).doc(log.id).set(_activityToMap(log));
  }

  Stream<List<ActivityLog>> watchActivities(String cropId) {
    return _activitiesCol(cropId)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _activityFromDoc(d)).toList());
  }

  Future<void> addHarvest(HarvestResult harvest) async {
    await _harvestsCol(
      harvest.cropId,
    ).doc(harvest.id).set(_harvestToMap(harvest));
    await _userDoc.collection('all_harvests').doc(harvest.id).set({
      ..._harvestToMap(harvest),
      'cropId': harvest.cropId,
    });
  }

  Stream<List<HarvestResult>> watchAllHarvests() {
    return _userDoc
        .collection('all_harvests')
        .orderBy('tanggalPanen', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _harvestFromDoc(d)).toList());
  }

  Future<void> addField(FarmField field) async {
    await _fieldsCol.doc(field.id).set(_fieldToMap(field));
  }

  Future<void> updateField(FarmField field) async {
    await _fieldsCol.doc(field.id).update(_fieldToMap(field));
  }

  Future<void> deleteField(String fieldId) async {
    await _fieldsCol.doc(fieldId).delete();
  }

  Stream<List<FarmField>> watchFields() {
    return _fieldsCol.snapshots().map(
      (snap) => snap.docs.map((d) => _fieldFromDoc(d)).toList(),
    );
  }

  Future<void> addReminder(FarmReminder reminder) async {
    await _remindersCol.doc(reminder.id).set(_reminderToMap(reminder));
  }

  Future<void> toggleReminder(String reminderId, bool selesai) async {
    await _remindersCol.doc(reminderId).update({'sudahSelesai': selesai});
  }

  Future<void> deleteReminder(String reminderId) async {
    await _remindersCol.doc(reminderId).delete();
  }

  Stream<List<FarmReminder>> watchActiveReminders() {
    return _remindersCol
        .where('sudahSelesai', isEqualTo: false)
        .orderBy('waktu')
        .snapshots()
        .map((snap) => snap.docs.map((d) => _reminderFromDoc(d)).toList());
  }
  
  Map<String, dynamic> _cropToMap(Crop c) => {
    'nama': c.nama,
    'jenisTanaman': c.jenisTanaman,
    'varietas': c.varietas,
    'namaLahan': c.namaLahan,
    'lokasiPlot': c.lokasiPlot,
    'tanggalSemai': Timestamp.fromDate(c.tanggalSemai),
    'tanggalTanam': c.tanggalTanam != null
        ? Timestamp.fromDate(c.tanggalTanam!)
        : null,
    'estimasiPanen': Timestamp.fromDate(c.estimasiPanen),
    'durasiHariPanen': c.durasiHariPanen,
    'healthStatus': c.healthStatus.name,
    'lifecycleStatus': c.lifecycleStatus.name,
    'fotoTerakhir': c.fotoTerakhir,
    'tinggiBatang': c.tinggiBatang,
    'jumlahDaun': c.jumlahDaun,
    'fotoTimeline': c.fotoTimeline,
    'createdAt': Timestamp.fromDate(c.createdAt),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Crop _cropFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Crop(
      id: doc.id,
      nama: d['nama'] ?? '',
      jenisTanaman: d['jenisTanaman'] ?? '',
      varietas: d['varietas'] ?? '',
      namaLahan: d['namaLahan'],
      lokasiPlot: d['lokasiPlot'],
      tanggalSemai: (d['tanggalSemai'] as Timestamp).toDate(),
      tanggalTanam: d['tanggalTanam'] != null
          ? (d['tanggalTanam'] as Timestamp).toDate()
          : null,
      estimasiPanen: (d['estimasiPanen'] as Timestamp).toDate(),
      durasiHariPanen: d['durasiHariPanen'] ?? 90,
      healthStatus: CropHealthStatus.values.firstWhere(
        (e) => e.name == d['healthStatus'],
        orElse: () => CropHealthStatus.tidakDiketahui,
      ),
      lifecycleStatus: CropLifecycleStatus.values.firstWhere(
        (e) => e.name == d['lifecycleStatus'],
        orElse: () => CropLifecycleStatus.semai,
      ),
      fotoTerakhir: d['fotoTerakhir'],
      tinggiBatang: (d['tinggiBatang'] as num?)?.toDouble(),
      jumlahDaun: d['jumlahDaun'],
      fotoTimeline: List<String>.from(d['fotoTimeline'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _activityToMap(ActivityLog a) => {
    'cropId': a.cropId,
    'tipe': a.tipe.name,
    'tanggal': Timestamp.fromDate(a.tanggal),
    'catatan': a.catatan,
    'foto': a.foto,
    'statusKesehatan': a.statusKesehatan?.name,
    'jenisPupuk': a.jenisPupuk,
    'dosisPupuk': a.dosisPupuk,
    'jenisPestisida': a.jenisPestisida,
    'konsentrasi': a.konsentrasi,
    'tinggiBatang': a.tinggiBatang,
    'jumlahDaun': a.jumlahDaun,
  };

  ActivityLog _activityFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ActivityLog(
      id: doc.id,
      cropId: d['cropId'] ?? '',
      tipe: ActivityType.values.firstWhere(
        (e) => e.name == d['tipe'],
        orElse: () => ActivityType.lainnya,
      ),
      tanggal: (d['tanggal'] as Timestamp).toDate(),
      catatan: d['catatan'],
      foto: d['foto'],
      statusKesehatan: d['statusKesehatan'] != null
          ? CropHealthStatus.values.firstWhere(
              (e) => e.name == d['statusKesehatan'],
              orElse: () => CropHealthStatus.tidakDiketahui,
            )
          : null,
      jenisPupuk: d['jenisPupuk'],
      dosisPupuk: (d['dosisPupuk'] as num?)?.toDouble(),
      jenisPestisida: d['jenisPestisida'],
      konsentrasi: (d['konsentrasi'] as num?)?.toDouble(),
      tinggiBatang: (d['tinggiBatang'] as num?)?.toDouble(),
      jumlahDaun: d['jumlahDaun'],
    );
  }

  Map<String, dynamic> _harvestToMap(HarvestResult h) => {
    'cropId': h.cropId,
    'tanggalPanen': Timestamp.fromDate(h.tanggalPanen),
    'beratKg': h.beratKg,
    'jumlahBuah': h.jumlahBuah,
    'kualitas': h.kualitas,
    'hargaJualPerKg': h.hargaJualPerKg,
    'foto': h.foto,
    'catatan': h.catatan,
    'rating': h.rating,
  };

  HarvestResult _harvestFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return HarvestResult(
      id: doc.id,
      cropId: d['cropId'] ?? '',
      tanggalPanen: (d['tanggalPanen'] as Timestamp).toDate(),
      beratKg: (d['beratKg'] as num).toDouble(),
      jumlahBuah: d['jumlahBuah'],
      kualitas: d['kualitas'] ?? 'Sedang',
      hargaJualPerKg: (d['hargaJualPerKg'] as num?)?.toDouble(),
      foto: d['foto'],
      catatan: d['catatan'],
      rating: d['rating'] ?? 3,
    );
  }

  Map<String, dynamic> _fieldToMap(FarmField f) => {
    'nama': f.nama,
    'deskripsi': f.deskripsi,
    'lokasi': f.lokasi,
  };

  FarmField _fieldFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FarmField(
      id: doc.id,
      nama: d['nama'] ?? '',
      deskripsi: d['deskripsi'],
      lokasi: d['lokasi'],
    );
  }

  Map<String, dynamic> _reminderToMap(FarmReminder r) => {
    'cropId': r.cropId,
    'judul': r.judul,
    'deskripsi': r.deskripsi,
    'waktu': Timestamp.fromDate(r.waktu),
    'sudahSelesai': r.sudahSelesai,
    'isOtomatis': r.isOtomatis,
  };

  FarmReminder _reminderFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FarmReminder(
      id: doc.id,
      cropId: d['cropId'],
      judul: d['judul'] ?? '',
      deskripsi: d['deskripsi'],
      waktu: (d['waktu'] as Timestamp).toDate(),
      sudahSelesai: d['sudahSelesai'] ?? false,
      isOtomatis: d['isOtomatis'] ?? false,
    );
  }
}

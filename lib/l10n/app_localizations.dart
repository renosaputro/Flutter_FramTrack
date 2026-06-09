import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static List<Locale> get supportedLocales => const [
    Locale('id'),
    Locale('en'),
  ];

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get chooseLanguage {
    switch (locale.languageCode) {
      case 'en':
        return 'Choose Language';
      case 'id':
      default:
        return 'Pilih Bahasa';
    }
  }

  String get appTitle {
    switch (locale.languageCode) {
      case 'en':
        return 'FarmTrack';
      case 'id':
      default:
        return 'FarmTrack';
    }
  }

  String get profile {
    switch (locale.languageCode) {
      case 'en':
        return 'Profile';
      case 'id':
      default:
        return 'Profil';
    }
  }

  String get tapToEditProfile {
    switch (locale.languageCode) {
      case 'en':
        return 'Tap to edit profile';
      case 'id':
      default:
        return 'Tap untuk edit profil';
    }
  }

  String get plants {
    switch (locale.languageCode) {
      case 'en':
        return 'Plants';
      case 'id':
      default:
        return 'Tanaman';
    }
  }

  String get harvests {
    switch (locale.languageCode) {
      case 'en':
        return 'Harvests';
      case 'id':
      default:
        return 'Panen';
    }
  }

  String get fields {
    switch (locale.languageCode) {
      case 'en':
        return 'Fields';
      case 'id':
      default:
        return 'Lahan';
    }
  }

  String get manageFields {
    switch (locale.languageCode) {
      case 'en':
        return 'Manage Fields';
      case 'id':
      default:
        return 'Kelola Lahan';
    }
  }

  String get addManageFields {
    switch (locale.languageCode) {
      case 'en':
        return 'Add & manage fields';
      case 'id':
      default:
        return 'Tambah & kelola lahan';
    }
  }

  String get harvestReport {
    switch (locale.languageCode) {
      case 'en':
        return 'Harvest Report';
      case 'id':
      default:
        return 'Laporan Panen';
    }
  }

  String get viewAnalysis {
    switch (locale.languageCode) {
      case 'en':
        return 'View analysis';
      case 'id':
      default:
        return 'Lihat analisis';
    }
  }

  String get notificationSettings {
    switch (locale.languageCode) {
      case 'en':
        return 'Notification Settings';
      case 'id':
      default:
        return 'Pengaturan Notifikasi';
    }
  }

  String get setReminders {
    switch (locale.languageCode) {
      case 'en':
        return 'Set reminders';
      case 'id':
      default:
        return 'Atur pengingat';
    }
  }

  String get darkMode {
    switch (locale.languageCode) {
      case 'en':
        return 'Dark Mode';
      case 'id':
      default:
        return 'Mode Gelap';
    }
  }

  String get active {
    switch (locale.languageCode) {
      case 'en':
        return 'Active';
      case 'id':
      default:
        return 'Aktif';
    }
  }

  String get inactive {
    switch (locale.languageCode) {
      case 'en':
        return 'Inactive';
      case 'id':
      default:
        return 'Nonaktif';
    }
  }

  String get language {
    switch (locale.languageCode) {
      case 'en':
        return 'Language';
      case 'id':
      default:
        return 'Bahasa';
    }
  }

  String get aboutApp {
    switch (locale.languageCode) {
      case 'en':
        return 'About FarmTrack';
      case 'id':
      default:
        return 'Tentang FarmTrack';
    }
  }

  String versionLabel(String v) {
    switch (locale.languageCode) {
      case 'en':
        return 'Version $v';
      case 'id':
      default:
        return 'Versi $v';
    }
  }

  String get logout {
    switch (locale.languageCode) {
      case 'en':
        return 'Logout';
      case 'id':
      default:
        return 'Keluar';
    }
  }

  String get noPlants {
    switch (locale.languageCode) {
      case 'en':
        return 'No plants yet';
      case 'id':
      default:
        return 'Belum ada tanaman';
    }
  }

  String get addPlant {
    switch (locale.languageCode) {
      case 'en':
        return 'Add Plant';
      case 'id':
      default:
        return 'Tambah Tanaman';
    }
  }

  String get seeAll {
    switch (locale.languageCode) {
      case 'en':
        return 'See All';
      case 'id':
      default:
        return 'Lihat Semua';
    }
  }

  String get activePlantsLabel {
    switch (locale.languageCode) {
      case 'en':
        return 'Active Plants';
      case 'id':
      default:
        return 'Tanaman Aktif';
    }
  }

  String get totalHarvestLabel {
    switch (locale.languageCode) {
      case 'en':
        return 'Total Harvest';
      case 'id':
      default:
        return 'Total Panen';
    }
  }

  String get upcomingReminders {
    switch (locale.languageCode) {
      case 'en':
        return 'Upcoming Reminders';
      case 'id':
      default:
        return 'Pengingat Mendatang';
    }
  }

  String get noActiveReminders {
    switch (locale.languageCode) {
      case 'en':
        return 'No active reminders';
      case 'id':
      default:
        return 'Tidak ada pengingat aktif';
    }
  }

  String get infoCrop {
    switch (locale.languageCode) {
      case 'en':
        return 'Crop Info';
      case 'id':
      default:
        return 'Info Tanaman';
    }
  }

  String get schedule {
    switch (locale.languageCode) {
      case 'en':
        return 'Schedule';
      case 'id':
      default:
        return 'Jadwal';
    }
  }

  String get location {
    switch (locale.languageCode) {
      case 'en':
        return 'Location';
      case 'id':
      default:
        return 'Lokasi';
    }
  }

  String get back {
    switch (locale.languageCode) {
      case 'en':
        return 'Back';
      case 'id':
      default:
        return 'Kembali';
    }
  }

  String get next {
    switch (locale.languageCode) {
      case 'en':
        return 'Next';
      case 'id':
      default:
        return 'Selanjutnya';
    }
  }

  String get saveCrop {
    switch (locale.languageCode) {
      case 'en':
        return 'Save Crop';
      case 'id':
      default:
        return 'Simpan Tanaman';
    }
  }

  String get choosePlantType {
    switch (locale.languageCode) {
      case 'en':
        return 'Choose Plant Type';
      case 'id':
      default:
        return 'Pilih Jenis Tanaman';
    }
  }

  String get selectField {
    switch (locale.languageCode) {
      case 'en':
        return 'Select Field';
      case 'id':
      default:
        return 'Pilih Lahan';
    }
  }

  String get noFieldsMessage {
    switch (locale.languageCode) {
      case 'en':
        return 'You have not created any fields. Create one first to select a location for the crop.';
      case 'id':
      default:
        return 'Anda belum membuat lahan. Buat lahan terlebih dahulu agar dapat memilih lokasi untuk tanaman.';
    }
  }

  String get createField {
    switch (locale.languageCode) {
      case 'en':
        return 'Create Field';
      case 'id':
      default:
        return 'Buat Lahan';
    }
  }

  String get summary {
    switch (locale.languageCode) {
      case 'en':
        return 'Summary';
      case 'id':
      default:
        return 'Ringkasan';
    }
  }

  String get customNameLabel {
    switch (locale.languageCode) {
      case 'en':
        return 'Custom Name';
      case 'id':
      default:
        return 'Nama Kustom';
    }
  }

  String get customNameHint {
    switch (locale.languageCode) {
      case 'en':
        return 'Example: Chili Batch 1';
      case 'id':
      default:
        return 'Contoh: Cabai Kloter 1';
    }
  }

  String get varietasLabel {
    switch (locale.languageCode) {
      case 'en':
        return 'Variety (optional)';
      case 'id':
      default:
        return 'Varietas (opsional)';
    }
  }

  String get pickCropFirst {
    switch (locale.languageCode) {
      case 'en':
        return 'Please choose a crop type first';
      case 'id':
      default:
        return 'Pilih jenis tanaman terlebih dahulu';
    }
  }

  String get cropAddedSuccess {
    switch (locale.languageCode) {
      case 'en':
        return '🎉 Crop added successfully!';
      case 'id':
      default:
        return '🎉 Tanaman berhasil ditambahkan!';
    }
  }

  String saveFailed(String e) {
    switch (locale.languageCode) {
      case 'en':
        return 'Failed to save: $e';
      case 'id':
      default:
        return 'Gagal menyimpan: $e';
    }
  }

  String get estimasiPanen {
    switch (locale.languageCode) {
      case 'en':
        return 'Estimated Harvest';
      case 'id':
      default:
        return 'Estimasi Panen';
    }
  }

  String get myPlants {
    switch (locale.languageCode) {
      case 'en':
        return 'My Plants';
      case 'id':
      default:
        return 'Tanaman Saya';
    }
  }

  String get searchPlants {
    switch (locale.languageCode) {
      case 'en':
        return 'Search plants...';
      case 'id':
      default:
        return 'Cari tanaman...';
    }
  }

  String get noHistory {
    switch (locale.languageCode) {
      case 'en':
        return 'No history yet';
      case 'id':
      default:
        return 'Belum Ada Riwayat';
    }
  }

  String get historySubtitle {
    switch (locale.languageCode) {
      case 'en':
        return 'Harvest history will appear after you harvest.';
      case 'id':
      default:
        return 'Riwayat panen muncul setelah kamu panen.';
    }
  }

  String get notifications {
    switch (locale.languageCode) {
      case 'en':
        return 'Notifications';
      case 'id':
      default:
        return 'Notifikasi';
    }
  }

  String get reminderTimeLabel {
    switch (locale.languageCode) {
      case 'en':
        return 'Daily reminder time';
      case 'id':
      default:
        return 'Jam Pengingat Harian';
    }
  }

  String get reminderTimeDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Automatic reminders are sent daily at:';
      case 'id':
      default:
        return 'Pengingat otomatis dikirim setiap hari pada jam:';
    }
  }

  String get notificationTypes {
    switch (locale.languageCode) {
      case 'en':
        return 'Notification types';
      case 'id':
      default:
        return 'Jenis Notifikasi';
    }
  }

  String get watering {
    switch (locale.languageCode) {
      case 'en':
        return 'Watering';
      case 'id':
      default:
        return 'Penyiraman';
    }
  }

  String get wateringDesc {
    switch (locale.languageCode) {
      case 'en':
        return 'Daily watering reminder';
      case 'id':
      default:
        return 'Pengingat siram harian';
    }
  }

  String get fertilizing {
    switch (locale.languageCode) {
      case 'en':
        return 'Fertilizing';
      case 'id':
      default:
        return 'Pemupukan';
    }
  }

  String get fertilizingDesc {
    switch (locale.languageCode) {
      case 'en':
        return 'Scheduled fertilizing reminders';
      case 'id':
      default:
        return 'Jadwal pupuk berkala';
    }
  }

  String get harvest {
    switch (locale.languageCode) {
      case 'en':
        return 'Harvest';
      case 'id':
      default:
        return 'Panen';
    }
  }

  String get harvestDesc {
    switch (locale.languageCode) {
      case 'en':
        return 'Estimated harvest arrival time';
      case 'id':
      default:
        return 'Estimasi waktu panen tiba';
    }
  }

  String get care {
    switch (locale.languageCode) {
      case 'en':
        return 'Care';
      case 'id':
      default:
        return 'Perawatan';
    }
  }

  String get careDesc {
    switch (locale.languageCode) {
      case 'en':
        return 'General care reminders';
      case 'id':
      default:
        return 'Pengingat perawatan umum';
    }
  }

  String get cancel {
    switch (locale.languageCode) {
      case 'en':
        return 'Cancel';
      case 'id':
      default:
        return 'Batal';
    }
  }

  String get save {
    switch (locale.languageCode) {
      case 'en':
        return 'Save';
      case 'id':
      default:
        return 'Simpan';
    }
  }

  String get languageDescription {
    switch (locale.languageCode) {
      case 'en':
        return 'Language used in the app';
      case 'id':
      default:
        return 'Bahasa yang digunakan di aplikasi';
    }
  }

  // ignore: non_constant_identifier_names
  String get Indonesia {
    switch (locale.languageCode) {
      case 'en':
        return 'Indonesia';
      case 'id':
      default:
        return 'Indonesia';
    }
  }

  // ignore: non_constant_identifier_names
  String get English {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'id':
      default:
        return 'Inggris';
    }
  }

  Null get days => null;

  Null get fromSeed => null;

  String? get choosePlantFirst => null;

  String? get cropAdded => null;

  Null get failedToSave => null;

  Null get nameLabel => null;

  Null get plantLabel => null;

  Null get fieldLabel => null;

  Null get durationLabel => null;

  Null get varietasHint => null;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'id'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

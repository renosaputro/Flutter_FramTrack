import 'package:equatable/equatable.dart';

class SettingsState extends Equatable {
  final bool isDarkMode;
  final String locale;
  final bool notifikasiAktif;
  final int jamPengingat;

  const SettingsState({
    this.isDarkMode = false,
    this.locale = 'id',
    this.notifikasiAktif = true,
    this.jamPengingat = 6,
  });

  SettingsState copyWith({
    bool? isDarkMode,
    String? locale,
    bool? notifikasiAktif,
    int? jamPengingat,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
      notifikasiAktif: notifikasiAktif ?? this.notifikasiAktif,
      jamPengingat: jamPengingat ?? this.jamPengingat,
    );
  }

  @override
  List<Object?> get props => [isDarkMode, locale, notifikasiAktif, jamPengingat];
}

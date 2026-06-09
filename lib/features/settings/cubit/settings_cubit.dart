import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  static const _keyDarkMode = 'dark_mode';
  static const _keyLocale = 'locale';
  static const _keyNotifikasi = 'notifikasi_aktif';
  static const _keyJamPengingat = 'jam_pengingat';

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    emit(SettingsState(
      isDarkMode: prefs.getBool(_keyDarkMode) ?? false,
      locale: prefs.getString(_keyLocale) ?? 'id',
      notifikasiAktif: prefs.getBool(_keyNotifikasi) ?? true,
      jamPengingat: prefs.getInt(_keyJamPengingat) ?? 6,
    ));
  }

  Future<void> toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
    emit(state.copyWith(isDarkMode: value));
  }

  Future<void> setLocale(String locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale);
    emit(state.copyWith(locale: locale));
  }

  Future<void> toggleNotifikasi(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifikasi, value);
    emit(state.copyWith(notifikasiAktif: value));
  }

  Future<void> setJamPengingat(int jam) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyJamPengingat, jam);
    emit(state.copyWith(jamPengingat: jam));
  }
}

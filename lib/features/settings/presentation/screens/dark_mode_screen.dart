import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../settings/cubit/settings_cubit.dart';
import '../../../settings/cubit/settings_state.dart';

class DarkModeScreen extends StatelessWidget {
  const DarkModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tampilan')),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final themeDark = Theme.of(context).brightness == Brightness.dark;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Mode Tampilan', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Pilih tema yang nyaman untuk mata Anda',
                style: TextStyle(color: themeDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
              const SizedBox(height: 24),

              _modeCard(context, 'Terang', 'Mode default dengan latar putih', Icons.light_mode, false, !state.isDarkMode, themeDark),
              const SizedBox(height: 12),
              _modeCard(context, 'Gelap', 'Nyaman untuk penggunaan malam hari', Icons.dark_mode, true, state.isDarkMode, themeDark),
            ]),
          );
        },
      ),
    );
  }

  Widget _modeCard(BuildContext context, String title, String desc, IconData icon, bool isDark, bool selected, bool themeDark) {
    return InkWell(
      onTap: () => context.read<SettingsCubit>().toggleDarkMode(isDark),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected
            ? (themeDark ? const Color(0xFF1B3A1E) : AppColors.primarySurface)
            : (themeDark ? AppColors.darkCard : AppColors.card),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : (themeDark ? AppColors.darkElevated : AppColors.divider),
            width: selected ? 2 : 0.5,
          ),
        ),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: isDark ? Colors.white : AppColors.secondary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 2),
            Text(desc, style: TextStyle(fontSize: 13, color: themeDark ? AppColors.darkTextSecondary : AppColors.textSecondary)),
          ])),
          if (selected)
            const Icon(Icons.check_circle, color: AppColors.primaryLight),
        ]),
      ),
    );
  }
}

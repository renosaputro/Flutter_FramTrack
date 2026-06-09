import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samar_farming/l10n/app_localizations.dart';
import '../../../settings/cubit/settings_cubit.dart';
import '../../../settings/cubit/settings_state.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.language)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.chooseLanguage,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.languageDescription,
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 24),
                _langCard(
                  context,
                  AppLocalizations.of(context)!.Indonesia,
                  '🇮🇩',
                  'id',
                  state.locale == 'id',
                ),
                const SizedBox(height: 12),
                _langCard(
                  context,
                  AppLocalizations.of(context)!.English,
                  '🇬🇧',
                  'en',
                  state.locale == 'en',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _langCard(
    BuildContext context,
    String title,
    String flag,
    String code,
    bool selected,
  ) {
    final theme = Theme.of(context);
    final bgColor = selected
        ? theme.colorScheme.primaryContainer
        : theme.cardColor;
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.dividerColor;
    final titleColor = selected ? theme.colorScheme.primary : null;

    return InkWell(
      onTap: () => context.read<SettingsCubit>().setLocale(code),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selected ? 2 : 0.5),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: titleColor,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}

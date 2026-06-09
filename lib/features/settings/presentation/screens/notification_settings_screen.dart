import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:samar_farming/l10n/app_localizations.dart';
import '../../../settings/cubit/settings_cubit.dart';
import '../../../settings/cubit/settings_state.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final Map<String, bool> _enabled = {
    'penyiraman': true,
    'pemupukan': true,
    'panen': true,
    'perawatan': false,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.notificationSettings),
      ),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: state.notifikasiAktif
                      ? theme.colorScheme.primaryContainer
                      : theme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: state.notifikasiAktif
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      state.notifikasiAktif
                          ? Icons.notifications_active
                          : Icons.notifications_off,
                      color: state.notifikasiAktif
                          ? theme.colorScheme.primary
                          // ignore: deprecated_member_use
                          : theme.textTheme.bodySmall?.color?.withOpacity(0.85),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.notifications,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.notifikasiAktif
                                ? AppLocalizations.of(context)!.active
                                : AppLocalizations.of(context)!.inactive,
                            style: TextStyle(
                              fontSize: 13,
                              color: theme.textTheme.bodySmall?.color
                                  // ignore: deprecated_member_use
                                  ?.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: state.notifikasiAktif,
                      onChanged: (v) =>
                          context.read<SettingsCubit>().toggleNotifikasi(v),
                      activeColor: theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (state.notifikasiAktif) ...[
                Text(
                  AppLocalizations.of(context)!.reminderTimeLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.reminderTimeDescription,
                  style: TextStyle(
                    // ignore: deprecated_member_use
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor, width: 0.5),
                  ),
                  child: InkWell(
                    onTap: () async {
                      final cubit = context.read<SettingsCubit>();
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: state.jamPengingat,
                          minute: 0,
                        ),
                      );
                      if (time != null) {
                        cubit.setJamPengingat(time.hour);
                      }
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${state.jamPengingat.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.edit,
                          size: 18,
                          // ignore: deprecated_member_use
                          color: theme.textTheme.bodySmall?.color?.withOpacity(
                            0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  AppLocalizations.of(context)!.notificationTypes,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                _notifTile(
                  context,
                  AppLocalizations.of(context)!.watering,
                  AppLocalizations.of(context)!.wateringDesc,
                  Icons.water_drop,
                  _enabled['penyiraman'] ?? true,
                  (v) => setState(() => _enabled['penyiraman'] = v),
                ),
                _notifTile(
                  context,
                  AppLocalizations.of(context)!.fertilizing,
                  AppLocalizations.of(context)!.fertilizingDesc,
                  Icons.eco,
                  _enabled['pemupukan'] ?? true,
                  (v) => setState(() => _enabled['pemupukan'] = v),
                ),
                _notifTile(
                  context,
                  AppLocalizations.of(context)!.harvest,
                  AppLocalizations.of(context)!.harvestDesc,
                  Icons.agriculture,
                  _enabled['panen'] ?? true,
                  (v) => setState(() => _enabled['panen'] = v),
                ),
                _notifTile(
                  context,
                  AppLocalizations.of(context)!.care,
                  AppLocalizations.of(context)!.careDesc,
                  Icons.healing,
                  _enabled['perawatan'] ?? false,
                  (v) => setState(() => _enabled['perawatan'] = v),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _notifTile(
    BuildContext context,
    String title,
    String desc,
    IconData icon,
    bool enabled,
    ValueChanged<bool> onChanged,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor, width: 0.5),
      ),
      child: SwitchListTile(
        value: enabled,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
          ],
        ),
        subtitle: Text(
          desc,
          style: TextStyle(
            fontSize: 12,
            // ignore: deprecated_member_use
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.85),
          ),
        ),
        activeColor: theme.colorScheme.primary,
      ),
    );
  }
}

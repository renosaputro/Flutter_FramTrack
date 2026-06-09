import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/domain/entities.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/widgets/ft_metric_card.dart';
import '../../../../injection/service_locator.dart';
import 'package:samar_farming/l10n/app_localizations.dart';
import '../../../settings/cubit/settings_cubit.dart';
import '../../../settings/cubit/settings_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthService>();
    final firestore = getIt<FirestoreService>();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(AppLocalizations.of(context)!.profile),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            StreamBuilder<Map<String, dynamic>?>(
              stream: firestore.watchUserProfile(),
              builder: (context, snapshot) {
                String displayName = auth.displayName;
                String? photoUrl = auth.photoUrl;
                if (snapshot.hasData && snapshot.data != null) {
                  final userData = snapshot.data!;
                  displayName = userData['name'] ?? auth.displayName;
                  photoUrl = userData['photoUrl'];
                }

                return InkWell(
                  onTap: () => context.push('/profile/edit'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: photoUrl != null && photoUrl.isNotEmpty
                              ? ClipOval(
                                  child: _isNetworkImage(photoUrl)
                                      ? Image.network(
                                          photoUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              const Icon(
                                                Icons.person,
                                                size: 44,
                                                color: Colors.white,
                                              ),
                                        )
                                      : Image.file(
                                          File(photoUrl),
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, _, _) =>
                                              const Icon(
                                                Icons.person,
                                                size: 44,
                                                color: Colors.white,
                                              ),
                                        ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 44,
                                  color: Colors.white,
                                ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          auth.email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.tapToEditProfile,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            StreamBuilder<List<Crop>>(
              stream: firestore.watchAllCrops(),
              builder: (context, cropSnap) {
                return StreamBuilder<List<HarvestResult>>(
                  stream: firestore.watchAllHarvests(),
                  builder: (context, harvestSnap) {
                    return StreamBuilder<List<FarmField>>(
                      stream: firestore.watchFields(),
                      builder: (context, fieldSnap) {
                        if (cropSnap.connectionState ==
                                ConnectionState.waiting ||
                            harvestSnap.connectionState ==
                                ConnectionState.waiting ||
                            fieldSnap.connectionState ==
                                ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: LinearProgressIndicator()),
                          );
                        }

                        final totalCrops = cropSnap.data?.length ?? 0;
                        final totalHarvests = harvestSnap.data?.length ?? 0;
                        final totalFields = fieldSnap.data?.length ?? 0;

                        return Row(
                          children: [
                            Expanded(
                              child: FtMetricCard(
                                icon: Icons.eco,
                                label: AppLocalizations.of(context)!.plants,
                                value: '$totalCrops',
                                iconColor: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FtMetricCard(
                                icon: Icons.emoji_events,
                                label: AppLocalizations.of(context)!.harvests,
                                value: '$totalHarvests',
                                iconColor: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FtMetricCard(
                                icon: Icons.landscape,
                                label: AppLocalizations.of(context)!.fields,
                                value: '$totalFields',
                                iconColor: AppColors.earth,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            _menuItem(
              context,
              Icons.landscape_outlined,
              AppLocalizations.of(context)!.manageFields,
              AppLocalizations.of(context)!.addManageFields,
              () => context.push('/settings/fields'),
            ),
            _menuItem(
              context,
              Icons.bar_chart,
              AppLocalizations.of(context)!.harvestReport,
              AppLocalizations.of(context)!.viewAnalysis,
              () => context.push('/harvest-history'),
            ),
            _menuItem(
              context,
              Icons.notifications_outlined,
              AppLocalizations.of(context)!.notificationSettings,
              AppLocalizations.of(context)!.setReminders,
              () => context.push('/settings/notifications'),
            ),

            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                return _menuItem(
                  context,
                  Icons.dark_mode_outlined,
                  'Mode Gelap',
                  state.isDarkMode ? 'Aktif' : 'Nonaktif',
                  () => context.push('/settings/dark-mode'),
                );
              },
            ),
            _menuItem(
              context,
              Icons.language,
              AppLocalizations.of(context)!.language,
              AppLocalizations.of(context)!.Indonesia,
              () => context.push('/settings/language'),
            ),
            _menuItem(
              context,
              Icons.info_outline,
              AppLocalizations.of(context)!.aboutApp,
              AppLocalizations.of(context)!.versionLabel('0.1.0'),
              () => context.push('/settings/about'),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) context.go('/login');
                },
                icon: const Icon(Icons.logout, color: AppColors.danger),
                label: Text(
                  AppLocalizations.of(context)!.logout,
                  style: const TextStyle(color: AppColors.danger),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isNetworkImage(String path) {
    final lowerPath = path.toLowerCase();
    return lowerPath.startsWith('http://') || lowerPath.startsWith('https://');
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    final cardColor = theme.cardColor;
    final dividerColor = theme.dividerColor;
    final primarySurface = theme.colorScheme.primaryContainer;
    final primaryColor = theme.colorScheme.primary;
    final titleStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 12,
      // ignore: deprecated_member_use
      color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
    );
    final trailingColor =
        // ignore: deprecated_member_use
        theme.textTheme.bodySmall?.color?.withOpacity(0.6) ?? Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: dividerColor, width: 0.5),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: primarySurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        title: Text(title, style: titleStyle),
        subtitle: Text(subtitle, style: subtitleStyle),
        trailing: Icon(Icons.chevron_right, color: trailingColor),
        onTap: onTap,
      ),
    );
  }
}

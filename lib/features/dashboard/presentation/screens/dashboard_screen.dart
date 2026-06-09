import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/domain/entities.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/widgets/ft_card.dart';
import '../../../../core/widgets/ft_crop_card.dart';
import '../../../../core/widgets/ft_metric_card.dart';
import '../../../../injection/service_locator.dart';
import 'package:samar_farming/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _firestore = getIt<FirestoreService>();
  final _auth = getIt<AuthService>();

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 10) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  String _getWeatherEmoji() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 17) return '☀️';
    return '🌙';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 230,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryDark,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
              title: Text(
                AppLocalizations.of(context)!.appTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${_getGreeting()}, ${_auth.displayName}! 👋',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat(
                                      'EEEE, d MMMM yyyy',
                                      'id',
                                    ).format(DateTime.now()),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            StreamBuilder<Map<String, dynamic>?>(
                              stream: _firestore.watchUserProfile(),
                              builder: (context, snap) {
                                final photoUrl =
                                    (snap.data != null
                                        ? snap.data!['photoUrl'] as String?
                                        : null) ??
                                    _auth.currentUser?.photoURL;
                                ImageProvider<Object>? img;
                                if (photoUrl != null && photoUrl.isNotEmpty) {
                                  if (photoUrl.startsWith('http')) {
                                    img = NetworkImage(photoUrl);
                                  } else {
                                    final file = File(photoUrl);
                                    if (file.existsSync()) {
                                      img = FileImage(file);
                                    }
                                  }
                                }
                                return GestureDetector(
                                  onTap: () => context.push('/profile'),
                                  child: CircleAvatar(
                                    radius: 22,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    backgroundImage: img,
                                    child: img == null
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                _getWeatherEmoji(),
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                '28°C • Cerah',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '💧 65%',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '🌱 ${AppLocalizations.of(context)!.activePlantsLabel}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () => context.go('/crops'),
                    child: const Text('Lihat Semua'),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 190,
              child: StreamBuilder<List<Crop>>(
                stream: _firestore.watchActiveCrops(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final crops = snapshot.data ?? [];
                  if (crops.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.eco_outlined,
                            size: 40,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            AppLocalizations.of(context)!.noPlants,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => context.push('/crop/add'),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(AppLocalizations.of(context)!.addPlant),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: crops.length,
                    itemBuilder: (context, index) => FtCropCard(
                      crop: crops[index],
                      isCompact: true,
                      onTap: () => context.push('/crop/${crops[index].id}'),
                    ),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                '📊 Ringkasan',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: StreamBuilder<List<Crop>>(
                stream: _firestore.watchAllCrops(),
                builder: (context, cropSnap) {
                  final allCrops = cropSnap.data ?? [];
                  final activeCrops = allCrops
                      .where(
                        (c) => c.lifecycleStatus != CropLifecycleStatus.selesai,
                      )
                      .length;
                  return StreamBuilder<List<HarvestResult>>(
                    stream: _firestore.watchAllHarvests(),
                    builder: (context, harvestSnap) {
                      final harvests = harvestSnap.data ?? [];
                      return StreamBuilder<List<FarmField>>(
                        stream: _firestore.watchFields(),
                        builder: (context, fieldSnap) {
                          final fields = fieldSnap.data ?? [];
                          return Row(
                            children: [
                              Expanded(
                                child: FtMetricCard(
                                  icon: Icons.eco,
                                  label: 'Tanaman Aktif',
                                  value: '$activeCrops',
                                  iconColor: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FtMetricCard(
                                  icon: Icons.emoji_events,
                                  label: 'Total Panen',
                                  value: '${harvests.length}',
                                  iconColor: AppColors.secondary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FtMetricCard(
                                  icon: Icons.landscape,
                                  label: 'Lahan',
                                  value: '${fields.length}',
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
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text(
                '🔔 Pengingat Mendatang',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: StreamBuilder<List<FarmReminder>>(
              stream: _firestore.watchActiveReminders(),
              builder: (context, snapshot) {
                final reminders = snapshot.data ?? [];
                if (reminders.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: FtCard(
                      margin: EdgeInsets.zero,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Tidak ada pengingat aktif',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: reminders.take(3).map((reminder) {
                    return FtCard(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryLight.withValues(
                                alpha: 0.3,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              reminder.isOtomatis
                                  ? Icons.auto_awesome
                                  : Icons.notifications_outlined,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  reminder.judul,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                if (reminder.deskripsi != null)
                                  Text(
                                    reminder.deskripsi!,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          if (reminder.isOtomatis)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Auto',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/domain/entities.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/widgets/ft_chip.dart';
import '../../../../core/widgets/ft_progress_bar.dart';
import '../../../../core/widgets/ft_metric_card.dart';
import '../../../../core/widgets/ft_card.dart';
import '../../../../injection/service_locator.dart';

class CropDetailScreen extends StatelessWidget {
  final String cropId;
  const CropDetailScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context) {
    final firestore = getIt<FirestoreService>();

    return StreamBuilder<Crop?>(
      stream: firestore.watchActiveCrops().map((crops) {
        try { return crops.firstWhere((c) => c.id == cropId); } catch (_) { return null; }
      }),
      builder: (context, cropSnap) {
        if (cropSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (cropSnap.data == null) {
          return FutureBuilder<Crop?>(
            future: firestore.getCrop(cropId),
            builder: (ctx, futureSnap) {
              if (futureSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              final crop = futureSnap.data;
              if (crop == null) {
                return Scaffold(appBar: AppBar(), body: const Center(child: Text('Tanaman tidak ditemukan')));
              }
              return _buildContent(context, crop, firestore);
            },
          );
        }

        return _buildContent(context, cropSnap.data!, firestore);
      },
    );
  }

  Widget _buildContent(BuildContext context, Crop crop, FirestoreService firestore) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200, pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: AppColors.headerGradient),
                child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: 60),
                  Text(_getEmoji(crop.jenisTanaman), style: const TextStyle(fontSize: 64)),
                  const SizedBox(height: 8),
                  Text(crop.nama, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  Text('${crop.jenisTanaman} • ${crop.varietas}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                ])),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Wrap(spacing: 8, runSpacing: 8, children: [
                FtChip.health(crop.healthStatus),
                FtChip.lifecycle(crop.lifecycleStatus),
                FtChip(label: 'Hari ke-${crop.hariKe}', icon: Icons.calendar_today, backgroundColor: const Color(0xFFE3F2FD), textColor: AppColors.info),
                if (crop.namaLahan != null) FtChip(label: crop.namaLahan!, icon: Icons.location_on_outlined, backgroundColor: const Color(0xFFEFEBE9), textColor: AppColors.earth),
              ])),
          ),
          SliverToBoxAdapter(
            child: FtCard(margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Progress ke Panen', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 12),
                FtProgressBar(progress: crop.progress, height: 10, label: '${crop.sisaHariPanen} hari lagi'),
              ])),
          ),
          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(children: [
                Expanded(child: FtMetricCard(icon: Icons.straighten, label: 'Tinggi', value: '${crop.tinggiBatang ?? 0} cm', iconColor: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: FtMetricCard(icon: Icons.spa, label: 'Daun', value: '${crop.jumlahDaun ?? 0}', iconColor: AppColors.success)),
                const SizedBox(width: 12),
                Expanded(child: FtMetricCard(icon: Icons.photo_library, label: 'Foto', value: '${crop.fotoTimeline.length}', iconColor: AppColors.info)),
              ])),
          ),

          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 8), child: Text('📝 Log Aktivitas', style: Theme.of(context).textTheme.titleLarge))),
          SliverToBoxAdapter(
            child: StreamBuilder<List<ActivityLog>>(
              stream: firestore.watchActivities(cropId),
              builder: (context, snapshot) {
                final logs = snapshot.data ?? [];
                if (logs.isEmpty) {
                  return const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('Belum ada log aktivitas', style: TextStyle(color: AppColors.textSecondary))));
                }
                return Column(children: logs.map((log) => FtCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(children: [
                    Container(width: 4, height: 40, decoration: BoxDecoration(color: _actColor(log.tipe), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [FtChip.activity(log.tipe), const Spacer(), Text(_formatDate(log.tanggal), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary))]),
                      if (log.catatan != null) ...[const SizedBox(height: 4), Text(log.catatan!, style: const TextStyle(fontSize: 13))],
                    ])),
                  ]),
                )).toList());
              },
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
              Expanded(child: ElevatedButton.icon(onPressed: () => context.push('/crop/$cropId/activity?nama=${Uri.encodeComponent(crop.nama)}'), icon: const Icon(Icons.add), label: const Text('Log Aktivitas'))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(
                onPressed: () => context.push('/crop/$cropId/harvest'),
                icon: const Icon(Icons.agriculture), label: const Text('Panen'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.secondary, side: const BorderSide(color: AppColors.secondary)),
              )),
            ])),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  String _getEmoji(String jenis) {
    final map = {'Cabai': '🌶️', 'Tomat': '🍅', 'Selada': '🥬', 'Kangkung': '🥬', 'Basil': '🌿', 'Jagung': '🌽'};
    for (final e in map.entries) { if (jenis.contains(e.key)) return e.value; }
    return '🌱';
  }

  Color _actColor(ActivityType t) {
    switch (t) { case ActivityType.penyiraman: return AppColors.info; case ActivityType.pemupukan: return AppColors.success;
      case ActivityType.pestisida: return AppColors.danger; case ActivityType.penyiangan: return AppColors.earth; default: return AppColors.textSecondary; }
  }

  String _formatDate(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Hari ini'; if (diff == 1) return 'Kemarin'; return '$diff hari lalu';
  }
}

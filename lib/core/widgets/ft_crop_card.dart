import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/domain/entities.dart';
import 'ft_chip.dart';
import 'ft_progress_bar.dart';

class FtCropCard extends StatelessWidget {
  final Crop crop;
  final VoidCallback? onTap;
  final bool isCompact;

  const FtCropCard({
    super.key,
    required this.crop,
    this.onTap,
    this.isCompact = false,
  });

  String _getEmoji(String jenis) {
    final emojiMap = {
      'Cabai': '🌶️', 'Tomat': '🍅', 'Selada': '🥬', 'Kangkung': '🥬',
      'Bayam': '🥬', 'Sawi': '🥬', 'Terong': '🍆', 'Mentimun': '🥒',
      'Wortel': '🥕', 'Brokoli': '🥦', 'Jagung': '🌽', 'Padi': '🌾',
      'Semangka': '🍉', 'Stroberi': '🍓', 'Basil': '🌿', 'Mint': '🌿',
      'Bawang': '🧅', 'Jahe': '🫚',
    };
    for (final entry in emojiMap.entries) {
      if (jenis.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return '🌱';
  }

  @override
  Widget build(BuildContext context) {
    if (isCompact) return _buildCompact(context);
    return _buildFull(context);
  }

  Widget _buildCompact(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkElevated : AppColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getEmoji(crop.jenisTanaman),
                      style: const TextStyle(fontSize: 28),
                    ),
                    _healthDot(crop.healthStatus),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  crop.nama,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  crop.jenisTanaman,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                // Progress
                FtProgressBar(
                  progress: crop.progress,
                  height: 6,
                  showPercentage: false,
                ),
                const SizedBox(height: 4),
                Text(
                  '${crop.sisaHariPanen} hari lagi',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFull(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? AppColors.darkElevated : AppColors.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      _getEmoji(crop.jenisTanaman),
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              crop.nama,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          FtChip.health(crop.healthStatus),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${crop.jenisTanaman} • ${crop.namaLahan ?? "Tanpa lahan"}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: FtProgressBar(
                              progress: crop.progress,
                              height: 6,
                              showPercentage: false,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(crop.progress * 100).round()}%',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _healthDot(CropHealthStatus status) {
    Color color;
    switch (status) {
      case CropHealthStatus.sehat:
        color = AppColors.success;
        break;
      case CropHealthStatus.hamaPenyakit:
        color = AppColors.danger;
        break;
      case CropHealthStatus.layu:
        color = AppColors.warning;
        break;
      case CropHealthStatus.tidakDiketahui:
        color = AppColors.disabled;
        break;
    }
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
        ],
      ),
    );
  }
}

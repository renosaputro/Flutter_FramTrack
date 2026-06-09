import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/domain/entities.dart';

class FtChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const FtChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  factory FtChip.health(CropHealthStatus status) {
    switch (status) {
      case CropHealthStatus.sehat:
        return const FtChip(
          label: 'Sehat',
          backgroundColor: Color(0xFFE8F5E9),
          textColor: AppColors.success,
          icon: Icons.check_circle_outline,
        );
      case CropHealthStatus.hamaPenyakit:
        return const FtChip(
          label: 'Hama/Penyakit',
          backgroundColor: Color(0xFFFFEBEE),
          textColor: AppColors.danger,
          icon: Icons.bug_report_outlined,
        );
      case CropHealthStatus.layu:
        return const FtChip(
          label: 'Layu',
          backgroundColor: Color(0xFFFFF3E0),
          textColor: AppColors.warning,
          icon: Icons.warning_amber_outlined,
        );
      case CropHealthStatus.tidakDiketahui:
        return const FtChip(
          label: 'Belum Dicek',
          backgroundColor: Color(0xFFF5F5F5),
          textColor: AppColors.textSecondary,
          icon: Icons.help_outline,
        );
    }
  }

  factory FtChip.lifecycle(CropLifecycleStatus status) {
    switch (status) {
      case CropLifecycleStatus.semai:
        return const FtChip(
          label: 'Semai',
          backgroundColor: Color(0xFFE3F2FD),
          textColor: AppColors.info,
          icon: Icons.eco_outlined,
        );
      case CropLifecycleStatus.vegetatif:
        return const FtChip(
          label: 'Vegetatif',
          backgroundColor: Color(0xFFE8F5E9),
          textColor: AppColors.primary,
          icon: Icons.spa_outlined,
        );
      case CropLifecycleStatus.generatif:
        return const FtChip(
          label: 'Generatif',
          backgroundColor: Color(0xFFFFF8E1),
          textColor: AppColors.secondary,
          icon: Icons.local_florist_outlined,
        );
      case CropLifecycleStatus.panen:
        return const FtChip(
          label: 'Siap Panen',
          backgroundColor: Color(0xFFFFF3E0),
          textColor: AppColors.secondaryDark,
          icon: Icons.agriculture_outlined,
        );
      case CropLifecycleStatus.selesai:
        return const FtChip(
          label: 'Selesai',
          backgroundColor: Color(0xFFEFEBE9),
          textColor: AppColors.earth,
          icon: Icons.done_all,
        );
    }
  }

  factory FtChip.activity(ActivityType tipe) {
    switch (tipe) {
      case ActivityType.penyiraman:
        return const FtChip(label: '💧 Siram', backgroundColor: Color(0xFFE3F2FD), textColor: AppColors.info);
      case ActivityType.pemupukan:
        return const FtChip(label: '🌱 Pupuk', backgroundColor: Color(0xFFE8F5E9), textColor: AppColors.success);
      case ActivityType.pestisida:
        return const FtChip(label: '🛡️ Pestisida', backgroundColor: Color(0xFFFFEBEE), textColor: AppColors.danger);
      case ActivityType.penyiangan:
        return const FtChip(label: '🌿 Siang', backgroundColor: Color(0xFFFFF8E1), textColor: AppColors.earth);
      case ActivityType.pemangkasan:
        return const FtChip(label: '✂️ Pangkas', backgroundColor: Color(0xFFF3E5F5), textColor: Color(0xFF7B1FA2));
      case ActivityType.lainnya:
        return const FtChip(label: '📝 Lainnya', backgroundColor: Color(0xFFF5F5F5), textColor: AppColors.textSecondary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primarySurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor ?? AppColors.primary),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor ?? AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

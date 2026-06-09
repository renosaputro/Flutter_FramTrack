import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/domain/entities.dart';

class FtTaskTile extends StatefulWidget {
  final DailyTask task;
  final ValueChanged<bool>? onToggle;

  const FtTaskTile({
    super.key,
    required this.task,
    this.onToggle,
  });

  @override
  State<FtTaskTile> createState() => _FtTaskTileState();
}

class _FtTaskTileState extends State<FtTaskTile> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getActivityIcon(ActivityType tipe) {
    switch (tipe) {
      case ActivityType.penyiraman:
        return Icons.water_drop_outlined;
      case ActivityType.pemupukan:
        return Icons.eco_outlined;
      case ActivityType.pestisida:
        return Icons.bug_report_outlined;
      case ActivityType.penyiangan:
        return Icons.grass_outlined;
      case ActivityType.pemangkasan:
        return Icons.content_cut_outlined;
      case ActivityType.lainnya:
        return Icons.note_outlined;
    }
  }

  Color _getActivityColor(ActivityType tipe) {
    switch (tipe) {
      case ActivityType.penyiraman:
        return AppColors.info;
      case ActivityType.pemupukan:
        return AppColors.success;
      case ActivityType.pestisida:
        return AppColors.danger;
      case ActivityType.penyiangan:
        return AppColors.earth;
      case ActivityType.pemangkasan:
        return const Color(0xFF7B1FA2);
      case ActivityType.lainnya:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.task.selesai;
    final color = _getActivityColor(widget.task.tipe);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: isDone
            ? AppColors.primarySurface.withValues(alpha: 0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _controller.forward(from: 0);
            widget.onToggle?.call(!isDone);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isDone ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDone ? AppColors.primary : AppColors.divider,
                        width: 2,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getActivityIcon(widget.task.tipe),
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.deskripsi,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          decoration: isDone ? TextDecoration.lineThrough : null,
                          color: isDone ? AppColors.textHint : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.task.cropNama,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
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
    );
  }
}

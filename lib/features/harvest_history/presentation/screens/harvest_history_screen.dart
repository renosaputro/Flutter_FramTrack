import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/domain/entities.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/widgets/ft_metric_card.dart';
import '../../../../injection/service_locator.dart';

class HarvestHistoryScreen extends StatelessWidget {
  const HarvestHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = getIt<FirestoreService>();

    return Scaffold(
      appBar: AppBar(title: const Text('Analisis Panen')),
      body: StreamBuilder<List<HarvestResult>>(
        stream: firestore.watchAllHarvests(),
        builder: (context, snapshot) {
          final theme = Theme.of(context);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Data Panen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Panen tanaman pertamamu untuk melihat analytics',
                    style: TextStyle(
                      // ignore: deprecated_member_use
                      color: theme.textTheme.bodySmall?.color?.withOpacity(
                        0.85,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final totalBerat = history.fold<double>(
            0,
            (sum, h) => sum + h.beratKg,
          );
          final avgRating =
              history.fold<int>(0, (sum, h) => sum + h.rating) / history.length;

          final chartGradient = LinearGradient(
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer,
            ],
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FtMetricCard(
                        icon: Icons.scale,
                        label: 'Total Panen',
                        value: '${totalBerat.toStringAsFixed(1)} Kg',
                        iconColor: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FtMetricCard(
                        icon: Icons.star,
                        label: 'Rata-rata',
                        value: '${avgRating.toStringAsFixed(1)} ⭐',
                        iconColor: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FtMetricCard(
                        icon: Icons.repeat,
                        label: 'Total Sesi',
                        value: '${history.length}',
                        iconColor: theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '📊 Perbandingan Panen',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Container(
                  height: 500,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor, width: 0.5),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (totalBerat / history.length * 100).clamp(500, 2000),
                      barTouchData: BarTouchData(enabled: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text(
                              'Sesi ${v.toInt() + 1}',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.textTheme.bodySmall?.color
                                    // ignore: deprecated_member_use
                                    ?.withOpacity(0.85),
                              ),
                            ),
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}',
                              style: TextStyle(
                                fontSize: 10,
                                color: theme.textTheme.bodySmall?.color
                                    // ignore: deprecated_member_use
                                    ?.withOpacity(0.85),
                              ),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 5,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: theme.dividerColor, strokeWidth: 0.5),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: history
                          .asMap()
                          .entries
                          .map(
                            (e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value.beratKg,
                                  width: 28,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                  gradient: chartGradient,
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '📋 Riwayat Detail',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...history.map(
                  (h) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.dividerColor, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.agriculture,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${h.beratKg} Kg — ${h.kualitas}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${'⭐' * h.rating}  ${h.catatan ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: theme.textTheme.bodySmall?.color
                                      // ignore: deprecated_member_use
                                      ?.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (h.totalPendapatan != null)
                          Text(
                            'Rp ${(h.totalPendapatan! / 1000).toStringAsFixed(0)}K',
                            style: TextStyle(
                              color: theme.colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

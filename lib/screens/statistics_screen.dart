import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final health = Provider.of<HealthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    final body = ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 100),
      children: [
        SafeArea(
          bottom: false,
          child: const Text('Thống kê & Xu hướng 📊',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        ),
        const SizedBox(height: 20),

        // Water Chart Card
        _ChartCard(
          title: 'Lượng nước 7 ngày qua (ml)',
          color: AppColors.appleBlue,
          cardBg: cardBg,
          isDark: isDark,
          spots: health.weeklyWaterSpots,
          unit: 'ml',
        ),
        const SizedBox(height: 16),

        // Sleep Chart Card
        _ChartCard(
          title: 'Thời lượng giấc ngủ 7 ngày qua (giờ)',
          color: AppColors.applePurple,
          cardBg: cardBg,
          isDark: isDark,
          spots: health.weeklySleepSpots,
          unit: 'h',
        ),
        const SizedBox(height: 16),

        // Activity Chart Card
        _ChartCard(
          title: 'Thời gian vận động 7 ngày qua (phút)',
          color: AppColors.appleRed,
          cardBg: cardBg,
          isDark: isDark,
          spots: health.weeklyActivitySpots,
          unit: 'phút',
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: body)) : body,
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Color color;
  final Color cardBg;
  final bool isDark;
  final List<FlSpot> spots;
  final String unit;

  const _ChartCard({
    required this.title,
    required this.color,
    required this.cardBg,
    required this.isDark,
    required this.spots,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final validSpots = spots.isNotEmpty
        ? spots
        : const [FlSpot(0, 0), FlSpot(1, 0), FlSpot(2, 0), FlSpot(3, 0), FlSpot(4, 0), FlSpot(5, 0), FlSpot(6, 0)];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10, color: AppColors.label3),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                        final idx = value.toInt() % 7;
                        return Text(
                          days[idx],
                          style: const TextStyle(fontSize: 11, color: AppColors.label2),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: validSpots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

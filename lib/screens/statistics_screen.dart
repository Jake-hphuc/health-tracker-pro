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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
        appBar: AppBar(
          title: const Text('Thống kê 📈'),
          elevation: 0,
          backgroundColor: Colors.transparent,
          bottom: TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: AppColors.appleGreen,
            labelColor: isDark ? Colors.white : Colors.black,
            unselectedLabelColor: AppColors.label2,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Cân nặng'),
              Tab(text: 'Nước uống'),
              Tab(text: 'Vận động'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildChartTab(
              context,
              title: 'Biểu đồ xu hướng cân nặng',
              subtitle: 'Lịch sử cân nặng và chỉ số cơ thể',
              child: _buildWeightChart(health, isDark),
              isWide: isWide,
              isDark: isDark,
            ),
            _buildChartTab(
              context,
              title: 'Lượng nước hôm nay',
              subtitle: 'Thực tế so với mục tiêu hàng ngày',
              child: _buildWaterChart(health, isDark),
              isWide: isWide,
              isDark: isDark,
              legend: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Thực tế (${health.todayWaterTotal} ml)', AppColors.appleBlue),
                  const SizedBox(width: 24),
                  _buildLegendItem('Mục tiêu (${health.goal.waterGoal} ml)', isDark ? AppColors.card3 : Colors.grey.shade300),
                ],
              ),
            ),
            _buildChartTab(
              context,
              title: 'Thời gian vận động',
              subtitle: 'Phút thể thao hôm nay so với mục tiêu',
              child: _buildActivityChart(health, isDark),
              isWide: isWide,
              isDark: isDark,
              legend: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Thực tế (${health.todayActivityMinutes} phút)', AppColors.appleRed),
                  const SizedBox(width: 24),
                  _buildLegendItem('Mục tiêu (${health.goal.activityGoal} phút)', isDark ? AppColors.card3 : Colors.grey.shade300),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartTab(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
    required bool isWide,
    required bool isDark,
    Widget? legend,
  }) {
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    Widget content = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: AppColors.label2),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 260,
                  child: child,
                ),
                if (legend != null) ...[
                  const SizedBox(height: 24),
                  legend,
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (isWide) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: content,
        ),
      );
    }
    return content;
  }

  Widget _buildWeightChart(HealthProvider health, bool isDark) {
    final records = health.weightHistory;

    if (records.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có đủ dữ liệu cân nặng để vẽ biểu đồ',
          style: TextStyle(color: AppColors.label2),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < records.length; i++) {
      spots.add(FlSpot(i.toDouble(), records[i].weight));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: isDark ? AppColors.separator : Colors.grey.shade200,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < records.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      records[index].date.substring(0, 5),
                      style: const TextStyle(color: AppColors.label2, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(1)} ',
                  style: const TextStyle(color: AppColors.label2, fontSize: 10, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.appleOrange,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: AppColors.appleOrange,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.appleOrange.withValues(alpha: 0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterChart(HealthProvider health, bool isDark) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Hôm nay',
                      style: TextStyle(color: AppColors.label2, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} ml',
                  style: const TextStyle(color: AppColors.label2, fontSize: 10, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: health.todayWaterTotal.toDouble(),
                color: AppColors.appleBlue,
                width: 28,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              BarChartRodData(
                toY: health.goal.waterGoal.toDouble(),
                color: isDark ? AppColors.card3 : Colors.grey.shade300,
                width: 28,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityChart(HealthProvider health, bool isDark) {
    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() == 0) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Hôm nay',
                      style: TextStyle(color: AppColors.label2, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} ph',
                  style: const TextStyle(color: AppColors.label2, fontSize: 10, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: health.todayActivityMinutes.toDouble(),
                color: AppColors.appleRed,
                width: 28,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              BarChartRodData(
                toY: health.goal.activityGoal.toDouble(),
                color: isDark ? AppColors.card3 : Colors.grey.shade300,
                width: 28,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.label2),
        ),
      ],
    );
  }
}

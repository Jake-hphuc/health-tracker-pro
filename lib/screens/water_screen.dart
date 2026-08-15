import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../widgets/activity_ring.dart';
import '../utils/constants.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final health = Provider.of<HealthProvider>(context);
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final isWide  = AppConstants.isWide(context);

    final current = health.todayWaterTotal;
    final target  = health.goal.waterGoal;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.5) : 0.0;

    final body = CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              child: const Text('Nước uống 💧',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ),
          ),
        ),

        // Ring + Goal
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: SingleRingWidget(
                progress:    progress,
                ringColor:   AppColors.appleBlue,
                ringBgColor: AppColors.appleBlue.withValues(alpha: 0.15),
                size:        200,
                strokeWidth: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$current',
                      style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        color: AppColors.appleBlue,
                        letterSpacing: -1,
                      )),
                    Text('/ $target ml',
                      style: const TextStyle(fontSize: 14, color: AppColors.label2)),
                    const SizedBox(height: 4),
                    Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.appleBlue)),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Quick add buttons
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Thêm nhanh lượng nước',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _QuickButton(label: '+150 ml', amount: 150, color: AppColors.appleBlue, isDark: isDark),
                    const SizedBox(width: 8),
                    _QuickButton(label: '+250 ml', amount: 250, color: AppColors.appleBlue, isDark: isDark),
                    const SizedBox(width: 8),
                    _QuickButton(label: '+500 ml', amount: 500, color: AppColors.appleBlue, isDark: isDark),
                    const SizedBox(width: 8),
                    _QuickButton(label: '+750 ml', amount: 750, color: AppColors.appleBlue, isDark: isDark),
                  ],
                ),
              ],
            ),
          ),
        ),

        // History
        SliverPadding(
          padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 24, isWide ? 28 : 20, 100),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Lịch sử hôm nay',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
                const SizedBox(height: 12),
                if (health.todayWaterList.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text('Chưa có dữ liệu hôm nay\nHãy bắt đầu uống ly nước đầu tiên! 💧',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.label2, height: 1.5)),
                    ),
                  )
                else
                  ...health.todayWaterList.map((item) => Dismissible(
                    key: Key('water_${item.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppColors.appleRed,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    onDismissed: (_) => health.deleteWater(item.id!),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.card1 : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.appleBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.water_drop_rounded,
                              color: AppColors.appleBlue, size: 18),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(item.time,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                          Text('+${item.amount} ml',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.appleBlue,
                            )),
                        ],
                      ),
                    ),
                  )),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: body)) : body,
    );
  }
}

class _QuickButton extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  final bool isDark;

  const _QuickButton({
    required this.label,
    required this.amount,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Provider.of<HealthProvider>(context, listen: false).addWater(amount);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã thêm $amount ml nước! 💧'),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppColors.card1 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Text(label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            )),
        ),
      ),
    );
  }
}

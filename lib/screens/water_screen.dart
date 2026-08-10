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
                color:       AppColors.appleBlue,
                size:        isWide ? 220 : 190,
                strokeWidth: 22,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.water_drop_rounded, color: AppColors.appleBlue, size: 22),
                    const SizedBox(height: 6),
                    Text('$current',
                      style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w800,
                        letterSpacing: -1.5, color: Colors.white)),
                    Text('/ $target ml',
                      style: const TextStyle(fontSize: 12, color: AppColors.label2, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Status text
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
            child: Text(
              progress >= 1.0
                  ? '🎉 Xuất sắc! Đã đạt mục tiêu hôm nay!'
                  : 'Cần uống thêm ${(target - current).clamp(0, target)} ml nữa',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: progress >= 1.0 ? AppColors.appleGreen : AppColors.appleBlue),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Quick add buttons
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Thêm nhanh',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : Colors.black)),
                const SizedBox(height: 12),
                Row(
                  children: AppConstants.waterAmounts.map((amount) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => health.addWater(amount),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.appleBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.appleBlue.withValues(alpha: 0.3), width: 1),
                          ),
                          child: Column(
                            children: [
                              const Icon(Icons.add, color: AppColors.appleBlue, size: 18),
                              const SizedBox(height: 4),
                              Text('$amount ml',
                                style: const TextStyle(
                                  color: AppColors.appleBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),

        // Log title
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
            child: Text('Nhật ký hôm nay',
              style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700,
                color: isDark ? AppColors.white : Colors.black)),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Log list
        health.todayWaterList.isEmpty
            ? SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text('Chưa có dữ liệu uống nước hôm nay',
                      style: TextStyle(color: AppColors.label2))),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final item = health.todayWaterList[i];
                    return _WaterLogTile(
                      amount:  item.amount,
                      time:    item.time,
                      isDark:  isDark,
                      isWide:  isWide,
                      onDelete: () => health.deleteWater(item.id!),
                    );
                  },
                  childCount: health.todayWaterList.length,
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide
          ? Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600), child: body))
          : body,
    );
  }
}

class _WaterLogTile extends StatelessWidget {
  final int amount;
  final String time;
  final bool isDark;
  final bool isWide;
  final VoidCallback onDelete;

  const _WaterLogTile({
    required this.amount, required this.time,
    required this.isDark, required this.isWide, required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 0, isWide ? 28 : 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.card1 : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.appleBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.water_drop_rounded, color: AppColors.appleBlue, size: 18),
          ),
          title: Text('+$amount ml',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          subtitle: Text('Lúc $time',
            style: const TextStyle(fontSize: 12, color: AppColors.label2)),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
              color: AppColors.appleRed, size: 20),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}

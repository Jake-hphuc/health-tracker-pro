import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/health_provider.dart';
import '../models/athlete_plan.dart';
import '../utils/constants.dart';

class KolPlansScreen extends StatelessWidget {
  const KolPlansScreen({super.key});

  void _showPlanDetail(BuildContext context, AthletePlan plan) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final challengeProv = Provider.of<ChallengeProvider>(context, listen: false);
    final healthProv = Provider.of<HealthProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.card1 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (ctx, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.separator : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Header Info
                  Row(
                    children: [
                      Text(
                        plan.avatarEmoji,
                        style: const TextStyle(fontSize: 48),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plan.role,
                              style: TextStyle(fontSize: 13, color: plan.themeColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: plan.themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '💬 "${plan.proTip}"',
                      style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: plan.themeColor, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Targets Row
                  const Text('🎯 Mục tiêu Hàng ngày của Idols', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _TargetPill(label: 'Nước uống', value: '${plan.dailyWaterMl} ml', color: AppColors.appleBlue),
                      const SizedBox(width: 8),
                      _TargetPill(label: 'Giấc ngủ', value: '${plan.dailySleepHours} giờ', color: AppColors.applePurple),
                      const SizedBox(width: 8),
                      _TargetPill(label: 'Vận động', value: '${plan.dailyActivityMinutes} ph', color: AppColors.appleRed),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Workout Routine Section
                  _buildSectionHeader('🏃 Lịch Tập Luyện Ngày', plan.themeColor),
                  const SizedBox(height: 10),
                  ...plan.workoutRoutine.map((item) => _buildDetailBullet(item, isDark)),
                  const SizedBox(height: 20),

                  // Meal Plan Section
                  _buildSectionHeader('🥗 Thực Đơn Bữa Ăn chuẩn', AppColors.appleGreen),
                  const SizedBox(height: 10),
                  ...plan.mealPlan.map((item) => _buildDetailBullet(item, isDark)),
                  const SizedBox(height: 20),

                  // Sleep Tips Section
                  _buildSectionHeader('🌙 Bí Quyết Giấc Ngủ & Phục Hồi', AppColors.applePurple),
                  const SizedBox(height: 10),
                  ...plan.sleepTips.map((item) => _buildDetailBullet(item, isDark)),
                  const SizedBox(height: 28),

                  // Apply Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        challengeProv.applyAthletePlan(plan.id);
                        healthProv.updateGoal(
                          waterGoal: plan.dailyWaterMl,
                          sleepGoal: plan.dailySleepHours,
                          activityGoal: plan.dailyActivityMinutes,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('⚡ Đã áp dụng mục tiêu sức khỏe của ${plan.name}!'),
                            backgroundColor: plan.themeColor,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: plan.themeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        'ÁP DỤNG LỊCH TRÌNH CỦA ${plan.name.toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDetailBullet(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(text, style: const TextStyle(fontSize: 13, height: 1.4)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challengeProv = Provider.of<ChallengeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    Widget body = CustomScrollView(
      slivers: [
        // App Bar Header
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KOLs & Vận động viên 🌟',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Khám phá & áp dụng lịch tập, bữa ăn chuẩn các ngôi sao thể thao',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.label2 : AppColors.subtitleLight,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Athlete Cards Grid / List
        SliverPadding(
          padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 0, isWide ? 28 : 20, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final athlete = challengeProv.athletePlans[index];
                final isApplied = challengeProv.activeAthletePlanId == athlete.id;

                return Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isApplied ? athlete.themeColor : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: athlete.themeColor.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: athlete.themeColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                athlete.avatarEmoji,
                                style: const TextStyle(fontSize: 32),
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
                                    Text(
                                      athlete.name,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    if (isApplied) ...[
                                      const SizedBox(width: 6),
                                      const Icon(Icons.check_circle_rounded, color: AppColors.appleGreen, size: 18),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  athlete.role,
                                  style: TextStyle(fontSize: 12, color: athlete.themeColor, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        athlete.tagline,
                        style: const TextStyle(fontSize: 13, color: AppColors.label2, height: 1.3),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _MiniTag(text: '${athlete.dailyWaterMl}ml Nước', color: AppColors.appleBlue),
                              const SizedBox(width: 6),
                              _MiniTag(text: '${athlete.dailySleepHours}h Ngủ', color: AppColors.applePurple),
                              const SizedBox(width: 6),
                              _MiniTag(text: '${athlete.dailyActivityMinutes}ph Tập', color: AppColors.appleRed),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () => _showPlanDetail(context, athlete),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: athlete.themeColor,
                              side: BorderSide(color: athlete.themeColor, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text('Xem Chi Tiết', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              childCount: challengeProv.athletePlans.length,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: body,
              ),
            )
          : body,
    );
  }
}

class _TargetPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TargetPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.label2)),
          ],
        ),
      ),
    );
  }
}

class _MiniTag extends StatelessWidget {
  final String text;
  final Color color;

  const _MiniTag({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

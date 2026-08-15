import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/health_provider.dart';
import '../models/athlete_plan.dart';
import '../utils/constants.dart';

class KolPlansScreen extends StatelessWidget {
  const KolPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final plans = challengeProvider.athletePlans;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);

    final body = ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 100),
      children: [
        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.appleGreen.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.stars_rounded, color: AppColors.appleGreen, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kế Hoạch KOLs & VĐV',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                        Text(
                          'Luyện tập & sinh hoạt theo vận động viên hàng đầu',
                          style: TextStyle(fontSize: 12, color: AppColors.label2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ...plans.map((plan) {
          final isApplied = challengeProvider.appliedPlanId == plan.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card1 : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: isApplied
                  ? Border.all(color: plan.themeColor, width: 2)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: plan.themeColor.withValues(alpha: isDark ? 0.15 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Avatar & Role
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: plan.themeColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(plan.avatarEmoji, style: const TextStyle(fontSize: 28)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              plan.name,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              plan.role,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: plan.themeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isApplied)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: plan.themeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded, size: 14, color: plan.themeColor),
                              const SizedBox(width: 4),
                              Text(
                                'Đang Áp Dụng',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: plan.themeColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pro tip quote
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💬 ', style: TextStyle(fontSize: 14)),
                        Expanded(
                          child: Text(
                            '"${plan.proTip}"',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontStyle: FontStyle.italic,
                              color: AppColors.label1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Target metrics preview
                  Row(
                    children: [
                      _MetricBadge(
                        icon: Icons.water_drop_rounded,
                        color: AppColors.appleBlue,
                        value: '${plan.dailyWaterMl} ml',
                        label: 'Nước uống',
                      ),
                      const SizedBox(width: 8),
                      _MetricBadge(
                        icon: Icons.bedtime_rounded,
                        color: AppColors.applePurple,
                        value: '${plan.dailySleepHours}h',
                        label: 'Giấc ngủ',
                      ),
                      const SizedBox(width: 8),
                      _MetricBadge(
                        icon: Icons.local_fire_department_rounded,
                        color: AppColors.appleRed,
                        value: '${plan.dailyActivityMinutes}p',
                        label: 'Vận động',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Details Expansion Button & Apply Button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _showPlanDetails(context, plan),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? AppColors.separator : Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Xem Chi Tiết', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            challengeProvider.applyAthletePlan(plan.id);
                            healthProvider.updateGoals(
                              water: plan.dailyWaterMl,
                              sleep: plan.dailySleepHours,
                              activity: plan.dailyActivityMinutes,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Đã áp dụng mục tiêu của ${plan.name}! ⭐'),
                                backgroundColor: plan.themeColor,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: plan.themeColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            isApplied ? 'Đã Áp Dụng' : 'Áp Dụng Kế Hoạch',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: body)) : body,
    );
  }

  void _showPlanDetails(BuildContext context, AthletePlan plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? AppColors.card1 : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.label3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(plan.avatarEmoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                        Text(plan.role, style: TextStyle(fontSize: 13, color: plan.themeColor, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    _SectionTitle(title: '🏋️ Lịch Tập Luyện Mỗi Ngày', color: plan.themeColor),
                    ...plan.workoutRoutine.map((w) => _DetailBullet(text: w)),
                    const SizedBox(height: 16),
                    _SectionTitle(title: '🥗 Chế Độ Ăn Uống Chuẩn', color: plan.themeColor),
                    ...plan.mealPlan.map((m) => _DetailBullet(text: m)),
                    const SizedBox(height: 16),
                    _SectionTitle(title: '😴 Bí Quyết Giấc Ngủ Sâu', color: plan.themeColor),
                    ...plan.sleepTips.map((s) => _DetailBullet(text: s)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _MetricBadge({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.label2)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DetailBullet extends StatelessWidget {
  final String text;

  const _DetailBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.label2)),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

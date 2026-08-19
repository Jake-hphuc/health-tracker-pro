import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';

class KolPlansScreen extends StatefulWidget {
  const KolPlansScreen({super.key});

  @override
  State<KolPlansScreen> createState() => _KolPlansScreenState();
}

class _KolPlansScreenState extends State<KolPlansScreen> {
  String _selectedCategory = 'Tất cả';

  final List<String> _categories = [
    'Tất cả',
    'Bóng đá',
    'Boxing',
    'Bóng rổ',
    'Điền kinh',
    'Thể hình',
    'Bơi lội',
    'Yoga',
  ];

  @override
  Widget build(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final healthProvider = Provider.of<HealthProvider>(context, listen: false);
    final allPlans = challengeProvider.athletePlans;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);

    final filteredPlans = _selectedCategory == 'Tất cả'
        ? allPlans
        : allPlans.where((p) => p.category == _selectedCategory).toList();

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
                          'KOLs & Huyền Thoại Thể Thao',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                        Text(
                          'Giáo án luyện tập & dinh dưỡng từ các siêu sao hàng đầu thế giới',
                          style: TextStyle(fontSize: 12, color: AppColors.label2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Chips by Sports Category
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: _categories.map((cat) {
                    final isSel = _selectedCategory == cat;
                    String iconPrefix = '';
                    switch (cat) {
                      case 'Bóng đá':
                        iconPrefix = '⚽ ';
                        break;
                      case 'Boxing':
                        iconPrefix = '🥊 ';
                        break;
                      case 'Bóng rổ':
                        iconPrefix = '🏀 ';
                        break;
                      case 'Điền kinh':
                        iconPrefix = '🏃 ';
                        break;
                      case 'Thể hình':
                        iconPrefix = '🏋️ ';
                        break;
                      case 'Bơi lội':
                        iconPrefix = '🏊 ';
                        break;
                      case 'Yoga':
                        iconPrefix = '🧘 ';
                        break;
                      default:
                        iconPrefix = '🔥 ';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text('$iconPrefix$cat'),
                        selected: isSel,
                        selectedColor: AppColors.appleGreen,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black87),
                          fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 13,
                        ),
                        onSelected: (val) {
                          if (val) setState(() => _selectedCategory = cat);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (filteredPlans.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Chưa có kế hoạch cho bộ môn này.',
                style: TextStyle(color: AppColors.label2, fontSize: 14),
              ),
            ),
          )
        else
          ...filteredPlans.map((plan) {
            final isApplied = challengeProvider.appliedPlanId == plan.id;

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card1 : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: isApplied
                    ? Border.all(color: plan.themeColor, width: 2.5)
                    : Border.all(color: isDark ? AppColors.separator : const Color(0xFFE5E5EA)),
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
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: plan.themeColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(plan.avatarEmoji, style: const TextStyle(fontSize: 30)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      plan.name,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: plan.themeColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      plan.category,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: plan.themeColor,
                                      ),
                                    ),
                                  ),
                                ],
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
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          left: BorderSide(color: plan.themeColor, width: 4),
                        ),
                      ),
                      child: Text(
                        '💡 "${plan.proTip}"',
                        style: const TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Target Metrics Row
                    Row(
                      children: [
                        _buildMetricChip(
                          icon: Icons.water_drop_rounded,
                          color: AppColors.appleBlue,
                          label: 'Nước',
                          value: '${plan.dailyWaterMl} ml',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildMetricChip(
                          icon: Icons.bedtime_rounded,
                          color: AppColors.applePurple,
                          label: 'Ngủ',
                          value: '${plan.dailySleepHours}h',
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildMetricChip(
                          icon: Icons.directions_run_rounded,
                          color: AppColors.appleRed,
                          label: 'Tập luyện',
                          value: '${plan.dailyActivityMinutes}p',
                          isDark: isDark,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Workout Routine
                    _buildSectionHeader('Lịch Trình Tập Luyện Chuẩn:', plan.themeColor),
                    const SizedBox(height: 8),
                    ...plan.workoutRoutine.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('⚡ ', style: TextStyle(fontSize: 12, color: plan.themeColor)),
                            Expanded(
                              child: Text(item, style: const TextStyle(fontSize: 13, height: 1.3)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Meal Plan
                    _buildSectionHeader('Thực Đơn Dinh Dưỡng:', plan.themeColor),
                    const SizedBox(height: 8),
                    ...plan.mealPlan.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🥗 ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(item, style: const TextStyle(fontSize: 13, height: 1.3)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sleep Tips
                    _buildSectionHeader('Bí Quyết Giấc Ngủ & Phục Hồi:', plan.themeColor),
                    const SizedBox(height: 8),
                    ...plan.sleepTips.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🌙 ', style: TextStyle(fontSize: 12)),
                            Expanded(
                              child: Text(item, style: const TextStyle(fontSize: 13, height: 1.3)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Apply Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApplied
                            ? (isDark ? AppColors.card2 : Colors.grey.shade300)
                            : plan.themeColor,
                        foregroundColor: isApplied ? AppColors.label2 : Colors.white,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: isApplied ? 0 : 2,
                      ),
                      onPressed: isApplied
                          ? null
                          : () async {
                              await challengeProvider.applyAthletePlan(plan.id);
                              await healthProvider.updateGoals(
                                water: plan.dailyWaterMl,
                                sleep: plan.dailySleepHours,
                                activity: plan.dailyActivityMinutes,
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã áp dụng kế hoạch tập luyện của ${plan.name}! 🔥'),
                                    backgroundColor: plan.themeColor,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                );
                              }
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isApplied ? Icons.check_circle_rounded : Icons.flash_on_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isApplied ? 'ĐANG THEO GIÁO ÁN NÀY' : 'ÁP DỤNG GIÁO ÁN NÀY',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ],
                      ),
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
      body: isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: body,
              ),
            )
          : body,
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.label2)),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

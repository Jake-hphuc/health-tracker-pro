import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final _waterGoalController = TextEditingController();
  final _sleepGoalController = TextEditingController();
  final _activityGoalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final health = Provider.of<HealthProvider>(context, listen: false);
    _waterGoalController.text = health.goal.waterGoal.toString();
    _sleepGoalController.text = health.goal.sleepGoal.toString();
    _activityGoalController.text = health.goal.activityGoal.toString();
  }

  @override
  void dispose() {
    _waterGoalController.dispose();
    _sleepGoalController.dispose();
    _activityGoalController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    final water = int.tryParse(_waterGoalController.text.trim()) ?? 2000;
    final sleep = double.tryParse(_sleepGoalController.text.trim()) ?? 8.0;
    final activity = int.tryParse(_activityGoalController.text.trim()) ?? 30;

    final health = Provider.of<HealthProvider>(context, listen: false);
    health.updateGoal(
      waterGoal: water,
      sleepGoal: sleep,
      activityGoal: activity,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã cập nhật mục tiêu sức khỏe cá nhân! 🎯'),
        backgroundColor: AppColors.appleGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    Widget body = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
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
                const Text(
                  'Đặt mục tiêu hàng ngày',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tùy chỉnh các chỉ số phù hợp với thể trạng của bạn',
                  style: TextStyle(fontSize: 13, color: AppColors.label2),
                ),
                const SizedBox(height: 28),

                // Water Goal
                _buildGoalField(
                  controller: _waterGoalController,
                  label: 'Mục tiêu Nước (ml)',
                  icon: Icons.water_drop_rounded,
                  color: AppColors.appleBlue,
                  isDark: isDark,
                ),
                const SizedBox(height: 18),

                // Sleep Goal
                _buildGoalField(
                  controller: _sleepGoalController,
                  label: 'Mục tiêu Giấc ngủ (Giờ)',
                  icon: Icons.bedtime_rounded,
                  color: AppColors.applePurple,
                  isDark: isDark,
                  isDecimal: true,
                ),
                const SizedBox(height: 18),

                // Activity Goal
                _buildGoalField(
                  controller: _activityGoalController,
                  label: 'Mục tiêu Vận động (Phút)',
                  icon: Icons.directions_run_rounded,
                  color: AppColors.appleRed,
                  isDark: isDark,
                ),
                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveGoals,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appleGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'LƯU MỤC TIÊU CÁ NHÂN',
                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Thiết lập Mục tiêu 🎯'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
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

  Widget _buildGoalField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
    bool isDecimal = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color, size: 20),
        filled: true,
        fillColor: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.label2),
      ),
    );
  }
}

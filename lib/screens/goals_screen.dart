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
  late TextEditingController _waterController;
  late TextEditingController _sleepController;
  late TextEditingController _activityController;

  @override
  void initState() {
    super.initState();
    final health = Provider.of<HealthProvider>(context, listen: false);
    _waterController = TextEditingController(text: health.goal.waterGoal.toString());
    _sleepController = TextEditingController(text: health.goal.sleepGoal.toString());
    _activityController = TextEditingController(text: health.goal.activityGoal.toString());
  }

  @override
  void dispose() {
    _waterController.dispose();
    _sleepController.dispose();
    _activityController.dispose();
    super.dispose();
  }

  void _save() {
    final w = int.tryParse(_waterController.text.trim()) ?? 2000;
    final s = double.tryParse(_sleepController.text.trim()) ?? 8.0;
    final a = int.tryParse(_activityController.text.trim()) ?? 30;

    Provider.of<HealthProvider>(context, listen: false).updateGoals(
      water: w,
      sleep: s,
      activity: a,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã cập nhật mục tiêu hàng ngày! 🎯'),
        backgroundColor: AppColors.appleGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      appBar: AppBar(
        title: const Text('Mục Tiêu Hàng Ngày', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                _GoalField(
                  controller: _waterController,
                  label: 'Mục tiêu nước uống',
                  suffix: 'ml',
                  icon: Icons.water_drop_rounded,
                  color: AppColors.appleBlue,
                  keyboardType: TextInputType.number,
                ),
                const Divider(height: 24),
                _GoalField(
                  controller: _sleepController,
                  label: 'Mục tiêu giấc ngủ',
                  suffix: 'giờ',
                  icon: Icons.bedtime_rounded,
                  color: AppColors.applePurple,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const Divider(height: 24),
                _GoalField(
                  controller: _activityController,
                  label: 'Mục tiêu vận động',
                  suffix: 'phút',
                  icon: Icons.directions_run_rounded,
                  color: AppColors.appleRed,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.appleGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('LƯU MỤC TIÊU',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }
}

class _GoalField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;
  final Color color;
  final TextInputType keyboardType;

  const _GoalField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
    required this.color,
    required this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ),
        SizedBox(
          width: 90,
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.end,
            decoration: InputDecoration(
              suffixText: suffix,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';
import '../utils/bmi_calculator.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _selectedType = 'Chạy bộ';
  final _durationController = TextEditingController();

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  void _save() {
    final dur = int.tryParse(_durationController.text.trim());
    if (dur == null || dur <= 0 || dur > 720) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập thời gian hợp lệ (1 - 720 phút)'),
          backgroundColor: AppColors.appleRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final health = Provider.of<HealthProvider>(context, listen: false);
    final calories = BmiCalculator.calculateCaloriesBurned(_selectedType, dur, 65.0);

    health.addActivity(
      type: _selectedType,
      duration: dur,
      calories: calories,
    );

    _durationController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã ghi nhận: $_selectedType · $dur phút (~${calories.round()} kcal)! 🔥'),
        backgroundColor: AppColors.appleRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

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
          child: const Text('Vận động & Thể thao 🔥',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        ),
        const SizedBox(height: 20),

        // Activity selector card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.appleRed.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chọn môn thể thao',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 76,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppConstants.activityTypes.length,
                  itemBuilder: (context, i) {
                    final type = AppConstants.activityTypes[i];
                    final isSelected = _selectedType == type;
                    final icon = AppConstants.activityIcons[type] ?? Icons.fitness_center_rounded;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.appleRed
                              : (isDark ? AppColors.card2 : const Color(0xFFF2F2F7)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, size: 22, color: isSelected ? Colors.white : AppColors.label2),
                            const SizedBox(height: 4),
                            Text(
                              type,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? Colors.white : (isDark ? AppColors.label2 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Duration input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Thời gian tập...',
                        suffixText: 'phút',
                        prefixIcon: Icon(Icons.timer_outlined, size: 20),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appleRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Lưu',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // History
        const Text('Lịch sử vận động',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
        const SizedBox(height: 12),
        if (health.activityList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Chưa có bài tập nào hôm nay\nHãy bắt đầu vận động ngay thôi! 🔥',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.label2, height: 1.5)),
            ),
          )
        else
          ...health.activityList.map((item) {
            final icon = AppConstants.activityIcons[item.type] ?? Icons.fitness_center_rounded;
            return Dismissible(
              key: Key('activity_${item.id}'),
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
              onDismissed: (_) => health.deleteActivity(item.id!),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.appleRed.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: AppColors.appleRed, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.type,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                          Text(item.date,
                            style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${item.duration} phút',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        Text('${item.calories.round()} kcal',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.appleRed)),
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
}

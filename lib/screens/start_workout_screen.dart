import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';
import '../utils/bmi_calculator.dart';

class StartWorkoutScreen extends StatefulWidget {
  const StartWorkoutScreen({super.key});

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<({String name, IconData icon, Color color, String desc})> _workoutTypes = [
    (name: 'Đi bộ', icon: Icons.directions_walk_rounded, color: AppColors.appleGreen, desc: 'Đốt calo nhẹ nhàng & bền bỉ'),
    (name: 'Chạy bộ', icon: Icons.directions_run_rounded, color: AppColors.appleRed, desc: 'Tăng sức bền tim mạch & tốc độ'),
    (name: 'Đạp xe', icon: Icons.pedal_bike_rounded, color: AppColors.appleBlue, desc: 'Săn chắc cơ đùi & đốt mỡ'),
    (name: 'Tập tạ', icon: Icons.fitness_center_rounded, color: AppColors.appleOrange, desc: 'Phát triển sức mạnh & cơ bắp'),
    (name: 'Yoga', icon: Icons.self_improvement_rounded, color: AppColors.applePurple, desc: 'Dẻo dai cơ thể & giải tỏa stress'),
    (name: 'HIIT', icon: Icons.local_fire_department_rounded, color: Color(0xFFFF5252), desc: 'Đốt mỡ cường độ cao ngắt quãng'),
    (name: 'Leo núi', icon: Icons.landscape_rounded, color: Color(0xFF8D6E63), desc: 'Thử thách địa hình & sức chịu đựng'),
    (name: 'Bơi lội', icon: Icons.pool_rounded, color: AppColors.appleTeal, desc: 'Vận động toàn thân dưới nước'),
    (name: 'Bóng rổ', icon: Icons.sports_basketball_rounded, color: Color(0xFFFF9800), desc: 'Bật nhảy, khéo léo & đồng đội'),
    (name: 'Bóng đá', icon: Icons.sports_soccer_rounded, color: Color(0xFF4CAF50), desc: 'Tốc độ, chiến thuật & thể lực'),
    (name: 'Cầu lông', icon: Icons.sports_tennis_rounded, color: Color(0xFF00BCD4), desc: 'Phản xạ nhanh & linh hoạt'),
    (name: 'Khác', icon: Icons.more_horiz_rounded, color: AppColors.appleYellow, desc: 'Các bộ môn vận động tự chọn'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showWorkoutStartSheet(BuildContext context, ({String name, IconData icon, Color color, String desc}) workout) {
    int durationMinutes = 30;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final calories = BmiCalculator.calculateCaloriesBurned(workout.name, durationMinutes, 65.0);

            return Container(
              padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 28),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card1 : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.separator : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: workout.color.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(workout.icon, color: workout.color, size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    workout.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workout.desc,
                    style: const TextStyle(color: AppColors.label2, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Thời gian dự kiến:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: workout.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$durationMinutes phút (~${calories.round()} kcal)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: workout.color),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: durationMinutes.toDouble(),
                    min: 5,
                    max: 180,
                    divisions: 35,
                    activeColor: workout.color,
                    inactiveColor: isDark ? AppColors.card2 : Colors.grey.shade200,
                    onChanged: (val) {
                      setSheetState(() => durationMinutes = val.round());
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final health = Provider.of<HealthProvider>(context, listen: false);
                      health.addActivity(
                        type: workout.name,
                        duration: durationMinutes,
                        calories: calories,
                      );
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Đã ghi nhận bài tập ${workout.name}: $durationMinutes phút (${calories.round()} kcal) 🔥'),
                          backgroundColor: workout.color,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: workout.color,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, size: 24),
                        SizedBox(width: 8),
                        Text('BẮT ĐẦU TẬP LUYỆN', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final health = Provider.of<HealthProvider>(context);

    final filteredWorkouts = _workoutTypes.where((w) {
      if (_searchQuery.isEmpty) return true;
      return w.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.desc.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final recentActivities = health.activityList.take(3).toList();

    final content = CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chọn Bài Tập ⚡',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  const Text('Lựa chọn bộ môn thể thao và bắt đầu đốt calo',
                    style: TextStyle(fontSize: 13, color: AppColors.label2)),
                  const SizedBox(height: 16),
                  // Search field
                  TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm bài tập (Chạy bộ, Yoga, Gym...)',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.label2),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.label2),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppColors.card1 : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Recent Workouts Section
        if (recentActivities.isNotEmpty && _searchQuery.isEmpty) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 24, isWide ? 28 : 20, 12),
              child: const Text('Bài Tập Gần Đây',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
                itemCount: recentActivities.length,
                itemBuilder: (context, idx) {
                  final act = recentActivities[idx];
                  final workoutData = _workoutTypes.firstWhere(
                    (w) => w.name == act.type,
                    orElse: () => (name: act.type, icon: Icons.fitness_center_rounded, color: AppColors.appleRed, desc: ''),
                  );

                  return GestureDetector(
                    onTap: () => _showWorkoutStartSheet(context, workoutData),
                    child: Container(
                      width: 170,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.card1 : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: workoutData.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: workoutData.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(workoutData.icon, color: workoutData.color, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(act.type, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 1),
                                const SizedBox(height: 2),
                                Text('${act.duration} phút', style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],

        // Grid of Workout Types
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 12),
            child: const Text('Tất Cả Môn Thể Thao',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 0, isWide ? 28 : 20, 100),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 4 : 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.15,
            ),
            itemCount: filteredWorkouts.length,
            itemBuilder: (context, index) {
              final workout = filteredWorkouts[index];
              return GestureDetector(
                onTap: () => _showWorkoutStartSheet(context, workout),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card1 : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: workout.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(workout.icon, color: workout.color, size: 24),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.label3),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(workout.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
                          const SizedBox(height: 2),
                          Text(workout.desc,
                            style: const TextStyle(fontSize: 11, color: AppColors.label2),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: content)) : content,
    );
  }
}

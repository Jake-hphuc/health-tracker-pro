import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';

// ─────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────
class WorkoutType {
  final String name;
  final IconData icon;
  final Color color;
  const WorkoutType({required this.name, required this.icon, required this.color});
}

const _workouts = [
  WorkoutType(name: 'Đi bộ',        icon: Icons.directions_walk_rounded,   color: AppColors.appleGreen),
  WorkoutType(name: 'Chạy bộ',      icon: Icons.directions_run_rounded,    color: AppColors.appleRed),
  WorkoutType(name: 'Đạp xe',       icon: Icons.pedal_bike_rounded,        color: AppColors.appleBlue),
  WorkoutType(name: 'Tập tạ',       icon: Icons.fitness_center_rounded,    color: AppColors.appleOrange),
  WorkoutType(name: 'Yoga',         icon: Icons.self_improvement_rounded,  color: AppColors.applePurple),
  WorkoutType(name: 'HIIT',         icon: Icons.local_fire_department_rounded, color: AppColors.appleRed),
  WorkoutType(name: 'Leo núi',      icon: Icons.landscape_rounded,         color: AppColors.appleTeal),
  WorkoutType(name: 'Bơi lội',      icon: Icons.pool_rounded,              color: AppColors.appleBlue),
  WorkoutType(name: 'Bóng rổ',      icon: Icons.sports_basketball_rounded, color: AppColors.appleOrange),
  WorkoutType(name: 'Bóng đá',      icon: Icons.sports_soccer_rounded,    color: AppColors.appleGreen),
  WorkoutType(name: 'Cầu lông',     icon: Icons.sports_tennis_rounded,    color: AppColors.appleYellow),
  WorkoutType(name: 'Khác',         icon: Icons.more_horiz_rounded,       color: AppColors.label2),
];

// ─────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────
class StartWorkoutScreen extends StatefulWidget {
  const StartWorkoutScreen({super.key});

  @override
  State<StartWorkoutScreen> createState() => _StartWorkoutScreenState();
}

class _StartWorkoutScreenState extends State<StartWorkoutScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() => _query = _searchCtrl.text.toLowerCase()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<WorkoutType> get _filtered => _query.isEmpty
      ? _workouts
      : _workouts.where((w) => w.name.toLowerCase().contains(_query)).toList();

  void _startWorkout(BuildContext context, WorkoutType workout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorkoutStartSheet(workout: workout),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final bgColor = isDark ? AppColors.blackBg : AppColors.lightBg;
    final cardColor = isDark ? AppColors.card1 : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 24, isWide ? 28 : 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.appleRed.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: AppColors.appleRed,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chọn Bài Tập',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Bắt đầu phiên luyện tập của bạn',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.label2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Search bar ────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchCtrl,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 15,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm bài tập...',
                          hintStyle: const TextStyle(color: AppColors.label2, fontSize: 15),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.label2, size: 22),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, color: AppColors.label2, size: 20),
                                  onPressed: () => _searchCtrl.clear(),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ── Recent Workouts (only when not searching) ──────
            if (_query.isEmpty) ...[
              SliverPadding(
                padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 0, isWide ? 28 : 20, 0),
                sliver: SliverToBoxAdapter(
                  child: _RecentWorkoutsSection(isDark: isDark, onStart: (w) => _startWorkout(context, w)),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 24, isWide ? 28 : 20, 10),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Tất cả Bài tập',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ],

            // ── Workout Grid ───────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 16, 0, isWide ? 28 : 16, 100),
              sliver: _filtered.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              const Icon(Icons.search_off_rounded, color: AppColors.label2, size: 48),
                              const SizedBox(height: 12),
                              Text(
                                'Không tìm thấy bài tập\n"${_searchCtrl.text}"',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: AppColors.label2, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isWide ? 4 : 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.88,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final workout = _filtered[index];
                          return _WorkoutCard(
                            workout: workout,
                            isDark: isDark,
                            onTap: () => _startWorkout(context, workout),
                          );
                        },
                        childCount: _filtered.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Workout Card (Grid Item)
// ─────────────────────────────────────────────────────────────
class _WorkoutCard extends StatelessWidget {
  final WorkoutType workout;
  final bool isDark;
  final VoidCallback onTap;

  const _WorkoutCard({required this.workout, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.card1 : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: workout.color.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon circle
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: workout.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(workout.icon, color: workout.color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              workout.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: workout.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Bắt đầu',
                style: TextStyle(fontSize: 10, color: workout.color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Recent Workouts Section
// ─────────────────────────────────────────────────────────────
class _RecentWorkoutsSection extends StatelessWidget {
  final bool isDark;
  final void Function(WorkoutType) onStart;

  const _RecentWorkoutsSection({required this.isDark, required this.onStart});

  static final _recents = [
    (workout: _workouts[1], duration: '32 phút', calories: '320 kcal', ago: '2 giờ trước'),
    (workout: _workouts[3], duration: '45 phút', calories: '280 kcal', ago: 'Hôm qua'),
    (workout: _workouts[0], duration: '25 phút', calories: '120 kcal', ago: '2 ngày trước'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gần đây',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black87,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Xem tất cả',
              style: const TextStyle(fontSize: 13, color: AppColors.appleBlue, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recents.map((r) => _RecentItem(
              workout: r.workout,
              duration: r.duration,
              calories: r.calories,
              ago: r.ago,
              isDark: isDark,
              onStart: onStart,
            )),
      ],
    );
  }
}

class _RecentItem extends StatelessWidget {
  final WorkoutType workout;
  final String duration;
  final String calories;
  final String ago;
  final bool isDark;
  final void Function(WorkoutType) onStart;

  const _RecentItem({
    required this.workout,
    required this.duration,
    required this.calories,
    required this.ago,
    required this.isDark,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.card1 : Colors.white;

    return GestureDetector(
      onTap: () => onStart(workout),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: workout.color.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: workout.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(workout.icon, color: workout.color, size: 22),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 12, color: AppColors.label2),
                      const SizedBox(width: 3),
                      Text(duration, style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                      const SizedBox(width: 10),
                      const Icon(Icons.local_fire_department_outlined, size: 12, color: AppColors.label2),
                      const SizedBox(width: 3),
                      Text(calories, style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                      const SizedBox(width: 10),
                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.label2),
                      const SizedBox(width: 3),
                      Text(ago, style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                    ],
                  ),
                ],
              ),
            ),

            // Quick start arrow
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: workout.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow_rounded, color: workout.color, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom Sheet: Start Workout
// ─────────────────────────────────────────────────────────────
class _WorkoutStartSheet extends StatefulWidget {
  final WorkoutType workout;
  const _WorkoutStartSheet({required this.workout});

  @override
  State<_WorkoutStartSheet> createState() => _WorkoutStartSheetState();
}

class _WorkoutStartSheetState extends State<_WorkoutStartSheet> {
  int _duration = 30;

  void _confirm() {
    Provider.of<HealthProvider>(context, listen: false).addActivity(
      type: widget.workout.name,
      durationMinutes: _duration,
      distanceKm: 0.0,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã bắt đầu ${widget.workout.name}! 💪'),
        backgroundColor: widget.workout.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.card1 : Colors.white;
    final w = widget.workout;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.separator : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: w.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(w.icon, color: w.color, size: 36),
          ),
          const SizedBox(height: 14),
          Text(
            w.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.3),
          ),
          const SizedBox(height: 4),
          Text(
            'Chọn thời gian luyện tập',
            style: const TextStyle(fontSize: 13, color: AppColors.label2),
          ),
          const SizedBox(height: 24),

          // Duration slider
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.timer_rounded, color: w.color, size: 20),
              const SizedBox(width: 8),
              Text(
                '$_duration phút',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: w.color),
              ),
            ],
          ),
          Slider(
            value: _duration.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            activeColor: w.color,
            inactiveColor: w.color.withValues(alpha: 0.2),
            onChanged: (v) => setState(() => _duration = v.round()),
          ),

          // Duration presets
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [10, 20, 30, 45, 60].map((mins) {
              final selected = _duration == mins;
              return GestureDetector(
                onTap: () => setState(() => _duration = mins),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? w.color : w.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${mins}ph',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : w.color,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // Start button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _confirm,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: const Text(
                'BẮT ĐẦU NGAY',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: w.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 4,
                shadowColor: w.color.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

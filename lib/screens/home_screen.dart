import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/activity_ring.dart';
import '../widgets/metric_card.dart';
import '../widgets/bottom_nav.dart';
import '../utils/constants.dart';
import 'schedule_screen.dart';
import 'water_screen.dart';
import 'sleep_screen.dart';
import 'weight_screen.dart';
import 'activity_screen.dart';
import 'challenges_screen.dart';
import 'kol_plans_screen.dart';
import 'health_tips_screen.dart';
import 'rewards_store_screen.dart';
import 'statistics_screen.dart';
import 'settings_screen.dart';
import 'start_workout_screen.dart';
import 'meal_scanner_screen.dart';
import 'project_intro_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.currentUser?.id != null) {
        final uid = auth.currentUser!.id!;
        Provider.of<HealthProvider>(context, listen: false).init(uid);
        Provider.of<ScheduleProvider>(context, listen: false).init(uid);
      }
    });
  }

  void _navigateToTab(int index) {
    setState(() => _currentIndex = index);
  }

  List<Widget> get _pages => [
        _DashboardTab(onNavigateToTab: _navigateToTab),
        const ScheduleScreen(),
        const MealScannerScreen(),
        const StartWorkoutScreen(),
        const WaterScreen(),
        const SleepScreen(),
        const WeightScreen(),
        const ActivityScreen(),
        const ChallengesScreen(),
        const KolPlansScreen(),
        const HealthTipsScreen(),
        const RewardsStoreScreen(),
        const StatisticsScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    final isWide = AppConstants.isWide(context);

    return Scaffold(
      body: isWide
          ? Row(
              children: [
                _SideRail(
                  currentIndex: _currentIndex,
                  onTap: _navigateToTab,
                ),
                const VerticalDivider(thickness: 0.5, width: 1),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _pages,
                  ),
                ),
              ],
            )
          : IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
      bottomNavigationBar: isWide
          ? null
          : CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: _navigateToTab,
            ),
    );
  }
}

class _SideRail extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _SideRail({required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.dashboard_rounded,      label: 'Tổng quan', color: AppColors.appleGreen),
    (icon: Icons.calendar_month_rounded, label: 'Lịch trình', color: AppColors.appleBlue),
    (icon: Icons.restaurant_rounded,     label: 'Ăn uống',   color: AppColors.appleOrange),
    (icon: Icons.bolt_rounded,           label: 'Tập luyện', color: AppColors.appleRed),
    (icon: Icons.water_drop_rounded,     label: 'Nước uống', color: AppColors.appleBlue),
    (icon: Icons.bedtime_rounded,        label: 'Giấc ngủ', color: AppColors.applePurple),
    (icon: Icons.monitor_weight_rounded, label: 'Cân nặng', color: AppColors.appleOrange),
    (icon: Icons.directions_run_rounded, label: 'Vận động', color: AppColors.appleRed),
    (icon: Icons.emoji_events_rounded,   label: 'Thử thách', color: AppColors.appleYellow),
    (icon: Icons.stars_rounded,          label: 'KOLs',     color: AppColors.appleGreen),
    (icon: Icons.lightbulb_rounded,      label: 'Mẹo hay',  color: AppColors.appleTeal),
    (icon: Icons.card_giftcard_rounded,  label: 'Đổi Quà',  color: AppColors.appleRed),
    (icon: Icons.bar_chart_rounded,      label: 'Thống kê', color: AppColors.appleTeal),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: isDark ? AppColors.card1 : Colors.white,
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.appleRed, AppColors.appleGreen],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final item = _items[i];
                  final isSelected = currentIndex == i;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: InkWell(
                      onTap: () => onTap(i),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? item.color.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.icon,
                              size: 20,
                              color: isSelected ? item.color : AppColors.label2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? item.color : AppColors.label2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final Function(int) onNavigateToTab;

  const _DashboardTab({required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final health = Provider.of<HealthProvider>(context);
    final schedule = Provider.of<ScheduleProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final today = DateFormat('EEEE, d MMMM', 'vi').format(DateTime.now());

    final waterGoal = health.goal.waterGoal > 0 ? health.goal.waterGoal : 2000;
    final activityGoal = health.goal.activityGoal > 0 ? health.goal.activityGoal : 30;

    // Apple-style ring metrics
    final moveCalories = (health.todayActivityMinutes * 6.5).round();
    final moveProgress = (moveCalories / 500).clamp(0.0, 1.0);
    final exerciseProgress = (health.todayActivityMinutes / activityGoal).clamp(0.0, 1.0);
    final standProgress = (health.todayWaterTotal / waterGoal).clamp(0.0, 1.0);

    final todaySchedules = schedule.todaySchedules;

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Header: User Greeting & Actions
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          today.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.label2,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Xin chào, ${auth.currentUser?.name ?? 'Bạn'} 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Thông tin Đề tài & Nhóm',
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.appleGreen.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.groups_rounded,
                              size: 22,
                              color: AppColors.appleGreen,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProjectIntroScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.card2 : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.settings_outlined, size: 22),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SettingsScreen()),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Project Info Banner Card
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 12, isWide ? 28 : 20, 0),
              sliver: SliverToBoxAdapter(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ProjectIntroScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF1E3A8A).withValues(alpha: 0.6),
                                const Color(0xFF065F46).withValues(alpha: 0.6),
                              ]
                            : [
                                const Color(0xFFE0F2FE),
                                const Color(0xFFDCFCE7),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.appleGreen.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.appleGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.school_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ĐỀ TÀI: THEO DÕI SỨC KHỎE – HEALTH TRACKER',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Nhóm: Hoàng Phúc (23150096) • Nhật Minh (23150210) • Minh Thuận (23150056)',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: AppColors.label2,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: AppColors.label2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Rings Section
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 16, isWide ? 28 : 20, 0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card1 : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ActivityRingWidget(
                          moveProgress: moveProgress,
                          exerciseProgress: exerciseProgress,
                          hydrationProgress: standProgress,
                          size: 120,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RingLegend(
                              color: AppColors.appleRed,
                              label: 'DI CHUYỂN',
                              value: '$moveCalories / 500 kcal',
                            ),
                            const SizedBox(height: 10),
                            _RingLegend(
                              color: AppColors.appleGreen,
                              label: 'TẬP LUYỆN',
                              value: '${health.todayActivityMinutes} / $activityGoal PHÚT',
                            ),
                            const SizedBox(height: 10),
                            _RingLegend(
                              color: AppColors.appleBlue,
                              label: 'UỐNG NƯỚC',
                              value: '${health.todayWaterTotal} / $waterGoal ML',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Section: Lịch Trình Hôm Nay
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.calendar_month_rounded, color: AppColors.appleBlue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Lịch Trình Hôm Nay',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () => onNavigateToTab(1),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'Xem tất cả',
                                style: TextStyle(
                                  color: AppColors.appleBlue,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.appleBlue),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (todaySchedules.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.card1 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, color: AppColors.appleGreen),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Bạn chưa có lịch trình nào cho hôm nay!',
                                style: TextStyle(fontSize: 13, color: AppColors.label2),
                              ),
                            ),
                            TextButton(
                              onPressed: () => onNavigateToTab(1),
                              child: const Text('Thêm ngay', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: todaySchedules.take(3).map((item) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.card1 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: item.isCompleted
                                    ? AppColors.appleGreen.withValues(alpha: 0.3)
                                    : (isDark ? AppColors.separator : const Color(0xFFE5E5EA)),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: item.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(item.icon, color: item.color, size: 18),
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                  color: item.isCompleted ? AppColors.label2 : null,
                                ),
                              ),
                              subtitle: Text(
                                '${item.scheduledTime} • ${item.scheduleType}',
                                style: const TextStyle(fontSize: 11.5, color: AppColors.label2),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  item.isCompleted
                                      ? Icons.check_circle_rounded
                                      : Icons.radio_button_unchecked_rounded,
                                  color: item.isCompleted ? AppColors.appleGreen : AppColors.label3,
                                  size: 24,
                                ),
                                onPressed: () => schedule.toggleComplete(item.id!),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            // Section: Metric Cards Grid
            SliverPadding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 100),
              sliver: SliverGrid.count(
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                children: [
                  MetricCard(
                    title: 'Nạp Calo',
                    value: '${health.todayCaloriesIn}',
                    unit: 'kcal',
                    icon: Icons.restaurant_rounded,
                    accentColor: AppColors.appleOrange,
                    progress: (health.todayCaloriesIn / 2000).clamp(0.0, 1.0),
                    subtitle: '${health.todayMeals.length} bữa ăn hôm nay',
                    onTap: () => onNavigateToTab(2),
                  ),
                  MetricCard(
                    title: 'Nước uống',
                    value: '${health.todayWaterTotal}',
                    unit: 'ml',
                    icon: Icons.water_drop_rounded,
                    accentColor: AppColors.appleBlue,
                    progress: (health.todayWaterTotal / waterGoal).clamp(0.0, 1.0),
                    subtitle: 'Mục tiêu: $waterGoal ml',
                    onTap: () => onNavigateToTab(4),
                  ),
                  MetricCard(
                    title: 'Giấc ngủ',
                    value: health.latestSleep != null
                        ? '${health.latestSleep!.duration.toStringAsFixed(1)}h'
                        : '--',
                    unit: '',
                    icon: Icons.bedtime_rounded,
                    accentColor: AppColors.applePurple,
                    progress: health.latestSleep != null
                        ? (health.latestSleep!.duration / health.goal.sleepGoal).clamp(0.0, 1.0)
                        : 0.0,
                    subtitle: health.latestSleep?.quality ?? 'Chưa ghi nhận',
                    onTap: () => onNavigateToTab(5),
                  ),
                  MetricCard(
                    title: 'Cân nặng',
                    value: health.currentWeight.toStringAsFixed(1),
                    unit: 'kg',
                    icon: Icons.monitor_weight_rounded,
                    accentColor: AppColors.appleOrange,
                    progress: 0.7,
                    subtitle: 'BMI: ${health.bmi.toStringAsFixed(1)} (${health.bmiClassification.split(' ').first})',
                    onTap: () => onNavigateToTab(6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _RingLegend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

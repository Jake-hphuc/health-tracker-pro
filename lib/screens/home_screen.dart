import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/health_provider.dart';
import '../widgets/activity_ring.dart';
import '../widgets/metric_card.dart';
import '../widgets/bottom_nav.dart';
import '../utils/constants.dart';
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
        Provider.of<HealthProvider>(context, listen: false)
            .init(auth.currentUser!.id!);
      }
    });
  }

  final List<Widget> _pages = const [
    _DashboardTab(),
    WaterScreen(),
    SleepScreen(),
    WeightScreen(),
    ActivityScreen(),
    ChallengesScreen(),
    KolPlansScreen(),
    HealthTipsScreen(),
    RewardsStoreScreen(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = AppConstants.isWide(context);

    return Scaffold(
      body: isWide
          // ── Tablet/Desktop: Side Rail + Content ──────────────
          ? Row(
              children: [
                _SideRail(
                  currentIndex: _currentIndex,
                  onTap: (i) => setState(() => _currentIndex = i),
                ),
                Expanded(child: _pages[_currentIndex]),
              ],
            )
          // ── Phone: Normal Bottom Nav ───────────────────────────
          : _pages[_currentIndex],
      bottomNavigationBar: isWide
          ? null
          : CustomBottomNav(
              currentIndex: _currentIndex,
              onTap: (i) => setState(() => _currentIndex = i),
            ),
    );
  }
}

// ─────────────────────────────────────────────
// Side Rail cho màn hình rộng (tablet/desktop)
// ─────────────────────────────────────────────
class _SideRail extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const _SideRail({required this.currentIndex, required this.onTap});

  static const _items = [
    (icon: Icons.square_rounded,          label: 'Tổng quan', color: AppColors.appleGreen),
    (icon: Icons.water_drop_rounded,       label: 'Nước',      color: AppColors.appleBlue),
    (icon: Icons.bedtime_rounded,          label: 'Giấc ngủ', color: AppColors.applePurple),
    (icon: Icons.monitor_weight_rounded,   label: 'Cân nặng', color: AppColors.appleOrange),
    (icon: Icons.directions_run_rounded,   label: 'Vận động', color: AppColors.appleRed),
    (icon: Icons.emoji_events_rounded,     label: 'Thử thách', color: AppColors.appleYellow),
    (icon: Icons.stars_rounded,            label: 'KOLs',     color: AppColors.appleGreen),
    (icon: Icons.lightbulb_rounded,        label: 'Mẹo hay',   color: AppColors.appleTeal),
    (icon: Icons.card_giftcard_rounded,    label: 'Đổi Quà',  color: AppColors.appleRed),
    (icon: Icons.bar_chart_rounded,        label: 'Thống kê', color: AppColors.appleTeal),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: isDark ? AppColors.card1 : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.separator : const Color(0xFFE5E5EA),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.appleRed, AppColors.appleGreen],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text('Health Pro',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ],
              ),
            ),
            ..._items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isActive = currentIndex == i;
              return InkWell(
                onTap: () => onTap(i),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? item.color.withValues(alpha: 0.15) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, size: 20,
                        color: isActive ? item.color : AppColors.label3),
                      const SizedBox(width: 12),
                      Text(item.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive ? item.color : AppColors.label2,
                        )),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Dashboard Tab
// ─────────────────────────────────────────────
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final auth   = Provider.of<AuthProvider>(context);
    final health = Provider.of<HealthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);

    final name = auth.currentUser?.name.split(' ').last ?? 'bạn';
    final now  = DateTime.now();
    final hour = now.hour;
    final greeting = hour < 12 ? 'Chào buổi sáng' : hour < 18 ? 'Chào buổi chiều' : 'Chào buổi tối';
    final todayStr  = DateFormat('EEEE, d MMMM', 'vi').format(now);

    // Progress values
    final waterP    = health.goal.waterGoal > 0
        ? (health.todayWaterTotal / health.goal.waterGoal).clamp(0.0, 1.5)
        : 0.0;
    final activityP = health.goal.activityGoal > 0
        ? (health.todayActivityMinutes / health.goal.activityGoal).clamp(0.0, 1.5)
        : 0.0;
    final sleepP    = (health.goal.sleepGoal > 0 && health.latestSleep != null)
        ? (health.latestSleep!.duration / health.goal.sleepGoal).clamp(0.0, 1.5)
        : 0.0;
    final weightBmi = health.latestWeight?.bmi ?? 0.0;

    // Calories estimate
    final calories  = (health.todayActivityMinutes * 7.5).toInt();

    Widget content = CustomScrollView(
      slivers: [
        // ── App Bar ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 16, isWide ? 28 : 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(greeting,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.label2 : AppColors.subtitleLight,
                          )),
                        const SizedBox(height: 2),
                        Text('$greeting, $name 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          )),
                        const SizedBox(height: 2),
                        Text(todayStr,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.label2 : AppColors.subtitleLight,
                          )),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle_outlined, size: 30),
                    onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Activity Ring Section ─────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isWide ? 28 : 20, vertical: 28),
            child: isWide
                // Landscape: ring kế bên stats
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildRing(context, activityP, sleepP, waterP, calories, health, isWide),
                      const SizedBox(width: 36),
                      Expanded(child: _buildRingLegend(context, activityP, sleepP, waterP, health)),
                    ],
                  )
                // Portrait: ring trên, stats dưới
                : Column(
                    children: [
                      _buildRing(context, activityP, sleepP, waterP, calories, health, isWide),
                      const SizedBox(height: 24),
                      _buildRingLegend(context, activityP, sleepP, waterP, health),
                    ],
                  ),
          ),
        ),

        // ── Stats Row ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
            child: Row(
              children: [
                _StatPill(label: 'Calories', value: '$calories', unit: 'kcal', color: AppColors.appleRed),
                const SizedBox(width: 12),
                _StatPill(label: 'Tập luyện', value: '${health.todayActivityMinutes}', unit: 'phút', color: AppColors.appleGreen),
                const SizedBox(width: 12),
                _StatPill(label: 'Nước', value: '${health.todayWaterTotal}', unit: 'ml', color: AppColors.appleBlue),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // ── Metric Cards Grid ─────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            isWide ? 28 : 20, 0, isWide ? 28 : 20, 100),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isWide ? 4 : 2,
              crossAxisSpacing: 14,
              mainAxisSpacing:  14,
              childAspectRatio: isWide ? 1.1 : 0.95,
            ),
            delegate: SliverChildListDelegate([
              MetricCard(
                title:       'Uống Nước',
                value:       '${health.todayWaterTotal}',
                unit:        '/ ${health.goal.waterGoal} ml',
                subtitle:    'Mục tiêu hàng ngày',
                icon:        Icons.water_drop_rounded,
                accentColor: AppColors.appleBlue,
                progress:    waterP,
                onTap: () {},
              ),
              MetricCard(
                title:       'Giấc Ngủ',
                value:       health.latestSleep != null
                    ? health.latestSleep!.duration.toStringAsFixed(1) : '0.0',
                unit:        '/ ${health.goal.sleepGoal}h',
                subtitle:    health.latestSleep?.quality ?? 'Chưa ghi nhận',
                icon:        Icons.bedtime_rounded,
                accentColor: AppColors.applePurple,
                progress:    sleepP,
                onTap: () {},
              ),
              MetricCard(
                title:       'Cân Nặng',
                value:       health.latestWeight != null
                    ? '${health.latestWeight!.weight}' : '--',
                unit:        'kg',
                subtitle:    AppConstants.getBMICategory(weightBmi),
                icon:        Icons.monitor_weight_rounded,
                accentColor: AppColors.appleOrange,
                progress:    weightBmi > 0 ? (weightBmi / 30.0).clamp(0.0, 1.0) : 0.0,
                onTap: () {},
              ),
              MetricCard(
                title:       'Vận Động',
                value:       '${health.todayActivityMinutes}',
                unit:        '/ ${health.goal.activityGoal} phút',
                subtitle:    'Phút thể thao',
                icon:        Icons.directions_run_rounded,
                accentColor: AppColors.appleRed,
                progress:    activityP,
                onTap: () {},
              ),
            ]),
          ),
        ),
      ],
    );

    if (isWide) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: content,
        ),
      );
    }
    return content;
  }

  Widget _buildRing(BuildContext context,
      double activityP, double sleepP, double waterP,
      int calories, HealthProvider health, bool isWide) {
    final size = isWide ? 220.0 : 200.0;
    return ActivityRingWidget(
      size: size,
      moveProgress:      activityP,
      exerciseProgress:  sleepP,
      hydrationProgress: waterP,
      centerWidget: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, color: AppColors.appleRed, size: 20),
          const SizedBox(height: 4),
          Text('$calories',
            style: const TextStyle(
              fontSize: 28, fontWeight: FontWeight.w800,
              letterSpacing: -1, color: Colors.white)),
          const Text('kcal',
            style: TextStyle(fontSize: 11, color: AppColors.label2, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRingLegend(BuildContext context,
      double activityP, double sleepP, double waterP, HealthProvider health) {
    return Column(
      children: [
        _RingLegendRow(
          color: AppColors.appleRed,
          label: 'Vận động',
          value: '${health.todayActivityMinutes} / ${health.goal.activityGoal} phút',
          percent: activityP,
        ),
        const SizedBox(height: 14),
        _RingLegendRow(
          color: AppColors.appleGreen,
          label: 'Giấc ngủ',
          value: health.latestSleep != null
              ? '${health.latestSleep!.duration.toStringAsFixed(1)} / ${health.goal.sleepGoal} giờ'
              : 'Chưa ghi nhận',
          percent: sleepP,
        ),
        const SizedBox(height: 14),
        _RingLegendRow(
          color: AppColors.appleBlue,
          label: 'Nước',
          value: '${health.todayWaterTotal} / ${health.goal.waterGoal} ml',
          percent: waterP,
        ),
      ],
    );
  }
}

class _RingLegendRow extends StatelessWidget {
  final Color  color;
  final String label;
  final String value;
  final double percent;

  const _RingLegendRow({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12, height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text('${(percent * 100).clamp(0, 999).toStringAsFixed(0)}%',
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value:  percent.clamp(0.0, 1.0),
                  minHeight: 5,
                  backgroundColor: color.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 2),
              Text(value,
                style: TextStyle(fontSize: 11, color: AppColors.label2)),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color  color;

  const _StatPill({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.card1 : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value,
                  style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800,
                    color: color, letterSpacing: -0.5)),
                const SizedBox(width: 3),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(unit,
                    style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.label2 : AppColors.subtitleLight,
              )),
          ],
        ),
      ),
    );
  }
}

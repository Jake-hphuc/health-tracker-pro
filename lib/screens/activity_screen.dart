import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../widgets/activity_ring.dart';
import '../utils/constants.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  String _type          = 'Đi bộ';
  final _durationCtrl   = TextEditingController(text: '30');
  final _distanceCtrl   = TextEditingController(text: '0.0');

  @override
  void dispose() {
    _durationCtrl.dispose();
    _distanceCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final dur = int.tryParse(_durationCtrl.text.trim());
    if (dur == null || dur <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập thời gian hợp lệ (phút)'),
          backgroundColor: AppColors.appleRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }
    final dist = double.tryParse(_distanceCtrl.text.trim()) ?? 0.0;
    Provider.of<HealthProvider>(context, listen: false)
        .addActivity(type: _type, durationMinutes: dur, distanceKm: dist);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu hoạt động vận động! 🏃'),
        backgroundColor: AppColors.appleRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final health = Provider.of<HealthProvider>(context);
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final isWide  = AppConstants.isWide(context);

    final current  = health.todayActivityMinutes;
    final target   = health.goal.activityGoal;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.5) : 0.0;
    final calories = (current * 7.5).toInt();

    Widget body = CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              child: const Text('Vận động 🏃',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ),
          ),
        ),

        // Ring
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: SingleRingWidget(
                progress:    progress,
                color:       AppColors.appleRed,
                size:        isWide ? 220 : 190,
                strokeWidth: 22,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.directions_run_rounded,
                      color: AppColors.appleRed, size: 24),
                    const SizedBox(height: 6),
                    Text('$current',
                      style: const TextStyle(
                        fontSize: 36, fontWeight: FontWeight.w800,
                        letterSpacing: -1.5, color: Colors.white)),
                    Text('/ $target phút',
                      style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                    const SizedBox(height: 4),
                    Text('~$calories kcal',
                      style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600,
                        color: AppColors.appleRed)),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Activity Type chips
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Loại hoạt động',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.activityTypes.map((type) {
                    final isSelected = _type == type;
                    final icon = AppConstants.activityIcons[type] ?? Icons.sports_rounded;
                    return GestureDetector(
                      onTap: () => setState(() => _type = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.appleRed.withValues(alpha: 0.2)
                              : (isDark ? AppColors.card2 : const Color(0xFFF2F2F7)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppColors.appleRed : Colors.transparent,
                            width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(icon, size: 14,
                              color: isSelected ? AppColors.appleRed : AppColors.label2),
                            const SizedBox(width: 6),
                            Text(type,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                color: isSelected ? AppColors.appleRed : AppColors.label2)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // Duration & Distance inputs
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card1 : Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Chi tiết hoạt động',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _AppleTextField(
                          controller: _durationCtrl,
                          label: 'Thời gian (phút)',
                          icon: Icons.timer_outlined,
                          color: AppColors.appleRed,
                          keyboardType: TextInputType.number,
                          isDark: isDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _AppleTextField(
                          controller: _distanceCtrl,
                          label: 'Khoảng cách (km)',
                          icon: Icons.map_outlined,
                          color: AppColors.appleOrange,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appleRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('LƯU HOẠT ĐỘNG',
                        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Today's log
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
            child: const Text('Hoạt động hôm nay',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        health.todayActivities.isEmpty
            ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Chưa có hoạt động nào hôm nay',
                    style: TextStyle(color: AppColors.label2)))))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final item = health.todayActivities[i];
                    final icon = AppConstants.activityIcons[item.type] ?? Icons.sports_rounded;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 0, isWide ? 28 : 20, 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.card1 : Colors.white,
                          borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.appleRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12)),
                            child: Icon(icon, color: AppColors.appleRed, size: 18),
                          ),
                          title: Text('${item.type}  •  ${item.duration} phút',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: Text(
                            '~${item.calories} kcal ${item.distance > 0 ? "• ${item.distance} km" : ""}',
                            style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                        ),
                      ),
                    );
                  },
                  childCount: health.todayActivities.length,
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide
          ? Center(child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600), child: body))
          : body,
    );
  }
}

class _AppleTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color color;
  final TextInputType keyboardType;
  final bool isDark;

  const _AppleTextField({
    required this.controller, required this.label,
    required this.icon, required this.color,
    required this.keyboardType, required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller:   controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText:  label,
        prefixIcon: Icon(icon, color: color),
        filled:     true,
        fillColor:  isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
        border:     OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: color, width: 1.5)),
        labelStyle: const TextStyle(color: AppColors.label2),
      ),
    );
  }
}

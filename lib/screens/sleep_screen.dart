import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../utils/constants.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime  = const TimeOfDay(hour: 7,  minute: 0);
  String    _quality   = 'Tốt';

  double get _duration {
    final sm = _sleepTime.hour * 60 + _sleepTime.minute;
    final wm = _wakeTime.hour  * 60 + _wakeTime.minute;
    int diff = wm - sm;
    if (diff <= 0) diff += 24 * 60;
    return diff / 60.0;
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  void _save() {
    final health = Provider.of<HealthProvider>(context, listen: false);
    health.addSleep(
      sleepTime: _fmt(_sleepTime),
      wakeTime:  _fmt(_wakeTime),
      duration:  _duration,
      quality:   _quality,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu giấc ngủ! 😴'),
        backgroundColor: AppColors.applePurple,
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

    final sleepP = health.goal.sleepGoal > 0 && health.latestSleep != null
        ? (health.latestSleep!.duration / health.goal.sleepGoal).clamp(0.0, 1.5)
        : 0.0;

    Widget body = CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              child: const Text('Giấc ngủ 😴',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ),
          ),
        ),

        // Ring + latest
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: isWide ? 200.0 : 180.0,
                        height: isWide ? 200.0 : 180.0,
                        child: CircularProgressIndicator(
                          value: sleepP.clamp(0.0, 1.0),
                          strokeWidth: 20,
                          backgroundColor: AppColors.applePurple.withValues(alpha: 0.12),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.applePurple),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bedtime_rounded, color: AppColors.applePurple, size: 24),
                          const SizedBox(height: 6),
                          Text(
                            health.latestSleep != null
                                ? health.latestSleep!.duration.toStringAsFixed(1)
                                : '0.0',
                            style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.w800,
                              letterSpacing: -1.5, color: Colors.white)),
                          Text('/ ${health.goal.sleepGoal} giờ',
                            style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (health.latestSleep != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.applePurple.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${health.latestSleep!.sleepTime} → ${health.latestSleep!.wakeTime}  •  ${health.latestSleep!.quality}',
                        style: const TextStyle(
                          color: AppColors.applePurple,
                          fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
            ),
          ),
        ),

        // Entry form
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
                  const Text('Ghi nhận giấc ngủ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  // Time pickers
                  Row(
                    children: [
                      Expanded(child: _TimePicker(
                        label: '🌙 Đi ngủ',
                        time:  _sleepTime,
                        color: AppColors.applePurple,
                        onTap: () async {
                          final t = await showTimePicker(context: context, initialTime: _sleepTime);
                          if (t != null) setState(() => _sleepTime = t);
                        },
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _TimePicker(
                        label: '☀️ Thức dậy',
                        time:  _wakeTime,
                        color: AppColors.appleYellow,
                        onTap: () async {
                          final t = await showTimePicker(context: context, initialTime: _wakeTime);
                          if (t != null) setState(() => _wakeTime = t);
                        },
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Duration display
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.applePurple.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time_rounded,
                          color: AppColors.applePurple, size: 18),
                        const SizedBox(width: 8),
                        Text('${_duration.toStringAsFixed(1)} giờ ngủ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.applePurple, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quality selector
                  const Text('Chất lượng giấc ngủ',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.label2)),
                  const SizedBox(height: 10),
                  Row(
                    children: AppConstants.sleepQualities.map((q) {
                      final isSelected = _quality == q;
                      final qColor = q == 'Tốt' ? AppColors.appleGreen
                          : q == 'Trung bình' ? AppColors.appleOrange
                          : AppColors.appleRed;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _quality = q),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? qColor.withValues(alpha: 0.2)
                                    : (isDark ? AppColors.card2 : const Color(0xFFF2F2F7)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? qColor : Colors.transparent,
                                  width: 1.5),
                              ),
                              child: Text(q,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color:  isSelected ? qColor : AppColors.label2,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  fontSize: 13)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.applePurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('LƯU GIẤC NGỦ',
                        style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // History
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isWide ? 28 : 20),
            child: const Text('Lịch sử giấc ngủ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        health.sleepList.isEmpty
            ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Chưa có lịch sử giấc ngủ',
                    style: TextStyle(color: AppColors.label2))),
                ))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final item = health.sleepList[i];
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
                              color: AppColors.applePurple.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.bedtime_rounded,
                              color: AppColors.applePurple, size: 18),
                          ),
                          title: Text('${item.duration.toStringAsFixed(1)} giờ (${item.quality})',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                          subtitle: Text('Ngủ ${item.sleepTime} — Dậy ${item.wakeTime}  •  ${item.date}',
                            style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                        ),
                      ),
                    );
                  },
                  childCount: health.sleepList.length,
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

class _TimePicker extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final Color color;
  final VoidCallback onTap;

  const _TimePicker({
    required this.label, required this.time,
    required this.color, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          children: [
            Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                color: isDark ? AppColors.label2 : AppColors.subtitleLight)),
            const SizedBox(height: 6),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: color, letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }
}

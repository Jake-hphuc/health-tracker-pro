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
        content: const Text('Đã lưu dữ liệu giấc ngủ! 😴'),
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
    final cardBg  = isDark ? AppColors.card1 : Colors.white;

    final body = ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 100),
      children: [
        SafeArea(
          bottom: false,
          child: const Text('Giấc ngủ 🌙',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        ),
        const SizedBox(height: 20),

        // Duration summary card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.applePurple.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text('Thời lượng ngủ dự tính',
                style: TextStyle(fontSize: 13, color: AppColors.label2, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                '${_duration.toInt()}h ${((_duration % 1) * 60).toInt()}m',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: AppColors.applePurple,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _TimePickerButton(
                    label: 'Giờ đi ngủ',
                    time: _sleepTime,
                    icon: Icons.bedtime_rounded,
                    color: AppColors.applePurple,
                    onPicked: (t) => setState(() => _sleepTime = t),
                  ),
                  Container(width: 1, height: 40, color: isDark ? AppColors.separator : Colors.grey.shade300),
                  _TimePickerButton(
                    label: 'Giờ thức dậy',
                    time: _wakeTime,
                    icon: Icons.wb_sunny_rounded,
                    color: AppColors.appleYellow,
                    onPicked: (t) => setState(() => _wakeTime = t),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quality selector
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chất lượng giấc ngủ',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: AppConstants.sleepQuality.map((q) {
                  final isSelected = _quality == q;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _quality = q),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.applePurple
                              : (isDark ? AppColors.card2 : const Color(0xFFF2F2F7)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          q,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : (isDark ? AppColors.label2 : Colors.black87),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Save Button
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.applePurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('LƯU BẢN GHI GIẤC NGỦ',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 24),

        // History
        const Text('Lịch sử giấc ngủ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
        const SizedBox(height: 12),
        if (health.sleepList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Chưa có dữ liệu giấc ngủ\nHãy ghi nhận giấc ngủ đầu tiên! 🌙',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.label2, height: 1.5)),
            ),
          )
        else
          ...health.sleepList.map((item) => Container(
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
                    color: AppColors.applePurple.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bedtime_rounded,
                    color: AppColors.applePurple, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.sleepTime} → ${item.wakeTime}',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text(item.date,
                        style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${item.duration.toStringAsFixed(1)} giờ',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.applePurple)),
                    Text(item.quality,
                      style: const TextStyle(fontSize: 11, color: AppColors.label2)),
                  ],
                ),
              ],
            ),
          )),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide ? Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 680), child: body)) : body,
    );
  }
}

class _TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final IconData icon;
  final Color color;
  final Function(TimeOfDay) onPicked;

  const _TimePickerButton({
    required this.label,
    required this.time,
    required this.icon,
    required this.color,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: time);
        if (picked != null) onPicked(picked);
      },
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.label2)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

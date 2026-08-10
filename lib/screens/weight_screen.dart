import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _save() {
    final w = double.tryParse(_ctrl.text.trim());
    if (w == null || w <= 20 || w > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập cân nặng hợp lệ (20–300 kg)'),
          backgroundColor: AppColors.appleRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }

    final height = Provider.of<AuthProvider>(context, listen: false).currentUser?.height ?? 170.0;
    Provider.of<HealthProvider>(context, listen: false).addWeight(w, height);
    _ctrl.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã cập nhật cân nặng & BMI! ⚖️'),
        backgroundColor: AppColors.appleOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final health = Provider.of<HealthProvider>(context);
    final auth   = Provider.of<AuthProvider>(context);
    final isDark  = Theme.of(context).brightness == Brightness.dark;
    final isWide  = AppConstants.isWide(context);

    final latest   = health.latestWeight;
    final bmi      = latest?.bmi ?? 0.0;
    final bmiColor = AppConstants.getBMIColor(bmi);
    final bmiCat   = AppConstants.getBMICategory(bmi);

    Widget body = CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
              child: const Text('Cân nặng & BMI ⚖️',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ),
          ),
        ),

        // BMI Hero Card
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 24, isWide ? 28 : 20, 0),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.card1 : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: bmiColor.withValues(alpha: 0.12),
                    blurRadius: 24, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Weight
                  Column(
                    children: [
                      Text(latest != null ? '${latest.weight}' : '--',
                        style: TextStyle(
                          fontSize: 44, fontWeight: FontWeight.w900,
                          letterSpacing: -2, color: AppColors.appleOrange)),
                      const Text('kg',
                        style: TextStyle(fontSize: 14, color: AppColors.label2, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      const Text('Cân nặng',
                        style: TextStyle(fontSize: 12, color: AppColors.label2)),
                    ],
                  ),
                  Container(width: 1, height: 60, color: AppColors.separator),
                  // BMI
                  Column(
                    children: [
                      Text(bmi > 0 ? bmi.toStringAsFixed(1) : '--',
                        style: TextStyle(
                          fontSize: 44, fontWeight: FontWeight.w900,
                          letterSpacing: -2, color: bmiColor)),
                      const Text('BMI',
                        style: TextStyle(fontSize: 14, color: AppColors.label2, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      if (bmi > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: bmiColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20)),
                          child: Text(bmiCat,
                            style: TextStyle(
                              color: bmiColor, fontSize: 11, fontWeight: FontWeight.w700)),
                        )
                      else
                        const Text('Chưa có dữ liệu',
                          style: TextStyle(fontSize: 12, color: AppColors.label2)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        // Profile info
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 12, isWide ? 28 : 20, 0),
            child: Text(
              '📏 Chiều cao hồ sơ: ${auth.currentUser?.height ?? 170} cm',
              style: const TextStyle(fontSize: 12, color: AppColors.label2)),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // Input form
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
                  const Text('Nhập cân nặng hôm nay',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _ctrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Cân nặng (kg)',
                      prefixIcon: const Icon(Icons.monitor_weight_outlined,
                        color: AppColors.appleOrange),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      filled: true,
                      fillColor: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.appleOrange, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.appleOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('CẬP NHẬT CÂN NẶNG',
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
            child: const Text('Lịch sử cân nặng',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        health.weightHistory.isEmpty
            ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Chưa có dữ liệu cân nặng',
                    style: TextStyle(color: AppColors.label2)))))
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final item = health.weightHistory[health.weightHistory.length - 1 - i];
                    final c = AppConstants.getBMIColor(item.bmi);
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
                              color: c.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12)),
                            child: Icon(Icons.monitor_weight_rounded, color: c, size: 18),
                          ),
                          title: Text('${item.weight} kg',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                          subtitle: Text('BMI ${item.bmi.toStringAsFixed(1)}  •  ${AppConstants.getBMICategory(item.bmi)}  •  ${item.date}',
                            style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                        ),
                      ),
                    );
                  },
                  childCount: health.weightHistory.length,
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

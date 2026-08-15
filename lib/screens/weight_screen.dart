import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../utils/bmi_calculator.dart';

class WeightScreen extends StatefulWidget {
  const WeightScreen({super.key});

  @override
  State<WeightScreen> createState() => _WeightScreenState();
}

class _WeightScreenState extends State<WeightScreen> {
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _save() {
    final w = double.tryParse(_weightController.text.trim());
    if (w == null || w <= 20 || w > 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập cân nặng hợp lệ (20 - 300 kg)'),
          backgroundColor: AppColors.appleRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final auth   = Provider.of<AuthProvider>(context, listen: false);
    final health = Provider.of<HealthProvider>(context, listen: false);
    final height = auth.currentUser?.height ?? 170.0;

    health.addWeight(w, height);
    _weightController.clear();
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã ghi nhận cân nặng: $w kg! ⚖️'),
        backgroundColor: AppColors.appleOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth   = Provider.of<AuthProvider>(context);
    final health = Provider.of<HealthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    final latest = health.latestWeight;
    final bmi    = latest?.bmi ?? 0.0;
    final bmiCat = BmiCalculator.getBmiCategory(bmi);
    final bmiCol = Color(BmiCalculator.getBmiColor(bmi));

    final body = ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 100),
      children: [
        SafeArea(
          bottom: false,
          child: const Text('Cân nặng & BMI ⚖️',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        ),
        const SizedBox(height: 20),

        // BMI Card
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.appleOrange.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Cân nặng gần nhất',
                        style: TextStyle(fontSize: 13, color: AppColors.label2, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            latest != null ? '${latest.weight}' : '--',
                            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, letterSpacing: -1),
                          ),
                          const SizedBox(width: 4),
                          const Text('kg',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.label2)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: bmiCol.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: bmiCol.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        Text('BMI: ${bmi > 0 ? bmi.toStringAsFixed(1) : '--'}',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: bmiCol)),
                        const SizedBox(height: 2),
                        Text(bmiCat,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: bmiCol)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Input row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Nhập cân nặng mới...',
                        suffixText: 'kg',
                        prefixIcon: const Icon(Icons.monitor_weight_outlined, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.appleOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Lưu',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '📏 Chiều cao hồ sơ: ${auth.currentUser?.height ?? 170} cm',
                style: const TextStyle(fontSize: 12, color: AppColors.label2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // History
        const Text('Lịch sử cân nặng',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
        const SizedBox(height: 12),
        if (health.weightList.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text('Chưa có dữ liệu cân nặng\nHãy nhập chỉ số đầu tiên của bạn! ⚖️',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.label2, height: 1.5)),
            ),
          )
        else
          ...health.weightList.map((item) => Container(
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
                    color: AppColors.appleOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.monitor_weight_rounded,
                    color: AppColors.appleOrange, size: 18),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item.weight} kg',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(item.date,
                        style: const TextStyle(fontSize: 12, color: AppColors.label2)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(BmiCalculator.getBmiColor(item.bmi)).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'BMI ${item.bmi.toStringAsFixed(1)} · ${BmiCalculator.getBmiCategory(item.bmi)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(BmiCalculator.getBmiColor(item.bmi)),
                    ),
                  ),
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

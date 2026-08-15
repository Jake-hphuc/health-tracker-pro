import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../utils/constants.dart';

class HealthTipsScreen extends StatelessWidget {
  const HealthTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final tips = challengeProvider.healthTips;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);

    final body = ListView(
      padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 100),
      children: [
        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.appleTeal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.lightbulb_rounded, color: AppColors.appleTeal, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mẹo Sức Khỏe & Dinh Dưỡng 💡',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                        ),
                        Text(
                          'Kiến thức khoa học từ các chuyên gia y tế',
                          style: TextStyle(fontSize: 12, color: AppColors.label2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ...tips.map((tip) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card1 : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.appleTeal.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(tip.iconEmoji, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.appleTeal.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tip.category,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.appleTeal),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              tip.title,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    tip.summary,
                    style: const TextStyle(fontSize: 13, color: AppColors.label2, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      tip.content,
                      style: const TextStyle(fontSize: 13, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tác giả: ${tip.author}',
                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.label3),
                      ),
                      Text(
                        '⏱️ Đọc trong ${tip.readTimeMinutes}',
                        style: const TextStyle(fontSize: 11, color: AppColors.label3),
                      ),
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

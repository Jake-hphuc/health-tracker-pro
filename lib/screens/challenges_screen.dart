import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../utils/constants.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final challenges = challengeProvider.challenges;
    final userPoints = challengeProvider.userPoints;
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thử Thách & Điểm Thưởng 🏆',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.appleYellow, AppColors.appleOrange],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.stars_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '$userPoints Xu',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Hoàn thành các mục tiêu để tích lũy xu đổi quà voucher',
                style: TextStyle(fontSize: 13, color: AppColors.label2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Challenge Cards List
        ...challenges.map((challenge) {
          final progressPercent = (challenge.currentProgress / challenge.targetValue).clamp(0.0, 1.0);

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card1 : Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: challenge.badgeColor.withValues(alpha: isDark ? 0.12 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: challenge.badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(challenge.badgeIcon, color: challenge.badgeColor, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            challenge.description,
                            style: const TextStyle(fontSize: 12, color: AppColors.label2),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.appleYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${challenge.rewardPoints} Xu',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appleOrange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progressPercent,
                    backgroundColor: isDark ? AppColors.card2 : const Color(0xFFE5E5EA),
                    valueColor: AlwaysStoppedAnimation<Color>(challenge.badgeColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 10),

                // Progress text & Action Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ: ${challenge.currentProgress}/${challenge.targetValue} ${challenge.unit}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.label2),
                    ),
                    if (challenge.isClaimed)
                      const Text(
                        'Đã nhận thưởng ✓',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.appleGreen),
                      )
                    else if (challenge.isCompleted)
                      ElevatedButton(
                        onPressed: () {
                          challengeProvider.addDailyLoginPoints(challenge.rewardPoints);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Đã nhận ${challenge.rewardPoints} Xu thưởng! 🎉'),
                              backgroundColor: AppColors.appleGreen,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.appleGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Nhận Xu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      )
                    else
                      Text(
                        'Còn ${(challenge.targetValue - challenge.currentProgress).clamp(0, challenge.targetValue)} ${challenge.unit}',
                        style: const TextStyle(fontSize: 12, color: AppColors.label3),
                      ),
                  ],
                ),
              ],
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

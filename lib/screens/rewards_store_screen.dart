import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/challenge_provider.dart';
import '../utils/constants.dart';

class RewardsStoreScreen extends StatelessWidget {
  const RewardsStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challengeProvider = Provider.of<ChallengeProvider>(context);
    final vouchers = challengeProvider.vouchers;
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
                    'Đổi Quà & Ưu Đãi 🎁',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.appleRed, AppColors.appleOrange],
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
                'Dùng điểm tích lũy để nhận voucher phòng tập và thực phẩm Healthy',
                style: TextStyle(fontSize: 12, color: AppColors.label2),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        ...vouchers.map((voucher) {
          final isRedeemed = challengeProvider.redeemedVoucherIds.contains(voucher.id);
          final canAfford = userPoints >= voucher.pointsCost;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.card1 : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: isRedeemed ? Border.all(color: AppColors.appleGreen, width: 1.5) : null,
              boxShadow: [
                BoxShadow(
                  color: voucher.themeColor.withValues(alpha: isDark ? 0.12 : 0.06),
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
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: voucher.themeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(voucher.iconEmoji, style: const TextStyle(fontSize: 24)),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: voucher.themeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                voucher.brandCategory,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: voucher.themeColor),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              voucher.title,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: voucher.themeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          voucher.discount,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    voucher.description,
                    style: const TextStyle(fontSize: 12.5, color: AppColors.label2, height: 1.35),
                  ),
                  const SizedBox(height: 14),

                  if (isRedeemed)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.appleGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.appleGreen.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Mã Voucher của bạn:', style: TextStyle(fontSize: 11, color: AppColors.label2)),
                              Text(voucher.code, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1)),
                            ],
                          ),
                          const Icon(Icons.check_circle_rounded, color: AppColors.appleGreen, size: 24),
                        ],
                      ),
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.stars_rounded, color: AppColors.appleOrange, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${voucher.pointsCost} Xu',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.appleOrange),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'HSD: ${voucher.expiryDate}',
                              style: const TextStyle(fontSize: 11, color: AppColors.label3),
                            ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: canAfford
                              ? () async {
                                  final success = await challengeProvider.redeemVoucher(voucher.id, voucher.pointsCost);
                                  if (success && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Đổi voucher "${voucher.title}" thành công! 🎉'),
                                        backgroundColor: AppColors.appleGreen,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: voucher.themeColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: isDark ? AppColors.card2 : Colors.grey.shade300,
                            disabledForegroundColor: AppColors.label3,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text(
                            canAfford ? 'Đổi Quà' : 'Chưa Đủ Xu',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
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

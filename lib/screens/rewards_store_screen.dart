import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/challenge_provider.dart';
import '../models/reward_voucher.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class RewardsStoreScreen extends StatefulWidget {
  const RewardsStoreScreen({super.key});

  @override
  State<RewardsStoreScreen> createState() => _RewardsStoreScreenState();
}

class _RewardsStoreScreenState extends State<RewardsStoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['Tất cả 🏪', 'Phòng Gym 🏋️', 'Ăn uống Healthy 🥗'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showVoucherDetail(BuildContext context, RewardVoucher voucher, ChallengeProvider challengeProv, bool isGuest) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canAfford = challengeProv.userPoints >= voucher.pointsCost;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.card1 : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.separator : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: voucher.themeColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(voucher.icon, color: voucher.themeColor, size: 36),
              ),
              const SizedBox(height: 16),

              Text(
                voucher.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
              ),
              const SizedBox(height: 6),
              Text(
                voucher.partnerName,
                style: TextStyle(fontSize: 14, color: voucher.themeColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Discount Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: voucher.themeColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  voucher.discountText,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                voucher.description,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.label2, height: 1.4),
              ),
              const SizedBox(height: 24),

              // Point Cost Row
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.card2 : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Chi phí đổi thưởng', style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded, color: AppColors.appleYellow, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${voucher.pointsCost} điểm',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.appleYellow),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              if (!canAfford)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.appleRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: AppColors.appleRed, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Bạn cần thêm ${voucher.pointsCost - challengeProv.userPoints} điểm nữa',
                        style: const TextStyle(fontSize: 12, color: AppColors.appleRed, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),

              // Redeem / Guest CTA
              SizedBox(
                width: double.infinity,
                child: isGuest
                    ? _buildGuestUpgradeCTA(context)
                    : voucher.isRedeemed
                        ? _buildRedeemedState(voucher)
                        : ElevatedButton.icon(
                            onPressed: canAfford
                                ? () {
                                    final ok = challengeProv.redeemVoucher(voucher.id);
                                    Navigator.pop(ctx);
                                    if (ok) {
                                      _showVoucherCodeDialog(context, voucher, isDark);
                                    }
                                  }
                                : null,
                            icon: const Icon(Icons.redeem_rounded, size: 20),
                            label: const Text(
                              'ĐỔI VOUCHER NGAY',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: voucher.themeColor,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: AppColors.label3.withValues(alpha: 0.3),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRedeemedState(RewardVoucher voucher) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.appleGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.appleGreen),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.appleGreen, size: 28),
          const SizedBox(height: 6),
          const Text(
            'Đã đổi thành công!',
            style: TextStyle(color: AppColors.appleGreen, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 4),
          Text(
            'Mã: ${voucher.voucherCode}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestUpgradeCTA(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.pop(context);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      icon: const Icon(Icons.person_add_rounded, size: 20),
      label: const Text(
        'ĐĂNG KÝ ĐỂ ĐỔI VOUCHER',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.appleGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  void _showVoucherCodeDialog(BuildContext context, RewardVoucher voucher, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.card1 : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.celebration_rounded, color: AppColors.appleYellow, size: 28),
            SizedBox(width: 10),
            Text('Đổi thưởng thành công!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Voucher từ ${voucher.partnerName}', style: const TextStyle(color: AppColors.label2, fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: voucher.themeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: voucher.themeColor.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  const Text('MÃ VOUCHER CỦA BẠN', style: TextStyle(fontSize: 11, color: AppColors.label2, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    voucher.voucherCode,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      color: voucher.themeColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Xuất trình mã này tại quầy thu ngân hoặc nhập khi đặt hàng online.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.label2, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đã hiểu', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final challengeProv = Provider.of<ChallengeProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    final isGuest = authProv.isGuest;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = AppConstants.isWide(context);
    final cardBg = isDark ? AppColors.card1 : Colors.white;

    Widget body = Column(
      children: [
        // Header
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(isWide ? 28 : 20, 20, isWide ? 28 : 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Đổi Điểm & Nhận Quà 🎁',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isGuest
                                ? 'Đăng ký tài khoản để tích điểm & đổi voucher'
                                : 'Đổi điểm thưởng lấy ưu đãi tại cơ sở liên kết',
                            style: const TextStyle(fontSize: 12, color: AppColors.label2),
                          ),
                        ],
                      ),
                    ),
                    // Points Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isGuest
                            ? AppColors.label3.withValues(alpha: 0.2)
                            : AppColors.appleYellow.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isGuest ? AppColors.label3 : AppColors.appleYellow,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            color: isGuest ? AppColors.label3 : AppColors.appleYellow,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isGuest ? '--' : '${challengeProv.userPoints} đ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isGuest ? AppColors.label3 : AppColors.appleYellow,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Guest Upsell Banner
                if (isGuest) ...[
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.appleGreen.withValues(alpha: 0.9),
                            AppColors.appleBlue.withValues(alpha: 0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Row(
                        children: [
                          Text('🎁', style: TextStyle(fontSize: 28)),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mỗi ngày đăng nhập = +10 điểm thưởng!',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Đăng ký ngay để tích điểm & đổi gym pass, voucher ăn uống.',
                                  style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],

                // Member Benefits Row (for logged in users)
                if (!isGuest) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.appleGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt_rounded, color: AppColors.appleGreen, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Đăng nhập mỗi ngày tích +10 điểm. Hoàn thành thử thách nhận thêm điểm!',
                            style: TextStyle(fontSize: 12, color: AppColors.appleGreen, fontWeight: FontWeight.w600, height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Tab Bar
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
                  labelColor: AppColors.appleGreen,
                  unselectedLabelColor: AppColors.label2,
                  indicatorColor: AppColors.appleGreen,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  tabs: _categories.map((c) => Tab(text: c)).toList(),
                ),
              ],
            ),
          ),
        ),

        // Voucher Grid
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: _categories.map((cat) {
              final filtered = cat == 'Tất cả 🏪'
                  ? challengeProv.vouchers
                  : challengeProv.vouchers.where((v) => v.category == cat).toList();

              return ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  isWide ? 28 : 20, 16, isWide ? 28 : 20, 100,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final voucher = filtered[index];
                  final canAfford = challengeProv.userPoints >= voucher.pointsCost;

                  return GestureDetector(
                    onTap: () => _showVoucherDetail(context, voucher, challengeProv, isGuest),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(22),
                        border: voucher.isRedeemed
                            ? Border.all(color: AppColors.appleGreen, width: 1.5)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: voucher.themeColor.withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: voucher.isRedeemed
                                    ? AppColors.appleGreen.withValues(alpha: 0.15)
                                    : voucher.themeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                voucher.isRedeemed ? Icons.check_circle_rounded : voucher.icon,
                                color: voucher.isRedeemed ? AppColors.appleGreen : voucher.themeColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    voucher.title,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    voucher.partnerName,
                                    style: TextStyle(fontSize: 11, color: voucher.themeColor, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: voucher.themeColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          voucher.discountText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: voucher.themeColor,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.stars_rounded,
                                            color: (!isGuest && canAfford) ? AppColors.appleYellow : AppColors.label3,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 3),
                                          Text(
                                            '${voucher.pointsCost}đ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                              color: (!isGuest && canAfford) ? AppColors.appleYellow : AppColors.label3,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.label3,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.blackBg : AppColors.lightBg,
      body: isWide
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: body,
              ),
            )
          : body,
    );
  }
}

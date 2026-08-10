import 'package:flutter/material.dart';
import '../models/challenge.dart';
import '../models/athlete_plan.dart';
import '../models/health_tip.dart';
import '../models/reward_voucher.dart';
import '../utils/constants.dart';

class ChallengeProvider with ChangeNotifier {
  int _userPoints = 500;
  String? _activeAthletePlanId;

  int get userPoints => _userPoints;
  String? get activeAthletePlanId => _activeAthletePlanId;

  // List of Monthly Challenges
  final List<Challenge> _challenges = [
    Challenge(
      id: 'c1',
      title: 'Thử thách Bứt phá 120 phút',
      description: 'Hoàn thành tổng cộng 120 phút vận động thể thao trong tháng 8.',
      month: 'Tháng 8',
      targetValue: 120,
      unit: 'phút',
      currentProgress: 75,
      rewardPoints: 100,
      badgeName: 'Chiến binh Vận động 🏅',
      badgeIcon: Icons.directions_run_rounded,
      themeColor: AppColors.appleRed,
    ),
    Challenge(
      id: 'c2',
      title: 'Đại dương Cơ thể (15.000ml)',
      description: 'Uống tổng cộng 15.000ml nước trong tháng để cấp ẩm tối ưu.',
      month: 'Tháng 8',
      targetValue: 15000,
      unit: 'ml',
      currentProgress: 15000,
      rewardPoints: 150,
      badgeName: 'Bậc thầy Cấp nước 💧',
      badgeIcon: Icons.water_drop_rounded,
      themeColor: AppColors.appleBlue,
    ),
    Challenge(
      id: 'c3',
      title: '7 Đêm Giấc ngủ Vàng',
      description: 'Tích lũy 56 giờ ngủ chất lượng để phục hồi cơ thể trọn vẹn.',
      month: 'Tháng 8',
      targetValue: 56,
      unit: 'giờ',
      currentProgress: 42,
      rewardPoints: 200,
      badgeName: 'Chủ nhân Giấc ngủ 🌙',
      badgeIcon: Icons.bedtime_rounded,
      themeColor: AppColors.applePurple,
    ),
    Challenge(
      id: 'c4',
      title: 'Kỷ luật Thể thao 30 ngày',
      description: 'Ghi nhận vận động ít nhất 20 phút mỗi ngày liên tục.',
      month: 'Tháng 8',
      targetValue: 30,
      unit: 'ngày',
      currentProgress: 18,
      rewardPoints: 300,
      badgeName: 'Kỷ luật Thép ⚡',
      badgeIcon: Icons.bolt_rounded,
      themeColor: AppColors.appleOrange,
    ),
  ];

  List<Challenge> get challenges => _challenges;

  // List of Unlocked Badges
  final List<BadgeReward> _unlockedBadges = [
    BadgeReward(
      id: 'b1',
      name: 'Chào sân Health Pro 🌟',
      description: 'Hoàn thành hồ sơ sức khỏe đầu tiên',
      icon: Icons.stars_rounded,
      color: AppColors.appleYellow,
      unlockedDate: '01/08/2026',
    ),
    BadgeReward(
      id: 'b2',
      name: 'Bậc thầy Cấp nước 💧',
      description: 'Đạt mốc 15.000ml nước uống tháng 8',
      icon: Icons.water_drop_rounded,
      color: AppColors.appleBlue,
      unlockedDate: '05/08/2026',
    ),
  ];

  List<BadgeReward> get unlockedBadges => _unlockedBadges;

  // Partner Vouchers System
  final List<RewardVoucher> _vouchers = [
    RewardVoucher(
      id: 'v1',
      title: 'Voucher Giảm 50% Gói Gym 6 Tháng',
      partnerName: 'California Fitness & Yoga 🏋️‍♂️',
      category: 'Phòng Gym 🏋️',
      pointsCost: 200,
      discountText: 'Giảm 50% chi phí tập',
      description: 'Áp dụng trên toàn bộ hệ thống cơ sở California Fitness toàn quốc.',
      icon: Icons.fitness_center_rounded,
      themeColor: AppColors.appleRed,
      voucherCode: 'CALI50-PRO-8899',
    ),
    RewardVoucher(
      id: 'v2',
      title: 'Pass 1 Tháng Tập Gym Không Giới Hạn',
      partnerName: 'Elite Fitness Club 💎',
      category: 'Phòng Gym 🏋️',
      pointsCost: 300,
      discountText: 'Miễn phí 100% 30 ngày',
      description: 'Trải nghiệm phòng tập 5 sao, bể bơi bốn mùa & xông hơi khoáng nóng.',
      icon: Icons.card_membership_rounded,
      themeColor: AppColors.appleGreen,
      voucherCode: 'ELITE30-VIP-7721',
    ),
    RewardVoucher(
      id: 'v3',
      title: 'Voucher 50.000đ Bữa Ăn Healthy Salad',
      partnerName: 'Green Healthy Salad Bar 🥗',
      category: 'Ăn uống Healthy 🥗',
      pointsCost: 100,
      discountText: 'Giảm 50.000đ trực tiếp',
      description: 'Áp dụng cho mọi hóa đơn mua salad, smoothie & nước ép hoa quả.',
      icon: Icons.restaurant_rounded,
      themeColor: AppColors.appleOrange,
      voucherCode: 'GREEN50-HEALTHY',
    ),
    RewardVoucher(
      id: 'v4',
      title: 'Voucher Giảm 100k Mua Whey Protein',
      partnerName: 'Whey Store Pro 🥤',
      category: 'Ăn uống Healthy 🥗',
      pointsCost: 150,
      discountText: 'Giảm 100.000đ hóa đơn',
      description: 'Áp dụng mua sữa tăng cơ Whey Isolate, BCAA & Vitamin tổng hợp.',
      icon: Icons.local_drink_rounded,
      themeColor: AppColors.appleBlue,
      voucherCode: 'WHEY100-PRO-99',
    ),
    RewardVoucher(
      id: 'v5',
      title: 'Miễn Phí 3 Buổi Tập Yoga Thư Giãn',
      partnerName: 'Zen Yoga & Meditation 🧘‍♀️',
      category: 'Phòng Gym 🏋️',
      pointsCost: 120,
      discountText: 'Tặng 3 buổi Yoga free',
      description: 'Luyện tập dẻo dai & thiền định giảm căng thẳng với HLV Ấn Độ.',
      icon: Icons.self_improvement_rounded,
      themeColor: AppColors.applePurple,
      voucherCode: 'ZEN3-YOGA-FREE',
    ),
  ];

  List<RewardVoucher> get vouchers => _vouchers;

  // List of KOLs & Athletes
  final List<AthletePlan> _athletePlans = [
    AthletePlan(
      id: 'kol_haaland',
      name: 'Erling Haaland ⚽',
      role: 'Tiền đạo Bóng đá Đỉnh cao',
      avatarEmoji: '⚽',
      tagline: 'Lịch tập sức mạnh, nước lọc kiềm & giấc ngủ 9 tiếng với kính chống ánh sáng xanh.',
      themeColor: AppColors.appleGreen,
      dailyWaterMl: 3500,
      dailySleepHours: 9.0,
      dailyActivityMinutes: 90,
      workoutRoutine: [
        'Sáng (07:30): Chạy bứt tốc 45 phút + Bài tập cơ trung tâm (Core)',
        'Chiều (15:00): Tập gym tạ nặng (Squat, Deadlift, Bench press)',
        'Tối (19:30): Co giãn cơ nhẹ nhàng & xông hơi thư giãn',
      ],
      mealPlan: [
        'Bữa sáng: Trứng ốp la, gan bò tươi, sinh tố sinh học & nước khoáng kiềm',
        'Bữa trưa: Bít tết bò nướng, mì pasta nguyên cám, rau xanh đậm',
        'Bữa tối: Cá hồi nướng húng tây, khoai lang hấp & quả bơ',
      ],
      sleepTips: [
        'Đeo kính lọc ánh sáng xanh 2 tiếng trước khi đi ngủ',
        'Phòng ngủ đạt độ lạnh chuẩn 18°C & tối hoàn toàn',
        'Tắt toàn bộ thiết bị Wi-Fi & điện thoại lúc 21:30',
      ],
      proTip: 'Ăn thực phẩm nguyên bản, uống nước khoáng sạch & coi giấc ngủ là vũ khí bí mật lớn nhất!',
    ),
    AthletePlan(
      id: 'kol_kipchoge',
      name: 'Eliud Kipchoge 🏃‍♂️',
      role: 'Kỷ kỷ lục gia Marathon Thế giới',
      avatarEmoji: '🏃‍♂️',
      tagline: 'Phương pháp chạy bền bỉ, dinh dưỡng giàu tinh bột lành mạnh & kỷ luật mỗi ngày.',
      themeColor: AppColors.appleRed,
      dailyWaterMl: 3000,
      dailySleepHours: 8.5,
      dailyActivityMinutes: 75,
      workoutRoutine: [
        'Sáng (06:00): Chạy đường dài 20km nhịp độ đều',
        'Chiều (16:00): Chạy thả lỏng 8km + Tập phục hồi khớp',
        'Chủ nhật: Nhảy dây & giãn cơ sâu',
      ],
      mealPlan: [
        'Bữa sáng: Bánh Ugali truyền thống, chuối luộc & trà đen Kenya',
        'Bữa trưa: Cơm gạo lứt, đậu hầm rau củ & quả bơ',
        'Bữa tối: Thịt gà luộc, súp rau & sữa tươi',
      ],
      sleepTips: [
        'Đi ngủ đúng 21:00 mỗi tối không ngoại lệ',
        'Ngủ trưa 1 tiếng từ 12:30 đến 13:30 để tái tạo năng lượng',
      ],
      proTip: 'Không ai có giới hạn. Kỷ luật nhỏ tạo nên thành tựu lớn.',
    ),
    AthletePlan(
      id: 'kol_anna',
      name: 'Fitness Coach Anna 🧘‍♀️',
      role: 'Chuyên gia Pilates & Dinh dưỡng',
      avatarEmoji: '🧘‍♀️',
      tagline: 'Luyện tập dẻo dai, nhịp sống healthy, làn da sáng khỏe & tâm trí bình yên.',
      themeColor: AppColors.applePurple,
      dailyWaterMl: 2500,
      dailySleepHours: 8.0,
      dailyActivityMinutes: 45,
      workoutRoutine: [
        'Sáng (06:30): 30 phút Yoga vươn thở đón bình minh',
        'Chiều (17:00): 45 phút Pilates siết cơ bụng & thắt lưng',
        'Tối (20:30): Meditate (Thiền định) 15 phút trước khi ngủ',
      ],
      mealPlan: [
        'Bữa sáng: Smoothie detox táo green apple, rau bina, hạt chia',
        'Bữa trưa: Salad ức gà nướng áp chảo với sốt dầu ô liu',
        'Bữa tối: Cá ngừ áp chảo, măng tây nướng & trà hoa cúc',
      ],
      sleepTips: [
        'Ngâm chân nước ấm với muối Himalaya 15 phút trước khi ngủ',
        'Xịt tinh dầu hoa khuyết lavender lên gối ngủ',
      ],
      proTip: 'Hãy lắng nghe cơ thể. Tập luyện là hành trình yêu thương bản thân!',
    ),
  ];

  List<AthletePlan> get athletePlans => _athletePlans;

  // List of Health Tips
  final List<HealthTip> _healthTips = [
    HealthTip(
      id: 't1',
      title: 'Quy tắc 8/20 trong Uống nước đúng cách',
      category: 'Dinh dưỡng',
      author: 'Dr. Andrew Huberman',
      readTime: '3 phút',
      summary: '80% lượng nước nên uống vào ban ngày và 20% còn lại trước 19:30 tối để đảm bảo giấc ngủ không bị gián đoạn.',
      bulletPoints: [
        'Uống 500ml nước ngay sau khi thức dậy để kích hoạt hệ tiêu hóa.',
        'Chia nhỏ lượng nước uống thành từng ngụm, không uống dồn dập.',
        'Hạn chế nước đá quá lạnh gây co thắt mạch máu dạ dày.',
      ],
      icon: Icons.local_drink_rounded,
      themeColor: AppColors.appleBlue,
    ),
    HealthTip(
      id: 't2',
      title: 'Tăng 30% Calo tiêu hao với bài tập Tabata 4 phút',
      category: 'Vận động',
      author: 'HLV Fitness Pro',
      readTime: '4 phút',
      summary: 'Chỉ với 4 phút tập cường độ cao (20s tập - 10s nghỉ), cơ thể tiếp tục đốt calo liên tục trong 12 tiếng sau đó.',
      bulletPoints: [
        '20 giây Burpees hết sức 🏃',
        '10 giây nghỉ thả lỏng ⏱️',
        'Lặp lại 8 hiệp liên tiếp để tối ưu năng lượng đốt mỡ.',
      ],
      icon: Icons.bolt_rounded,
      themeColor: AppColors.appleRed,
    ),
    HealthTip(
      id: 't3',
      title: 'Bí quyết Giấc ngủ REM sâu phục hồi não bộ',
      category: 'Giấc ngủ',
      author: 'Viện Y học Giấc ngủ',
      readTime: '3 phút',
      summary: 'Giấc ngủ REM giúp củng cố trí nhớ và chữa lành tổn thương tế bào não sau ngày làm việc căng thẳng.',
      bulletPoints: [
        'Giữ nhiệt độ phòng từ 18 - 20°C giúp cơ thể hạ thân nhiệt tự nhiên.',
        'Không dùng cafein sau 14:00 chiều.',
        'Thực hành bài tập thở 4-7-8 trước khi nhắm mắt.',
      ],
      icon: Icons.bedtime_rounded,
      themeColor: AppColors.applePurple,
    ),
    HealthTip(
      id: 't4',
      title: 'Thực đơn Eat Clean 7 ngày thanh lọc cơ thể',
      category: 'Dinh dưỡng',
      author: 'Chuyên gia Dinh dưỡng',
      readTime: '5 phút',
      summary: 'Cắt giảm đường tinh luyện và thực phẩm chế biến sẵn để phục hồi năng lượng và làm sạch làn da.',
      bulletPoints: [
        'Ưu tiên tinh bột chậm: Khoai lang, yến mạch, gạo lứt.',
        'Bổ sung chất béo tốt từ quả bơ, hạt bơ & cá hồi.',
        'Uống đủ nước ép rau xanh mỗi ngày.',
      ],
      icon: Icons.restaurant_rounded,
      themeColor: AppColors.appleGreen,
    ),
  ];

  List<HealthTip> get healthTips => _healthTips;

  // Actions
  void claimChallengeReward(String challengeId) {
    final index = _challenges.indexWhere((c) => c.id == challengeId);
    if (index != -1 && _challenges[index].isCompleted && !_challenges[index].isClaimed) {
      final challenge = _challenges[index];
      _userPoints += challenge.rewardPoints;
      _challenges[index] = challenge.copyWith(isClaimed: true);

      // Add badge
      _unlockedBadges.add(
        BadgeReward(
          id: 'badge_${DateTime.now().millisecondsSinceEpoch}',
          name: challenge.badgeName,
          description: 'Hoàn thành thử thách ${challenge.title}',
          icon: challenge.badgeIcon,
          color: challenge.themeColor,
          unlockedDate: 'Hôm nay',
        ),
      );

      notifyListeners();
    }
  }

  bool redeemVoucher(String voucherId) {
    final index = _vouchers.indexWhere((v) => v.id == voucherId);
    if (index != -1) {
      final voucher = _vouchers[index];
      if (!voucher.isRedeemed && _userPoints >= voucher.pointsCost) {
        _userPoints -= voucher.pointsCost;
        voucher.isRedeemed = true;
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  void applyAthletePlan(String planId) {
    _activeAthletePlanId = planId;
    notifyListeners();
  }

  void addDailyLoginPoints(int pts) {
    _userPoints += pts;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/challenge.dart';
import '../models/reward_voucher.dart';
import '../models/athlete_plan.dart';
import '../models/health_tip.dart';
import '../utils/constants.dart';

class ChallengeProvider with ChangeNotifier {
  static const String _keyPoints = 'user_reward_points';
  static const String _keyRedeemedIds = 'user_redeemed_voucher_ids';
  static const String _keyAppliedPlanId = 'user_applied_plan_id';

  int _userPoints = 150;
  List<String> _redeemedVoucherIds = [];
  String? _appliedPlanId;

  int get userPoints => _userPoints;
  List<String> get redeemedVoucherIds => _redeemedVoucherIds;
  String? get appliedPlanId => _appliedPlanId;

  ChallengeProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    _userPoints = prefs.getInt(_keyPoints) ?? 150;
    _redeemedVoucherIds = prefs.getStringList(_keyRedeemedIds) ?? [];
    _appliedPlanId = prefs.getString(_keyAppliedPlanId);
    notifyListeners();
  }

  Future<void> addDailyLoginPoints(int points) async {
    _userPoints += points;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, _userPoints);
    notifyListeners();
  }

  Future<bool> redeemVoucher(String voucherId, int cost) async {
    if (_userPoints < cost) return false;
    _userPoints -= cost;
    if (!_redeemedVoucherIds.contains(voucherId)) {
      _redeemedVoucherIds.add(voucherId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPoints, _userPoints);
    await prefs.setStringList(_keyRedeemedIds, _redeemedVoucherIds);
    notifyListeners();
    return true;
  }

  Future<void> applyAthletePlan(String planId) async {
    _appliedPlanId = planId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppliedPlanId, planId);
    notifyListeners();
  }

  // Danh sách thử thách
  List<Challenge> get challenges => [
    const Challenge(
      id: 'c1',
      title: 'Uống đủ 2.000 ml nước',
      description: 'Duy trì đủ lượng nước mỗi ngày để thanh lọc cơ thể và tăng năng lượng.',
      targetValue: 2000,
      currentProgress: 1450,
      unit: 'ml',
      rewardPoints: 30,
      badgeIcon: Icons.water_drop_rounded,
      badgeColor: AppColors.appleBlue,
      category: 'Nước uống',
      isCompleted: false,
    ),
    const Challenge(
      id: 'c2',
      title: 'Ngủ đủ 8 tiếng chất lượng',
      description: 'Giúp cơ bắp phục hồi và tái tạo năng lượng tối ưu cho ngày mới.',
      targetValue: 8,
      currentProgress: 8,
      unit: 'giờ',
      rewardPoints: 50,
      badgeIcon: Icons.bedtime_rounded,
      badgeColor: AppColors.applePurple,
      category: 'Giấc ngủ',
      isCompleted: true,
      isClaimed: false,
    ),
    const Challenge(
      id: 'c3',
      title: 'Vận động thể thao 30 phút',
      description: 'Đốt cháy calo và tăng cường sức bền hệ tim mạch.',
      targetValue: 30,
      currentProgress: 45,
      unit: 'phút',
      rewardPoints: 60,
      badgeIcon: Icons.local_fire_department_rounded,
      badgeColor: AppColors.appleRed,
      category: 'Vận động',
      isCompleted: true,
      isClaimed: true,
    ),
    const Challenge(
      id: 'c4',
      title: 'Đi bộ 10.000 bước chân',
      description: 'Tạo thói quen năng động mỗi ngày cùng cộng đồng Health Tracker.',
      targetValue: 10000,
      currentProgress: 7200,
      unit: 'bước',
      rewardPoints: 40,
      badgeIcon: Icons.directions_walk_rounded,
      badgeColor: AppColors.appleGreen,
      category: 'Vận động',
      isCompleted: false,
    ),
  ];

  // Danh sách voucher đổi thưởng
  List<RewardVoucher> get vouchers => [
    const RewardVoucher(
      id: 'v1',
      title: 'Giảm 30% Gói Tập Gym 3 Tháng',
      brandName: 'California Fitness & Yoga',
      brandCategory: 'Phòng Gym',
      discount: '30%',
      pointsCost: 100,
      expiryDate: '30/09/2026',
      code: 'CALI30HEALTH',
      description: 'Áp dụng cho tất cả các phòng tập thuộc hệ thống California Fitness toàn quốc.',
      iconEmoji: '🏋️',
      themeColor: AppColors.appleRed,
    ),
    const RewardVoucher(
      id: 'v2',
      title: 'Giảm 50.000đ Combo Salad Healthy',
      brandName: 'SaladStop! Vietnam',
      brandCategory: 'Ăn uống Healthy',
      discount: '50K',
      pointsCost: 50,
      expiryDate: '15/09/2026',
      code: 'SALADHEALTH50',
      description: 'Giảm trực tiếp 50.000đ cho đơn hàng từ 120.000đ tại cửa hàng hoặc đặt online.',
      iconEmoji: '🥗',
      themeColor: AppColors.appleGreen,
    ),
    const RewardVoucher(
      id: 'v3',
      title: 'Tặng 1 Buổi Trải Nghiệm Yoga Chuyên Sâu',
      brandName: 'Elite Fitness & Spa',
      brandCategory: 'Phòng Gym',
      discount: 'MIỄN PHÍ',
      pointsCost: 120,
      expiryDate: '31/10/2026',
      code: 'ELITEYOGA100',
      description: 'Miễn phí 1 buổi tập Yoga với HLV quốc tế và sử dụng hồ bơi 4 mùa.',
      iconEmoji: '🧘',
      themeColor: AppColors.applePurple,
    ),
    const RewardVoucher(
      id: 'v4',
      title: 'Giảm 25% Hộp Thực Phẩm Dinh Dưỡng Eat Clean',
      brandName: 'Fitfood Vietnam',
      brandCategory: 'Ăn uống Healthy',
      discount: '25%',
      pointsCost: 80,
      expiryDate: '25/09/2026',
      code: 'FITFOOD25CLEAN',
      description: 'Giao hàng tận nơi các gói ăn dinh dưỡng cân bằng Macro chuẩn chuyên gia.',
      iconEmoji: '🍱',
      themeColor: AppColors.appleOrange,
    ),
  ];

  // Danh sách KOLs / Vận động viên
  List<AthletePlan> get athletePlans => [
    const AthletePlan(
      id: 'p1',
      name: 'Nguyễn Thị Oanh',
      role: 'Kỷ lục gia Điền kinh SEA Games',
      avatarEmoji: '🏃‍♀️',
      proTip: 'Uống nước theo từng ngụm nhỏ và ngủ đủ 8.5 tiếng là bí quyết phục hồi tốt nhất.',
      dailyWaterMl: 2800,
      dailySleepHours: 8.5,
      dailyActivityMinutes: 90,
      workoutRoutine: [
        'Khởi động kỹ khớp 15 phút',
        'Chạy biến tốc (Interval) 45 phút',
        'Bài tập giãn cơ & phục hồi 30 phút',
      ],
      mealPlan: [
        'Sáng: Yến mạch, chuối, 2 quả trứng luộc',
        'Trưa: Ức gà nướng, gạo lứt, bông cải xanh',
        'Tối: Cá hồi áp chảo, khoai lang hấp, salad',
      ],
      sleepTips: [
        'Không dùng điện thoại trước khi ngủ 45 phút',
        'Phòng ngủ giữ nhiệt độ mát 20-22°C',
      ],
      themeColor: AppColors.appleRed,
    ),
    const AthletePlan(
      id: 'p2',
      name: 'Hana Giang Anh',
      role: 'Fitness Influencer & HLV Yoga',
      avatarEmoji: '🧘‍♀️',
      proTip: 'Hãy lắng nghe cơ thể. 30 phút vận động mỗi ngày mang lại sự thay đổi diệu kỳ.',
      dailyWaterMl: 2400,
      dailySleepHours: 8.0,
      dailyActivityMinutes: 45,
      workoutRoutine: [
        'Bài tập HIIT toàn thân đốt mỡ 25 phút',
        'Yoga kéo giãn & giải tỏa căng thẳng 20 phút',
      ],
      mealPlan: [
        'Sáng: Sinh tố bơ chuối sữa hạt',
        'Trưa: Bún lứt xào thịt bò, rau củ',
        'Tối: Đậu hũ sốt cà chua, canh rau ngót',
      ],
      sleepTips: [
        'Uống 1 tách trà hoa cúc ấm trước giờ ngủ',
        'Tập thở sâu 4-7-8 giúp ngủ sâu',
      ],
      themeColor: AppColors.appleGreen,
    ),
    const AthletePlan(
      id: 'p3',
      name: 'Trần Quyết Chiến',
      role: 'Nhà vô địch Thế giới Billiards',
      avatarEmoji: '🎱',
      proTip: 'Tâm trí vững vàng đến từ một giấc ngủ sâu và bổ sung nước đều đặn.',
      dailyWaterMl: 2200,
      dailySleepHours: 7.5,
      dailyActivityMinutes: 30,
      workoutRoutine: [
        'Đi bộ nhanh ngoài trời 30 phút',
        'Bài tập tăng cường sự tập trung và thăng bằng',
      ],
      mealPlan: [
        'Sáng: Bánh mì nguyên cám, bơ hạt dẻ',
        'Trưa: Cơm gạo lứt, cá thu sốt tiêu',
        'Tối: Canh rong biển thịt bằm, trái cây tươi',
      ],
      sleepTips: [
        'Nghe nhạc không lời tần số 432Hz trước khi ngủ',
        'Duy trì khung giờ ngủ cố định 23:00 mỗi đêm',
      ],
      themeColor: AppColors.appleBlue,
    ),
  ];

  // Danh sách mẹo sức khỏe
  List<HealthTip> get healthTips => [
    const HealthTip(
      id: 't1',
      title: 'Quy tắc 8 ly nước mỗi ngày cho sức khỏe dẻo dai',
      summary: 'Thời điểm vàng để uống nước giúp trao đổi chất hiệu quả nhất trong ngày.',
      content: '1. Ngay khi thức dậy: 1 ly nước ấm để đánh thức hệ tiêu hóa.\n2. Trước bữa ăn 30 phút: Hỗ trợ tiêu hóa thức ăn tốt hơn.\n3. Trước khi tắm: Giúp ổn định huyết áp.\n4. Trước khi đi ngủ: Bổ sung nước và phòng ngừa chuột rút.',
      category: 'Dinh dưỡng',
      author: 'BS. Nguyễn Văn Hùng',
      iconEmoji: '💧',
      readTimeMinutes: '3 phút',
    ),
    const HealthTip(
      id: 't2',
      title: 'Tối ưu hóa chu kỳ giấc ngủ 90 phút',
      summary: 'Bí quyết thức dậy tỉnh táo, không mệt mỏi theo nguyên lý khoa học.',
      content: 'Một chu kỳ ngủ trọn vẹn gồm 5 giai đoạn kéo dài khoảng 90 phút. Hãy đặt báo thức vào thời điểm kết thúc một chu kỳ (ví dụ: 6 tiếng = 4 chu kỳ, 7.5 tiếng = 5 chu kỳ) để cơ thể luôn thức dậy ở trạng thái sảng khoái nhất.',
      category: 'Giấc ngủ',
      author: 'Chuyên gia Giấc ngủ SleepLab',
      iconEmoji: '🌙',
      readTimeMinutes: '4 phút',
    ),
    const HealthTip(
      id: 't3',
      title: '30 phút đi bộ mỗi ngày thay đổi cơ thể như thế nào?',
      summary: 'Những lợi ích kỳ diệu của việc duy trì đi bộ đều đặn.',
      content: 'Đi bộ nhanh 30 phút mỗi ngày giúp:\n- Giảm 30% nguy cơ mắc bệnh tim mạch.\n- Cải thiện tâm trạng và giải tỏa hormone cortisol gây stress.\n- Tăng cường mật độ xương và săn chắc cơ chân.',
      category: 'Vận động',
      author: 'HLV Thể hình Tuấn Anh',
      iconEmoji: '👟',
      readTimeMinutes: '3 phút',
    ),
  ];
}

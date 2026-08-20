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

  // Danh sách KOLs / Vận động viên nổi tiếng theo từng bộ môn thể thao
  List<AthletePlan> get athletePlans => [
    // === 1. BÓNG ĐÁ (FOOTBALL) ===
    const AthletePlan(
      id: 'p_cr7',
      name: 'Cristiano Ronaldo (CR7)',
      role: 'Siêu sao Huyền thoại • The GOAT (Kỷ lục gia vĩ đại nhất)',
      category: 'Bóng đá',
      avatarEmoji: '🐐',
      proTip: 'Kỷ luật và kiên trì là chìa khóa. Tôi không bao giờ uống nước ngọt, luôn ngủ đủ giấc và tập luyện mỗi ngày.',
      dailyWaterMl: 3200,
      dailySleepHours: 8.5,
      dailyActivityMinutes: 120,
      workoutRoutine: [
        'Khởi động cardio & giãn cơ động 20 phút',
        'Bài tập bứt tốc độ cao & kỹ thuật sút bóng 40 phút',
        'Tập tạ toàn thân (Squat, Deadlift, Core) 40 phút',
        'Bơi lội thả lỏng & ngâm bồn nước đá hồi phục 20 phút',
      ],
      mealPlan: [
        'Sáng: Trứng ốp la, phô mai nạc, bánh mì nguyên cám, nước cam tươi',
        'Trưa: Cá tuyết nướng / Ức gà nạc, salad cà chua & quả bơ',
        'Xế chiều: Trái cây tươi (táo, lê), hạt hạnh nhân & sữa chua Hy Lạp',
        'Tối: Bít tết cá kiếm nướng, khoai lang hấp & măng tây',
      ],
      sleepTips: [
        'Chia giấc ngủ thành 5 chu kỳ 90 phút (ngủ đa pha)',
        'Tắt hoàn toàn màn hình điện tử trước giờ ngủ 90 phút',
        'Nhiệt độ phòng ngủ luôn duy trì ở mức 19-20°C',
      ],
      themeColor: Color(0xFFE50914), // Red
    ),

    const AthletePlan(
      id: 'p_mbappe',
      name: 'Kylian Mbappé (M3p)',
      role: 'Siêu sao Bóng đá • Tốc Độ & Bùng Nổ',
      category: 'Bóng đá',
      avatarEmoji: '⚡',
      proTip: 'Tốc độ trên sân cỏ bắt nguồn từ bữa ăn sạch, giấc ngủ sâu và các bài tập bứt tốc bùng nổ.',
      dailyWaterMl: 3000,
      dailySleepHours: 8.0,
      dailyActivityMinutes: 90,
      workoutRoutine: [
        'Khởi động khớp & chạy tăng tốc dần 15 phút',
        'Bài tập tăng tốc cự ly ngắn 10m - 30m 35 phút',
        'Tập sức mạnh chân (Leg Press, Box Jump, Plyometrics) 25 phút',
        'Kéo giãn tĩnh & xoa bóp cơ bắp 15 phút',
      ],
      mealPlan: [
        'Sáng: Bát yến mạch sữa hạt, quả mọng việt quất, trứng luộc',
        'Trưa: Mì Ý nguyên cám sốt cá hồi áp chảo, rau củ hấp',
        'Xế chiều: Sinh tố chuối bơ đậu phộng & hạt chia',
        'Tối: Thịt bò nạc xào bông cải xanh, canh rong biển',
      ],
      sleepTips: [
        'Ngâm chân nước ấm trước khi đi ngủ 30 phút',
        'Đeo kính chống ánh sáng xanh vào buổi tối',
      ],
      themeColor: Color(0xFF0055FF), // Blue
    ),

    const AthletePlan(
      id: 'p_messi',
      name: 'Lionel Messi',
      role: 'Nhạc trưởng Argentina • Nghệ sĩ Sân cỏ',
      category: 'Bóng đá',
      avatarEmoji: '🪄',
      proTip: 'Hãy lắng nghe cơ thể. Dinh dưỡng lành mạnh từ thực vật và nước lọc giúp tôi thi đấu đỉnh cao suốt 20 năm.',
      dailyWaterMl: 2800,
      dailySleepHours: 8.0,
      dailyActivityMinutes: 75,
      workoutRoutine: [
        'Kích hoạt cơ bắp & bài tập thăng bằng 20 phút',
        'Rê dắt bóng tốc độ cao qua chướng ngại vật 30 phút',
        'Bài tập core và linh hoạt cột sống 15 phút',
        'Xông hơi & phục hồi cơ bắp 10 phút',
      ],
      mealPlan: [
        'Sáng: Ngũ cốc nguyên hạt, quả hạch, trái cây tươi',
        'Trưa: Thịt gà hữu cơ, gạo lứt, salad ô-liu dầu dừa',
        'Xế chiều: Trà thảo mộc Maté truyền thống',
        'Tối: Cá hấp xì dầu, súp rau củ thanh đạm',
      ],
      sleepTips: [
        'Nghe nhạc êm dịu không lời trước khi vào giấc',
        'Uống một cốc nước lọc ấm nhỏ trước khi lên giường',
      ],
      themeColor: Color(0xFF00A896), // Teal
    ),

    // === 2. BOXING / QUYỀN ANH ===
    const AthletePlan(
      id: 'p_tyson',
      name: 'Mike Tyson',
      role: 'Huyền thoại Quyền Anh Hạng Nặng • Cú Đấm Thép',
      category: 'Boxing',
      avatarEmoji: '🥊',
      proTip: 'Không có gì thay thế được sự chăm chỉ. 4 giờ sáng thức dậy chạy bộ khi cả thế giới đang ngủ là lúc tạo nên nhà vô địch.',
      dailyWaterMl: 3500,
      dailySleepHours: 8.0,
      dailyActivityMinutes: 120,
      workoutRoutine: [
        'Chạy bộ sáng sớm 45 phút',
        'Đánh bao cát nặng & đòn tổ hợp 35 phút',
        'Gập bụng 500 cái, chống đẩy & xà đơn 25 phút',
        'Nhảy dây tốc độ cao 15 phút',
      ],
      mealPlan: [
        'Sáng: 6 quả trứng gà, yến mạch nguyên cám, 2 quả chuối',
        'Trưa: Bít tết thịt bò nạc 300g, cơm gạo lứt, rau bina',
        'Xế: Sinh tố Protein whey, hạt óc chó, táo xanh',
        'Tối: Ức gà nướng, khoai tây nghiền, súp củ quả',
      ],
      sleepTips: [
        'Duy trì phòng ngủ tối hoàn toàn để tối đa hóa hormone tăng trưởng',
        'Cố định giờ ngủ lúc 21:30 mỗi tối',
      ],
      themeColor: Color(0xFFFF5722), // Deep Orange
    ),

    const AthletePlan(
      id: 'p_canelo',
      name: 'Canelo Álvarez',
      role: 'Nhà vô địch Boxing Thế giới • Sức Mạnh Toàn Diện',
      category: 'Boxing',
      avatarEmoji: '🏆',
      proTip: 'Mỗi cú đấm xuất phát từ sức mạnh của đôi chân và sự tập trung tuyệt đối của tâm trí.',
      dailyWaterMl: 3200,
      dailySleepHours: 8.5,
      dailyActivityMinutes: 90,
      workoutRoutine: [
        'Nhảy dây & khởi động găng tay 20 phút',
        'Sparring tập chiến thuật & né đòn 40 phút',
        'Bài tập sức mạnh Medicine Ball & Cáp kéo 20 phút',
        'Thả lỏng ngâm bồn lạnh Cryotherapy 10 phút',
      ],
      mealPlan: [
        'Sáng: Trứng chiên nấm, bánh mì nướng bơ, nước ép lựu',
        'Trưa: Cá ngừ sốt tiêu xanh, khoai lang nướng, salad dưa chuột',
        'Tối: Thịt bò nạc băm xào ớt chuông, quinoa',
      ],
      sleepTips: [
        'Tập thở sâu giảm căng thẳng thần kinh trước khi ngủ',
        'Dành 15 phút giãn cơ cổ và lưng trước khi nằm',
      ],
      themeColor: Color(0xFFC2185B), // Maroon / Pink
    ),

    const AthletePlan(
      id: 'p_mayweather',
      name: 'Floyd Mayweather',
      role: 'Tay đấm Bất bại 50-0 • Bậc thầy Phòng ngự',
      category: 'Boxing',
      avatarEmoji: '💰',
      proTip: 'Làm việc chăm chỉ và cống hiến hết mình. Khi bạn muốn thành công nhiều như bạn muốn thở, bạn sẽ bất bại.',
      dailyWaterMl: 3000,
      dailySleepHours: 9.0,
      dailyActivityMinutes: 100,
      workoutRoutine: [
        'Chạy bộ đêm duy trì sức bền tim mạch 40 phút',
        'Tập đòn găng (Mitt work) cực nhanh 30 phút',
        'Tập bụng & bài tập bodyweight 20 phút',
        'Kéo giãn khớp toàn thân 10 phút',
      ],
      mealPlan: [
        'Sáng: Bánh kếp yến mạch chuối, trứng ốp la, trà thảo dược',
        'Trưa: Tôm nướng tỏi ô-liu, cơm gạo hoa hồi, bông cải xanh',
        'Tối: Cá hồi nướng chanh, salad rau mầm sốt giấm táo',
      ],
      sleepTips: [
        'Ngủ sâu 9 tiếng mỗi ngày để các mô cơ hồi phục tối đa',
        'Tránh uống caffeine sau 15:00',
      ],
      themeColor: Color(0xFFFFB300), // Gold
    ),

    // === 3. BÓNG RỔ (BASKETBALL) ===
    const AthletePlan(
      id: 'p_lebron',
      name: 'LeBron James',
      role: 'Huyền thoại NBA • Cỗ Máy Thể Lực 40 Tuổi',
      category: 'Bóng rổ',
      avatarEmoji: '👑',
      proTip: 'Tôi đầu tư 1.5 triệu USD mỗi năm vào cơ thể mình. Giấc ngủ 9-10 tiếng là công cụ phục hồi tốt nhất thế giới.',
      dailyWaterMl: 3800,
      dailySleepHours: 9.5,
      dailyActivityMinutes: 90,
      workoutRoutine: [
        'Kích hoạt cơ bắp & yoga thăng bằng 20 phút',
        'Tập tạ liên hoàn (Superset) tăng lực bật nhảy 35 phút',
        'Tập ném rổ & di chuyển chiến thuật 25 phút',
        'Ngâm bồn nước đá & phòng oxy áp suất cao 10 phút',
      ],
      mealPlan: [
        'Sáng: Bánh mì nướng bơ trứng, quả việt quất, sinh tố xanh',
        'Trưa: Cá hồi hoang dã nướng, khoai lang tím, salad xà lách romaine',
        'Xế: Sinh tố Protein Collagen quả mọng',
        'Tối: Ức gà hữu cơ, mì bí ngòi sốt ô-liu, măng tây nướng',
      ],
      sleepTips: [
        'Ngủ trong phòng tối 100% không có đèn LED',
        'Duy trì giấc ngủ trưa 45 phút mỗi ngày',
      ],
      themeColor: Color(0xFF7B1FA2), // Purple
    ),

    const AthletePlan(
      id: 'p_curry',
      name: 'Stephen Curry',
      role: 'Vua Ném 3 Điểm NBA • Phản Xạ Thần Tốc',
      category: 'Bóng rổ',
      avatarEmoji: '🎯',
      proTip: 'Sự chính xác đến từ sự lặp lại hàng nghìn lần trong trạng thái tinh thần thư thái và thể lực dẻo dai.',
      dailyWaterMl: 3000,
      dailySleepHours: 8.0,
      dailyActivityMinutes: 80,
      workoutRoutine: [
        'Tập phản xạ mắt và xúc giác với bóng đèn nhấp nháy 20 phút',
        'Ném 500 quả bóng rổ ở các cự ly khác nhau 35 phút',
        'Bài tập bứt tốc đổi hướng Agility Ladder 15 phút',
        'Giãn cơ tĩnh & thả lỏng cơ khớp 10 phút',
      ],
      mealPlan: [
        'Sáng: Cháo yến mạch hạt chia, chuối, mật ong nguyên chất',
        'Trưa: Cá basa áp chảo, cơm gạo lứt, canh rau bina',
        'Tối: Bò cuộn măng tây nướng, salad dầu giấm',
      ],
      sleepTips: [
        'Đọc sách 20 phút trước khi ngủ giúp thư giãn não bộ',
        'Dùng máy tạo độ ẩm không khí trong phòng ngủ',
      ],
      themeColor: Color(0xFF1976D2), // Blue
    ),

    // === 4. ĐIỀN KINH & CHẠY BỘ ===
    const AthletePlan(
      id: 'p_bolt',
      name: 'Usain Bolt',
      role: 'Kỷ lục gia 100m • Người Nhanh Nhất Hành Tinh',
      category: 'Điền kinh',
      avatarEmoji: '⚡',
      proTip: 'Tôi đã tập luyện suốt 4 năm chỉ để chạy 9 giây. Đừng bỏ cuộc chỉ vì kết quả chưa đến sau vài ngày.',
      dailyWaterMl: 3200,
      dailySleepHours: 8.5,
      dailyActivityMinutes: 90,
      workoutRoutine: [
        'Khởi động bước chạy kỹ thuật & dây kháng lực 20 phút',
        'Chạy bứt tốc cự ly 60m - 150m tối đa công suất 40 phút',
        'Tập sức mạnh chân (Squat nặng, Glute bridge) 20 phút',
        'Thả lỏng cơ bắp trên máy chạy 10 phút',
      ],
      mealPlan: [
        'Sáng: Bánh mì nướng mứt chuối ngự, 3 quả trứng luộc',
        'Trưa: Cơm gạo lứt, cá ngừ xào rau củ, khoai lang nghiền',
        'Tối: Thịt bò nướng, mì Ý nguyên cám, canh rau củ',
      ],
      sleepTips: [
        'Ngủ đủ 8.5 tiếng mỗi đêm để hệ thần kinh trung ương hồi phục',
        'Thư giãn cơ bắp với con lăn massage Foam Roller',
      ],
      themeColor: Color(0xFF388E3C), // Green
    ),

    const AthletePlan(
      id: 'p_kipchoge',
      name: 'Eliud Kipchoge',
      role: 'Kỷ lục gia Marathon Dưới 2 Giờ (1:59:40)',
      category: 'Điền kinh',
      avatarEmoji: '🏃‍♂️',
      proTip: 'Chỉ những người có kỷ luật mới thực sự tự do. Không có giới hạn nào cho con người nếu ta kiên trì.',
      dailyWaterMl: 3400,
      dailySleepHours: 9.0,
      dailyActivityMinutes: 120,
      workoutRoutine: [
        'Chạy đường dài nhẹ nhàng buổi sáng 60 phút',
        'Tập bổ trợ cơ lõi (Core & Balance) 30 phút',
        'Chạy biến tốc cự ly dài 30 phút',
      ],
      mealPlan: [
        'Sáng: Bột ngô Ugali truyền thống Kenya, sữa tươi hữu cơ',
        'Trưa: Đậu tây hầm cà chua, cơm gạo lứt, rau chân vịt',
        'Tối: Trứng bác, khoai lang luộc, trà gừng ấm',
      ],
      sleepTips: [
        'Ngủ sớm từ 20:30 mỗi đêm và thức dậy lúc 5:00',
        'Thiền định 10 phút trước khi vào giấc ngủ',
      ],
      themeColor: Color(0xFF00796B), // Teal
    ),

    const AthletePlan(
      id: 'p_oanh',
      name: 'Nguyễn Thị Oanh',
      role: 'Kỷ lục gia Điền kinh SEA Games (4 HCV)',
      category: 'Điền kinh',
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

    // === 5. GYM & THỂ HÌNH (BODYBUILDING) ===
    const AthletePlan(
      id: 'p_arnold',
      name: 'Arnold Schwarzenegger',
      role: 'Tượng đài Thể hình 7 Lần Mr. Olympia',
      category: 'Thể hình',
      avatarEmoji: '🦾',
      proTip: 'Bộ não là nơi tạo ra cơ bắp. Bạn phải hình dung cơ bắp phát triển trong từng hiệp tập.',
      dailyWaterMl: 3600,
      dailySleepHours: 8.0,
      dailyActivityMinutes: 90,
      workoutRoutine: [
        'Khởi động khớp vai & ngực 15 phút',
        'Tập ngực & lưng (Bench Press, Barbell Row) 45 phút',
        'Tập tay & bụng (Bicep Curl, Tricep Dip) 20 phút',
        'Kéo giãn cơ bắp 10 phút',
      ],
      mealPlan: [
        'Sáng: 4 quả trứng, 100g bột yến mạch, 1 ly sữa tươi',
        'Trưa: Bít tết bò nạc 250g, cơm gạo lứt, rau trộn dầu ô-liu',
        'Xế: Sinh tố Protein Whey, hạt hạnh nhân',
        'Tối: Ức gà nướng thảo mộc, khoai tây hấp, bông cải',
      ],
      sleepTips: [
        'Ngủ đủ 8 tiếng sâu để cơ bắp tổng hợp Protein tối ưu',
        'Tắm nước ấm thư giãn cơ bắp trước khi ngủ',
      ],
      themeColor: Color(0xFFE65100), // Orange
    ),

    const AthletePlan(
      id: 'p_cbum',
      name: 'Chris Bumstead (CBum)',
      role: 'Nhà vô địch Classic Physique Mr. Olympia 5 Lần',
      category: 'Thể hình',
      avatarEmoji: '🏋️‍♂️',
      proTip: 'Sự kiên định qua từng năm tháng quan trọng hơn sự bùng nổ nhất thời. Đừng bỏ lỡ bất kỳ bữa ăn sạch nào.',
      dailyWaterMl: 3800,
      dailySleepHours: 8.5,
      dailyActivityMinutes: 80,
      workoutRoutine: [
        'Kích hoạt khớp & làm nóng cơ bắp 15 phút',
        'Tập cơ bắp theo giáo án Push/Pull/Legs 50 phút',
        'Cardio đi bộ dốc máy Incline Treadmill 15 phút',
      ],
      mealPlan: [
        'Sáng: Bột yến mạch, quả việt quất, bột Whey cô lập, lòng trắng trứng',
        'Trưa: Gà nướng cà ri, cơm hoa nhài, bí ngòi nướng',
        'Xế: Thịt bò nạc, khoai lang nướng',
        'Tối: Cá hồi nướng măng tây, bơ đậu phộng',
      ],
      sleepTips: [
        'Bổ sung Magie hữu cơ giúp giãn cơ sâu',
        'Giữ phòng ngủ hoàn toàn yên tĩnh và thông thoáng',
      ],
      themeColor: Color(0xFF0288D1), // Light Blue
    ),

    // === 6. BƠI LỘI (SWIMMING) ===
    const AthletePlan(
      id: 'p_phelps',
      name: 'Michael Phelps',
      role: 'Kỷ lục gia 28 Huy Chương Olympic (23 HCV)',
      category: 'Bơi lội',
      avatarEmoji: '🏊‍♂️',
      proTip: 'Nếu bạn muốn đạt được điều chưa từng có, bạn phải làm những điều bạn chưa từng làm.',
      dailyWaterMl: 4000,
      dailySleepHours: 8.5,
      dailyActivityMinutes: 120,
      workoutRoutine: [
        'Khởi động khớp vai & bơi khởi động nhẹ 20 phút',
        'Bài tập bơi sải & bơi bướm cường độ cao 60 phút',
        'Tập tạ bổ trợ sức kéo xô & tay sau 30 phút',
        'Thả lỏng cơ thể dưới nước 10 phút',
      ],
      mealPlan: [
        'Sáng: 3 bánh mì kẹp trứng phô mai, ngũ cốc, nước cam ép',
        'Trưa: Mì Ý sốt bò bằm nguyên cám, 2 bánh sandwich giăm bông',
        'Tối: Pizza nguyên cám nướng, thịt gà nướng, salad hoa quả',
      ],
      sleepTips: [
        'Ngủ trong buồng ngủ mô phỏng độ cao tăng hồng cầu',
        'Ngủ trưa 60 phút giữa hai buổi tập dưới nước',
      ],
      themeColor: Color(0xFF0277BD), // Deep Ocean Blue
    ),

    // === 7. YOGA & THỂ THAO ĐẠI CHÚNG ===
    const AthletePlan(
      id: 'p_hana',
      name: 'Hana Giang Anh',
      role: 'Fitness Influencer & HLV Yoga Hàng Đầu',
      category: 'Yoga',
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

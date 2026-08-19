import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/health_profile.dart';
import '../models/water_intake.dart';
import '../models/sleep_record.dart';
import '../models/weight_record.dart';
import '../models/activity_record.dart';
import '../models/user_goal.dart';
import '../models/meal_record.dart';
import '../database/database_helper.dart';

class HealthProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  int? _userId;

  HealthProfile? _healthProfile;
  List<WaterIntake> _todayWaterList = [];
  List<SleepRecord> _sleepList = [];
  List<WeightRecord> _weightList = [];
  List<ActivityRecord> _activityList = [];
  List<MealRecord> _todayMealList = [];
  UserGoal _goal = UserGoal(userId: 0, waterGoal: 2000, sleepGoal: 8.0, activityGoal: 30);

  // Weekly spots for charts
  List<FlSpot> _weeklyWaterSpots = [];
  List<FlSpot> _weeklySleepSpots = [];
  List<FlSpot> _weeklyActivitySpots = [];

  // Getters
  int? get userId => _userId;
  HealthProfile? get healthProfile => _healthProfile;
  List<WaterIntake> get todayWaterList => _todayWaterList;
  List<SleepRecord> get sleepList => _sleepList;
  List<WeightRecord> get weightList => _weightList;
  List<ActivityRecord> get activityList => _activityList;
  List<MealRecord> get todayMeals => _todayMealList;
  UserGoal get goal => _goal;

  List<FlSpot> get weeklyWaterSpots => _weeklyWaterSpots;
  List<FlSpot> get weeklySleepSpots => _weeklySleepSpots;
  List<FlSpot> get weeklyActivitySpots => _weeklyActivitySpots;

  int get todayWaterTotal => _todayWaterList.fold(0, (sum, item) => sum + item.amount);
  int get todayActivityMinutes => _activityList
      .where((a) => a.date == _todayStr())
      .fold(0, (sum, item) => sum + item.duration);
  double get todayCaloriesBurned => _activityList
      .where((a) => a.date == _todayStr())
      .fold(0.0, (sum, item) => sum + item.calories);
  int get todayCaloriesIn => _todayMealList.fold(0, (sum, item) => sum + item.calories);

  SleepRecord? get latestSleep => _sleepList.isNotEmpty ? _sleepList.first : null;
  WeightRecord? get latestWeight => _weightList.isNotEmpty ? _weightList.first : null;

  // Tính cân nặng hiện tại
  double get currentWeight =>
      latestWeight?.weight ?? _healthProfile?.currentWeight ?? 65.0;

  // Chiều cao (cm)
  double get currentHeight => _healthProfile?.height ?? 170.0;

  // Tính BMI tự động dựa trên chiều cao và cân nặng của user hiện tại
  double get bmi {
    final heightM = currentHeight / 100.0;
    if (heightM <= 0) return 22.0;
    return currentWeight / (heightM * heightM);
  }

  String get bmiClassification {
    final b = bmi;
    if (b < 18.5) return 'Thiếu cân (Gầy)';
    if (b < 24.9) return 'Bình thường (Lý tưởng)';
    if (b < 29.9) return 'Thừa cân';
    return 'Béo phì';
  }

  String _todayStr() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  // Khởi tạo theo User ID
  Future<void> init(int userId) async {
    _userId = userId;
    await refreshAll();
  }

  // Xóa toàn bộ dữ liệu bộ nhớ RAM khi Logout
  void clear() {
    _userId = null;
    _healthProfile = null;
    _todayWaterList = [];
    _sleepList = [];
    _weightList = [];
    _activityList = [];
    _todayMealList = [];
    _goal = UserGoal(userId: 0, waterGoal: 2000, sleepGoal: 8.0, activityGoal: 30);
    _weeklyWaterSpots = [];
    _weeklySleepSpots = [];
    _weeklyActivitySpots = [];
    notifyListeners();
  }

  Future<void> refreshAll() async {
    if (_userId == null) return;
    final today = _todayStr();

    // 1. Nạp hồ sơ sức khỏe
    _healthProfile = await _db.getHealthProfile(_userId!);
    if (_healthProfile == null) {
      final now = DateTime.now().toIso8601String();
      _healthProfile = HealthProfile(
        userId: _userId!,
        fullName: 'Người dùng',
        height: 170.0,
        currentWeight: 65.0,
        targetWeight: 60.0,
        createdAt: now,
        updatedAt: now,
      );
      await _db.upsertHealthProfile(_healthProfile!);
    }

    // 2. Nạp dữ liệu các phân hệ
    _todayWaterList = await _db.getWaterIntakesByDate(_userId!, today);
    _sleepList = await _db.getSleepRecords(_userId!);
    _weightList = await _db.getWeightRecords(_userId!);
    _activityList = await _db.getActivityRecords(_userId!);
    _todayMealList = await _db.getMealsByDate(_userId!, today);

    // 3. Nạp mục tiêu
    final goalFromDb = await _db.getUserGoal(_userId!);
    if (goalFromDb != null) {
      _goal = goalFromDb;
    } else {
      _goal = UserGoal(
        userId: _userId!,
        waterGoal: _healthProfile?.waterGoal ?? 2000,
        sleepGoal: _healthProfile?.sleepGoal ?? 8.0,
        activityGoal: 30,
      );
      await _db.saveUserGoal(_goal);
    }

    await _generateWeeklyCharts();
    notifyListeners();
  }

  Future<void> _generateWeeklyCharts() async {
    if (_userId == null) return;
    final now = DateTime.now();
    List<FlSpot> waterSpots = [];
    List<FlSpot> sleepSpots = [];
    List<FlSpot> actSpots = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final spotX = (6 - i).toDouble();

      final dayWater = await _db.getWaterIntakesByDate(_userId!, dateStr);
      final totalWater = dayWater.fold(0, (sum, w) => sum + w.amount);
      waterSpots.add(FlSpot(spotX, totalWater.toDouble()));

      final daySleep = _sleepList.where((s) => s.date == dateStr).toList();
      final totalSleep = daySleep.isNotEmpty ? daySleep.first.duration : 0.0;
      sleepSpots.add(FlSpot(spotX, totalSleep));

      final dayAct = _activityList.where((a) => a.date == dateStr).toList();
      final totalAct = dayAct.fold(0, (sum, a) => sum + a.duration);
      actSpots.add(FlSpot(spotX, totalAct.toDouble()));
    }

    _weeklyWaterSpots = waterSpots;
    _weeklySleepSpots = sleepSpots;
    _weeklyActivitySpots = actSpots;
  }

  // === Hồ sơ sức khỏe (Health Profile) ===
  Future<void> updateProfile(HealthProfile profile) async {
    if (_userId == null) return;
    _healthProfile = profile.copyWith(
      userId: _userId!,
      updatedAt: DateTime.now().toIso8601String(),
    );
    await _db.upsertHealthProfile(_healthProfile!);
    
    // Đồng bộ mục tiêu
    _goal = UserGoal(
      userId: _userId!,
      waterGoal: _healthProfile!.waterGoal,
      sleepGoal: _healthProfile!.sleepGoal,
      activityGoal: _goal.activityGoal,
    );
    await _db.saveUserGoal(_goal);

    notifyListeners();
  }

  // === Nước uống (Water) ===
  Future<void> addWater(int amount) async {
    if (_userId == null) return;
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    final water = WaterIntake(
      userId: _userId!,
      amount: amount,
      time: timeStr,
      date: dateStr,
    );

    await _db.insertWaterIntake(water);
    await refreshAll();
  }

  Future<void> deleteWater(int id) async {
    await _db.deleteWaterIntake(id);
    await refreshAll();
  }

  // === Giấc ngủ (Sleep) ===
  Future<void> addSleep({
    required String sleepTime,
    required String wakeTime,
    required double duration,
    required String quality,
  }) async {
    if (_userId == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final sleep = SleepRecord(
      userId: _userId!,
      sleepTime: sleepTime,
      wakeTime: wakeTime,
      duration: duration,
      quality: quality,
      date: dateStr,
    );

    await _db.insertSleepRecord(sleep);
    await refreshAll();
  }

  // === Cân nặng & BMI (Weight) ===
  Future<void> addWeight(double weight, double heightCm) async {
    if (_userId == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final heightM = heightCm / 100.0;
    final bmiVal = weight / (heightM * heightM);

    final w = WeightRecord(
      userId: _userId!,
      weight: weight,
      bmi: bmiVal,
      date: dateStr,
    );

    await _db.insertWeightRecord(w);
    
    if (_healthProfile != null) {
      _healthProfile = _healthProfile!.copyWith(
        currentWeight: weight,
        height: heightCm,
        updatedAt: DateTime.now().toIso8601String(),
      );
    }
    
    await refreshAll();
  }

  // === Vận động (Activity) ===
  Future<void> addActivity({
    required String type,
    required int duration,
    required double calories,
  }) async {
    if (_userId == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final act = ActivityRecord(
      userId: _userId!,
      type: type,
      duration: duration,
      calories: calories,
      date: dateStr,
    );

    await _db.insertActivityRecord(act);
    await refreshAll();
  }

  Future<void> deleteActivity(int id) async {
    await _db.deleteActivityRecord(id);
    await refreshAll();
  }

  // === Bữa ăn (Meal) ===
  Future<void> addMeal({
    required String name,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    required String mealType,
    required String photoEmoji,
  }) async {
    if (_userId == null) return;
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(now);
    final dateStr = DateFormat('yyyy-MM-dd').format(now);

    final meal = MealRecord(
      userId: _userId!,
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      mealType: mealType,
      photoEmoji: photoEmoji,
      time: timeStr,
      date: dateStr,
    );

    await _db.insertMealRecord(meal);
    await refreshAll();
  }

  Future<void> deleteMeal(int id) async {
    await _db.deleteMealRecord(id);
    await refreshAll();
  }

  // === Mục tiêu (Goals) ===
  Future<void> updateGoals({int? water, double? sleep, int? activity}) async {
    if (_userId == null) return;
    _goal = UserGoal(
      id: _goal.id,
      userId: _userId!,
      waterGoal: water ?? _goal.waterGoal,
      sleepGoal: sleep ?? _goal.sleepGoal,
      activityGoal: activity ?? _goal.activityGoal,
    );
    await _db.saveUserGoal(_goal);

    if (_healthProfile != null) {
      _healthProfile = _healthProfile!.copyWith(
        waterGoal: water ?? _healthProfile!.waterGoal,
        sleepGoal: sleep ?? _healthProfile!.sleepGoal,
      );
      await _db.upsertHealthProfile(_healthProfile!);
    }

    notifyListeners();
  }
}

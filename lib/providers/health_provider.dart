import '../models/meal_record.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/water_intake.dart';
import '../models/sleep_record.dart';
import '../models/weight_record.dart';
import '../models/activity_record.dart';
import '../models/user_goal.dart';
import '../utils/bmi_calculator.dart';

class HealthProvider with ChangeNotifier {
  int? _userId;

  // Meal / Nutrition Data
  List<MealRecord> _todayMeals = [];
  int _todayCaloriesIn = 0;
  double _todayProtein = 0;
  double _todayCarbs = 0;
  double _todayFat = 0;
  // Water Data
  List<WaterIntake> _todayWaterList = [];
  int _todayWaterTotal = 0;

  // Sleep Data
  List<SleepRecord> _sleepList = [];

  // Weight Data
  WeightRecord? _latestWeight;
  List<WeightRecord> _weightHistory = [];

  // Activity Data
  List<ActivityRecord> _todayActivities = [];
  int _todayActivityMinutes = 0;

  // Goal Data
  UserGoal _goal = UserGoal(userId: 0);

  bool _isLoading = false;

  // Getters
  List<MealRecord> get todayMeals => _todayMeals;
  int get todayCaloriesIn => _todayCaloriesIn;
  double get todayProtein => _todayProtein;
  double get todayCarbs => _todayCarbs;
  double get todayFat => _todayFat;
  List<WaterIntake> get todayWaterList => _todayWaterList;
  int get todayWaterTotal => _todayWaterTotal;

  List<SleepRecord> get sleepList => _sleepList;
  SleepRecord? get latestSleep => _sleepList.isNotEmpty ? _sleepList.first : null;

  WeightRecord? get latestWeight => _latestWeight;
  List<WeightRecord> get weightHistory => _weightHistory;

  List<ActivityRecord> get todayActivities => _todayActivities;
  int get todayActivityMinutes => _todayActivityMinutes;

  UserGoal get goal => _goal;
  bool get isLoading => _isLoading;

  String get _todayStr => DateFormat('yyyy-MM-dd').format(DateTime.now());

  void init(int userId) {
    _userId = userId;
    loadAllData();
  }

  Future<void> loadAllData() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    final userId = _userId!;

    // 0. Meals
    _todayMeals = await DatabaseHelper.instance.getMealsByDate(userId, _todayStr);
    _todayCaloriesIn = await DatabaseHelper.instance.getTotalCaloriesByDate(userId, _todayStr);
    _todayProtein = _todayMeals.fold(0.0, (sum, m) => sum + m.protein);
    _todayCarbs = _todayMeals.fold(0.0, (sum, m) => sum + m.carbs);
    _todayFat = _todayMeals.fold(0.0, (sum, m) => sum + m.fat);
    // 1. Water
    _todayWaterList = await DatabaseHelper.instance.getWaterByDate(userId, _todayStr);
    _todayWaterTotal = await DatabaseHelper.instance.getTotalWaterByDate(userId, _todayStr);

    // 2. Sleep
    _sleepList = await DatabaseHelper.instance.getAllSleepRecords(userId);

    // 3. Weight
    _latestWeight = await DatabaseHelper.instance.getLatestWeight(userId);
    _weightHistory = await DatabaseHelper.instance.getAllWeightRecords(userId);

    // 4. Activity
    _todayActivities = await DatabaseHelper.instance.getActivityByDate(userId, _todayStr);
    _todayActivityMinutes = await DatabaseHelper.instance.getTotalActivityDurationByDate(userId, _todayStr);

    // 5. Goals
    _goal = await DatabaseHelper.instance.getGoal(userId);

    _isLoading = false;
    notifyListeners();
  }

  // ==================== MEAL / NUTRITION ACTIONS ====================
  Future<void> addMeal({
    required String name,
    required String mealType,
    required int calories,
    required double protein,
    required double carbs,
    required double fat,
    String? imagePath,
  }) async {
    if (_userId == null) return;
    final now = DateTime.now();
    final meal = MealRecord(
      userId: _userId!,
      name: name,
      mealType: mealType,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      imagePath: imagePath,
      date: _todayStr,
      time: DateFormat('HH:mm').format(now),
    );
    await DatabaseHelper.instance.insertMeal(meal);
    await loadAllData();
  }

  Future<void> deleteMeal(int id) async {
    await DatabaseHelper.instance.deleteMeal(id);
    await loadAllData();
  }
  // ==================== WATER ACTIONS ====================
  Future<void> addWater(int amount) async {
    if (_userId == null) return;
    final now = DateTime.now();
    final water = WaterIntake(
      userId: _userId!,
      amount: amount,
      date: _todayStr,
      time: DateFormat('HH:mm').format(now),
    );

    await DatabaseHelper.instance.insertWater(water);
    await loadAllData();
  }

  Future<void> deleteWater(int id) async {
    await DatabaseHelper.instance.deleteWater(id);
    await loadAllData();
  }

  // ==================== SLEEP ACTIONS ====================
  Future<void> addSleep({
    required String sleepTime,
    required String wakeTime,
    required double duration,
    required String quality,
  }) async {
    if (_userId == null) return;
    final sleep = SleepRecord(
      userId: _userId!,
      sleepTime: sleepTime,
      wakeTime: wakeTime,
      duration: duration,
      quality: quality,
      date: _todayStr,
    );

    await DatabaseHelper.instance.insertSleep(sleep);
    await loadAllData();
  }

  // ==================== WEIGHT ACTIONS ====================
  Future<void> addWeight(double weightKg, double heightCm) async {
    if (_userId == null) return;
    final bmi = BMICalculator.calculate(weightKg, heightCm);
    final weightRecord = WeightRecord(
      userId: _userId!,
      weight: weightKg,
      bmi: bmi,
      date: _todayStr,
    );

    await DatabaseHelper.instance.insertWeight(weightRecord);
    await loadAllData();
  }

  // ==================== ACTIVITY ACTIONS ====================
  Future<void> addActivity({
    required String type,
    required int durationMinutes,
    required double distanceKm,
  }) async {
    if (_userId == null) return;
    final calories = BMICalculator.estimateCalories(type, durationMinutes);
    final activity = ActivityRecord(
      userId: _userId!,
      type: type,
      duration: durationMinutes,
      distance: distanceKm,
      calories: calories,
      date: _todayStr,
    );

    await DatabaseHelper.instance.insertActivity(activity);
    await loadAllData();
  }

  // ==================== GOAL ACTIONS ====================
  Future<void> updateGoal({
    int? waterGoal,
    double? sleepGoal,
    double? weightGoal,
    int? activityGoal,
  }) async {
    if (_userId == null) return;

    final updatedGoal = UserGoal(
      userId: _userId!,
      waterGoal: waterGoal ?? _goal.waterGoal,
      sleepGoal: sleepGoal ?? _goal.sleepGoal,
      weightGoal: weightGoal ?? _goal.weightGoal,
      activityGoal: activityGoal ?? _goal.activityGoal,
    );

    await DatabaseHelper.instance.updateGoal(updatedGoal);
    await loadAllData();
  }
}


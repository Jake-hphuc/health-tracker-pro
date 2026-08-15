import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/water_intake.dart';
import '../models/sleep_record.dart';
import '../models/weight_record.dart';
import '../models/activity_record.dart';
import '../models/user_goal.dart';
import '../models/meal_record.dart';
import '../database/database_helper.dart';

/// Manages health-related data and state for the application.
/// 
/// This provider handles:
/// - Water intake tracking and goals
/// - Sleep records and quality
/// - Weight management and BMI
/// - Activity/exercise tracking
/// - Meal/nutrition records
/// - User health goals
/// - Weekly charts and visualization data
/// 
/// All data is persisted to SQLite database via DatabaseHelper.
class HealthProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  int? _userId;

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
  int get todayCaloriesIn => _todayMealList.fold(0, (sum, item) => sum + item.calories);

  SleepRecord? get latestSleep => _sleepList.isNotEmpty ? _sleepList.first : null;
  WeightRecord? get latestWeight => _weightList.isNotEmpty ? _weightList.first : null;

  String _todayStr() => DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future<void> init(int userId) async {
    _userId = userId;
    await refreshAll();
  }

  Future<void> refreshAll() async {
    if (_userId == null) return;
    final today = _todayStr();

    _todayWaterList = await _db.getWaterIntakesByDate(_userId!, today);
    _sleepList = await _db.getSleepRecords(_userId!);
    _weightList = await _db.getWeightRecords(_userId!);
    _activityList = await _db.getActivityRecords(_userId!);
    _todayMealList = await _db.getMealsByDate(_userId!, today);

    final goalFromDb = await _db.getUserGoal(_userId!);
    if (goalFromDb != null) {
      _goal = goalFromDb;
    } else {
      _goal = UserGoal(userId: _userId!, waterGoal: 2000, sleepGoal: 8.0, activityGoal: 30);
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

  Future<void> addWeight(double weight, double heightCm) async {
    if (_userId == null) return;
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final heightM = heightCm / 100.0;
    final bmi = weight / (heightM * heightM);

    final w = WeightRecord(
      userId: _userId!,
      weight: weight,
      bmi: bmi,
      date: dateStr,
    );

    await _db.insertWeightRecord(w);
    await refreshAll();
  }

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
    notifyListeners();
  }
}

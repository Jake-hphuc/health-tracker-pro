import '../models/meal_record.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';
import '../models/water_intake.dart';
import '../models/sleep_record.dart';
import '../models/weight_record.dart';
import '../models/activity_record.dart';
import '../models/user_goal.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  // In-Memory Data Store cho Web Fallback
  final List<MealRecord> _webMeals = [];
  int _webMealAutoId = 1;
  final List<User> _webUsers = [];
  final List<WaterIntake> _webWater = [];
  final List<SleepRecord> _webSleep = [];
  final List<WeightRecord> _webWeight = [];
  final List<ActivityRecord> _webActivities = [];
  final Map<int, UserGoal> _webGoals = {};
  int _webUserAutoId = 1;
  int _webWaterAutoId = 1;
  int _webSleepAutoId = 1;
  int _webWeightAutoId = 1;
  int _webActivityAutoId = 1;

  DatabaseHelper._init();

  Future<Database?> get database async {
    if (kIsWeb) return null; // Web sá»­ dá»¥ng In-Memory fallback
    if (_database != null) return _database!;
    _database = await _initDB('health_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Báº£ng Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        height REAL NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // 2. Báº£ng Water Intake
    await db.execute('''
      CREATE TABLE water_intake (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount INTEGER NOT NULL,
        date TEXT NOT NULL,
        time TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 3. Báº£ng Sleep Records
    await db.execute('''
      CREATE TABLE sleep_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        sleep_time TEXT NOT NULL,
        wake_time TEXT NOT NULL,
        duration REAL NOT NULL,
        quality TEXT NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 4. Báº£ng Weight Records
    await db.execute('''
      CREATE TABLE weight_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        weight REAL NOT NULL,
        bmi REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 5. Báº£ng Activity Records
    await db.execute('''
      CREATE TABLE activity_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        duration INTEGER NOT NULL,
        distance REAL NOT NULL,
        calories INTEGER NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 6. Báº£ng User Goals
    await db.execute('''
      CREATE TABLE user_goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER UNIQUE NOT NULL,
        water_goal INTEGER NOT NULL,
        sleep_goal REAL NOT NULL,
        weight_goal REAL NOT NULL,
        activity_goal INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // ==================== USER CRUD ====================
  Future<User?> createUser(User user) async {
    if (kIsWeb) {
      final newUser = user.copyWith(id: _webUserAutoId++);
      _webUsers.add(newUser);
      await createGoal(UserGoal(userId: newUser.id!));
      return newUser;
    }

    final db = await instance.database;
    final id = await db!.insert('users', user.toMap());
    final newUser = user.copyWith(id: id);
    await createGoal(UserGoal(userId: id));
    return newUser;
  }


  /// Seed admin vao web store neu chua co
  void seedAdmin(String email, String passwordHash) {
    if (kIsWeb) {
      final has = _webUsers.any((u) => u.email.toLowerCase() == email.toLowerCase());
      if (!has) {
        _webUsers.insert(0, User(
          id: 1,
          name: 'Administrator',
          email: email,
          password: passwordHash,
          height: 170.0,
          createdAt: DateTime.now().toIso8601String(),
          isAdmin: true,
        ));
        _webUserAutoId = _webUsers.length + 1;
      }
    }
  }

  /// Lay tat ca users (cho admin)
  List<User> getAllWebUsers() {
    return List.unmodifiable(_webUsers);
  }
  Future<User?> getUserByEmail(String email) async {
    if (kIsWeb) {
      try {
        return _webUsers.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
      } catch (_) {
        return null;
      }
    }

    final db = await instance.database;
    final maps = await db!.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  // ==================== MEAL CRUD ====================
  Future<int> insertMeal(MealRecord meal) async {
    if (kIsWeb) {
      final id = _webMealAutoId++;
      _webMeals.insert(0, MealRecord(
        id: id,
        userId: meal.userId,
        name: meal.name,
        mealType: meal.mealType,
        calories: meal.calories,
        protein: meal.protein,
        carbs: meal.carbs,
        fat: meal.fat,
        imagePath: meal.imagePath,
        date: meal.date,
        time: meal.time,
      ));
      return id;
    }
    final db = await instance.database;
    return await db!.insert('meal_records', meal.toMap());
  }

  Future<List<MealRecord>> getMealsByDate(int userId, String date) async {
    if (kIsWeb) {
      return _webMeals.where((m) => m.userId == userId && m.date == date).toList();
    }
    final db = await instance.database;
    final result = await db!.query(
      'meal_records',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'id DESC',
    );
    return result.map((map) => MealRecord.fromMap(map)).toList();
  }

  Future<int> getTotalCaloriesByDate(int userId, String date) async {
    if (kIsWeb) {
      final list = _webMeals.where((m) => m.userId == userId && m.date == date);
      return list.fold<int>(0, (sum, item) => sum + item.calories);
    }
    final db = await instance.database;
    final result = await db!.rawQuery('''
      SELECT SUM(calories) as total FROM meal_records 
      WHERE user_id = ? AND date = ?
    ''', [userId, date]);
    final total = result.first['total'];
    return (total as num?)?.toInt() ?? 0;
  }

  Future<int> deleteMeal(int id) async {
    if (kIsWeb) {
      _webMeals.removeWhere((m) => m.id == id);
      return 1;
    }
    final db = await instance.database;
    return await db!.delete('meal_records', where: 'id = ?', whereArgs: [id]);
  }
  // ==================== WATER CRUD ====================
  Future<int> insertWater(WaterIntake water) async {
    if (kIsWeb) {
      final id = _webWaterAutoId++;
      _webWater.add(WaterIntake(
        id: id,
        userId: water.userId,
        amount: water.amount,
        date: water.date,
        time: water.time,
      ));
      return id;
    }

    final db = await instance.database;
    return await db!.insert('water_intake', water.toMap());
  }

  Future<List<WaterIntake>> getWaterByDate(int userId, String date) async {
    if (kIsWeb) {
      return _webWater.where((w) => w.userId == userId && w.date == date).toList().reversed.toList();
    }

    final db = await instance.database;
    final result = await db!.query(
      'water_intake',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'id DESC',
    );
    return result.map((map) => WaterIntake.fromMap(map)).toList();
  }

  Future<int> getTotalWaterByDate(int userId, String date) async {
    if (kIsWeb) {
      final list = _webWater.where((w) => w.userId == userId && w.date == date);
      return list.fold<int>(0, (sum, item) => sum + item.amount);
    }

    final db = await instance.database;
    final result = await db!.rawQuery('''
      SELECT SUM(amount) as total FROM water_intake 
      WHERE user_id = ? AND date = ?
    ''', [userId, date]);
    final total = result.first['total'];
    return (total as num?)?.toInt() ?? 0;
  }

  Future<int> deleteWater(int id) async {
    if (kIsWeb) {
      _webWater.removeWhere((w) => w.id == id);
      return 1;
    }

    final db = await instance.database;
    return await db!.delete('water_intake', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== SLEEP CRUD ====================
  Future<int> insertSleep(SleepRecord sleep) async {
    if (kIsWeb) {
      final id = _webSleepAutoId++;
      _webSleep.insert(0, SleepRecord(
        id: id,
        userId: sleep.userId,
        sleepTime: sleep.sleepTime,
        wakeTime: sleep.wakeTime,
        duration: sleep.duration,
        quality: sleep.quality,
        date: sleep.date,
      ));
      return id;
    }

    final db = await instance.database;
    return await db!.insert('sleep_records', sleep.toMap());
  }

  Future<List<SleepRecord>> getSleepByDate(int userId, String date) async {
    if (kIsWeb) {
      return _webSleep.where((s) => s.userId == userId && s.date == date).toList();
    }

    final db = await instance.database;
    final result = await db!.query(
      'sleep_records',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'id DESC',
    );
    return result.map((map) => SleepRecord.fromMap(map)).toList();
  }

  Future<List<SleepRecord>> getAllSleepRecords(int userId) async {
    if (kIsWeb) {
      return _webSleep.where((s) => s.userId == userId).toList();
    }

    final db = await instance.database;
    final result = await db!.query(
      'sleep_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    return result.map((map) => SleepRecord.fromMap(map)).toList();
  }

  // ==================== WEIGHT CRUD ====================
  Future<int> insertWeight(WeightRecord weight) async {
    if (kIsWeb) {
      final id = _webWeightAutoId++;
      _webWeight.add(WeightRecord(
        id: id,
        userId: weight.userId,
        weight: weight.weight,
        bmi: weight.bmi,
        date: weight.date,
      ));
      return id;
    }

    final db = await instance.database;
    return await db!.insert('weight_records', weight.toMap());
  }

  Future<WeightRecord?> getLatestWeight(int userId) async {
    if (kIsWeb) {
      final userWeights = _webWeight.where((w) => w.userId == userId).toList();
      return userWeights.isNotEmpty ? userWeights.last : null;
    }

    final db = await instance.database;
    final result = await db!.query(
      'weight_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC, id DESC',
      limit: 1,
    );
    if (result.isNotEmpty) {
      return WeightRecord.fromMap(result.first);
    }
    return null;
  }

  Future<List<WeightRecord>> getAllWeightRecords(int userId) async {
    if (kIsWeb) {
      return _webWeight.where((w) => w.userId == userId).toList();
    }

    final db = await instance.database;
    final result = await db!.query(
      'weight_records',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date ASC',
    );
    return result.map((map) => WeightRecord.fromMap(map)).toList();
  }

  // ==================== ACTIVITY CRUD ====================
  Future<int> insertActivity(ActivityRecord activity) async {
    if (kIsWeb) {
      final id = _webActivityAutoId++;
      _webActivities.insert(0, ActivityRecord(
        id: id,
        userId: activity.userId,
        type: activity.type,
        duration: activity.duration,
        distance: activity.distance,
        calories: activity.calories,
        date: activity.date,
      ));
      return id;
    }

    final db = await instance.database;
    return await db!.insert('activity_records', activity.toMap());
  }

  Future<List<ActivityRecord>> getActivityByDate(int userId, String date) async {
    if (kIsWeb) {
      return _webActivities.where((a) => a.userId == userId && a.date == date).toList();
    }

    final db = await instance.database;
    final result = await db!.query(
      'activity_records',
      where: 'user_id = ? AND date = ?',
      whereArgs: [userId, date],
      orderBy: 'id DESC',
    );
    return result.map((map) => ActivityRecord.fromMap(map)).toList();
  }

  Future<int> getTotalActivityDurationByDate(int userId, String date) async {
    if (kIsWeb) {
      final list = _webActivities.where((a) => a.userId == userId && a.date == date);
      return list.fold<int>(0, (sum, item) => sum + item.duration);
    }

    final db = await instance.database;
    final result = await db!.rawQuery('''
      SELECT SUM(duration) as total FROM activity_records 
      WHERE user_id = ? AND date = ?
    ''', [userId, date]);
    final total = result.first['total'];
    return (total as num?)?.toInt() ?? 0;
  }

  // ==================== GOALS CRUD ====================
  Future<int> createGoal(UserGoal goal) async {
    if (kIsWeb) {
      _webGoals[goal.userId] = goal;
      return 1;
    }

    final db = await instance.database;
    return await db!.insert('user_goals', goal.toMap());
  }

  Future<UserGoal> getGoal(int userId) async {
    if (kIsWeb) {
      return _webGoals[userId] ?? UserGoal(userId: userId);
    }

    final db = await instance.database;
    final result = await db!.query(
      'user_goals',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    if (result.isNotEmpty) {
      return UserGoal.fromMap(result.first);
    }
    return UserGoal(userId: userId);
  }

  Future<int> updateGoal(UserGoal goal) async {
    if (kIsWeb) {
      _webGoals[goal.userId] = goal;
      return 1;
    }

    final db = await instance.database;
    return await db!.update(
      'user_goals',
      goal.toMap(),
      where: 'user_id = ?',
      whereArgs: [goal.userId],
    );
  }

  Future<void> close() async {
    if (!kIsWeb && _database != null) {
      final db = await instance.database;
      await db?.close();
    }
  }
}
